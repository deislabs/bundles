BINDIR    := $(CURDIR)/bin
GOFLAGS   :=
LDFLAGS   := -w -s
TESTFLAGS :=

ifeq ($(OS),Windows_NT)
	TARGET = armup.exe
	SHELL  = cmd.exe
	CHECK  = where.exe
else
	TARGET = armup
	SHELL  = bash
	CHECK  = command -v
endif

GIT_TAG  := $(shell git describe --tags --always)
VERSION  := ${GIT_TAG}
#LDFLAGS  += -X github.com/deis/duffle/pkg/version.Version=$(VERSION)

.PHONY: build
build:
	go build $(GOFLAGS) -o $(BINDIR)/$(TARGET) -ldflags '$(LDFLAGS)' ./...

.PHONY: cxbuild
cxbuild:
	GOOS=linux GOARCH=amd64 go build $(GOFLAGS) -o cnab/app/armup -ldflags '$(LDFLAGS)' ./...

# Note: to build/push the Docker image for this bundle,
# call the root Makefile's targets from the root of this project , e.g.
# BUNDLE=armbase make docker-build

.PHONY: test
test:
	go test $(TESTFLAGS) ./...

.PHONY: lint
lint:
	gometalinter --config ./gometalinter.json ./...

HAS_DEP          := $(shell $(CHECK) dep)
HAS_GOMETALINTER := $(shell $(CHECK) gometalinter)

.PHONY: bootstrap
bootstrap:
ifndef HAS_DEP
	go get -u github.com/golang/dep/cmd/dep
endif
ifndef HAS_GOMETALINTER
	go get -u github.com/alecthomas/gometalinter
	gometalinter --install
endif
	dep ensure -vendor-only -v
