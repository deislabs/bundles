# Developer's Guide

## Bundle Development

### Build

```shell
# builds the invocation image for a given bundle
BUNDLE=<bundle> make build

# builds invocation images for all bundles
make build
```

### Docker Build

```shell
# builds the invocation image for the provided bundle
BUNDLE=<bundle> make docker-build

# builds invocation images for all bundles
make docker-build
```

### Docker Push

```shell
# pushes the invocation image for the provided bundle
BUNDLE=<bundle> make docker-push

# pushes invocation images for all bundles
make docker-push
```

### Validate Bundle(s)

These targets can be used to validate that a bundle's `bundle.json` adheres to the official json schema spec.

#### Docker-based

```shell
make build-validator

# validates the provided bundle
BUNDLE=<bundle> make validate

# validates all bundles
make validate
```

#### Local

```shell
make build-validator-local

# validates the provided bundle
BUNDLE=<bundle> make validate-local

# validates all bundles
make validate-local
```

### Docker Run

This command is only valid for a provided `BUNDLE`.

```shell
BUNDLE=<bundle> make docker-run
```

### Test Bundle(s)

#### Docker-based

This will run inside the latest `duffle` docker image.

```shell
# runs functional tests against the provided bundle
BUNDLE=<bundle> make test-functional-docker

# runs functional tests against all bundles
make test-functional-docker
```

#### Local

This will run using the local `duffle` binary found in one's path.

```shell
# runs functional tests against the provided bundle
BUNDLE=<bundle> make test-functional

# runs functional tests against all bundles
make test-functional
```
