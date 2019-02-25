# Terraform: A Base Invocation Image for Terraform

This CNAB bundle provides a base image for working with TerraForm.

To test:

```console
$ duffle creds generate -f ./bundle.json terraform
$ edit $HOME/.duffle/credentials/terraform.yaml
$ duffle install -c terraform -f bundle.json my-terraform-test
```

To use this as a base image:

```Dockerfile
FROM cnab/terraform:latest

COPY my/terraform/dir /cnab/app/tf
COPY my/Dockerfile /cnab/Dockerfile
```

See the `aks-terraform` example to see how to build such an invocation image.
