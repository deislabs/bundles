PROJECT         := bundles
ORG             := deislabs
DOCKER_REGISTRY ?= cnab

BASE_DIR        := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

GIT             ?= git
GIT_TAG         := $(shell $(GIT) describe --tags --always)
VERSION         ?= ${GIT_TAG}
# Replace + with -, for Docker image tag compliance
IMAGE_TAG       ?= $(subst +,-,$(VERSION))
BUNDLE          ?=
DUFFLE_IMG      ?= brigade.azurecr.io/deislabs/duffle:latest

# --no-print-directory avoids verbose cd logging when invoking targets that utilize sub-makes
MAKE_OPTS       ?= --no-print-directory

ifeq ($(OS),Windows_NT)
	SHELL  = cmd.exe
	CHECK  = where.exe
else
	SHELL  ?= bash
	CHECK  ?= command -v
endif

HAS_DOCKER := $(shell $(CHECK) docker)
HAS_DUFFLE := $(shell $(CHECK) duffle)

.PHONY: has-docker
has-docker:
ifndef HAS_DOCKER
	$(error You must install docker)
endif

.PHONY: has-duffle
has-duffle:
ifndef HAS_DUFFLE
	$(error You must install duffle)
endif

# all loops through all sub-directories and if the file provided by the first argument exists,
# it will run the make target(s) provided by the second argument
define all
	@for dir in $$(ls -1); do \
		if [[ -e "$$dir/$(1)" ]]; then \
			BUNDLE=$$dir make $(MAKE_OPTS) $(2) ; \
		fi ; \
	done
endef

# run the provided make target on all bundles with a 'cnab/Dockerfile' file in their directory
define docker-all
	$(call all,cnab/Dockerfile,$(1))
endef

# run the provided make target on all bundles with a 'bundle.json' file in their directory
define bundle-all
	$(call all,bundle.json,$(1))
endef

.PHONY: check-bundle
check-bundle:
ifndef BUNDLE
	$(error BUNDLE must be provided, e.g., BUNDLE=<bundle> make <target>)
endif

.PHONY: build
build: docker-build sign-local

.PHONY: docker-build
docker-build:
ifndef BUNDLE
	$(call docker-all,docker-build)
else 
	docker build -t $(DOCKER_REGISTRY)/$(BUNDLE):$(IMAGE_TAG) $(BUNDLE)/cnab
endif

.PHONY: docker-push
docker-push:
ifndef BUNDLE
	$(call docker-all,docker-push)
else
	docker push $(DOCKER_REGISTRY)/$(BUNDLE):$(IMAGE_TAG)
endif

.PHONY: docker-run
docker-run: check-bundle
	docker run -t $(DOCKER_REGISTRY)/$(BUNDLE):$(VERSION)

.PHONY: sign
sign: has-duffle
ifndef BUNDLE
	$(call bundle-all,sign)
else
	duffle bundle sign -f $(BUNDLE)/bundle.json
endif

.PHONY: sign-local
sign-local: has-duffle
ifndef BUNDLE
	$(call bundle-all,sign-local)
else
	duffle bundle sign -f $(BUNDLE)/bundle.json -o $(BUNDLE)/bundle.cnab
endif

JSON_SCHEMA_URI  := https://api.github.com/repos/deislabs/cnab-spec/contents/schema/bundle.schema.json
JSON_SCHEMA_FILE := /tmp/bundle.schema.json
VALIDATOR_IMG    := $(ORG)/$(PROJECT)-ajv
VALIDATOR_CMD    := ajv test -s $(JSON_SCHEMA_FILE) -d $(BUNDLE)/bundle.json --valid

# TODO: remove need to pass/use GITHUB_AUTH_TOKEN once cnab-spec repo public
.PHONY: build-validator
build-validator:
ifndef GITHUB_AUTH_TOKEN
	$(error GITHUB_AUTH_TOKEN currently needed to fetch json schema)
endif
	@docker build -f Dockerfile.ajv \
		--build-arg github_auth_token=${GITHUB_AUTH_TOKEN} \
		--build-arg json_schema_uri=$(JSON_SCHEMA_URI) \
		--build-arg json_schema_file=$(JSON_SCHEMA_FILE) \
		-t $(VALIDATOR_IMG) .

.PHONY: validate
validate:
ifndef BUNDLE
	$(call bundle-all,validate)
else
	@docker run --rm \
		-v ${BASE_DIR}:/root \
		-w /root \
		-e BUNDLE=$(BUNDLE) \
		$(VALIDATOR_IMG) sh -c '$(VALIDATOR_CMD)'
endif

.PHONY: build-validator-local
build-validator-local:
	@npm install -g ajv-cli
	@wget -q \
		--header="Authorization: token ${GITHUB_AUTH_TOKEN}" \
		--header 'Accept: application/vnd.github.v3.raw' \
		-O $(JSON_SCHEMA_FILE) \
		$(JSON_SCHEMA_URI)

# TODO: remove need to pass/use GITHUB_AUTH_TOKEN once cnab-spec repo public
.PHONY: validate-local
validate-local:
ifndef GITHUB_AUTH_TOKEN
	$(error GITHUB_AUTH_TOKEN currently needed to fetch json schema)
endif
ifndef BUNDLE
	$(call bundle-all,validate-local)
else
	@$(VALIDATOR_CMD)
endif

# duffle commands in functional tests will run in insecure mode if this is set to 'true'
INSECURE ?= false

.PHONY: test-functional
test-functional:
ifeq ($(INSECURE),false)
	make $(MAKE_OPTS) sign-local
endif
	./scripts/test-functional.sh

.PHONY: test-functional-docker
test-functional-docker:
	docker run --rm \
		-v ${BASE_DIR}:/src \
		-w /src \
		-e BUNDLE=$(BUNDLE) \
		-e INSECURE=$(INSECURE) \
		-e CHECK=which \
		$(DUFFLE_IMG) sh -c "make $(MAKE_OPTS) test-functional"
