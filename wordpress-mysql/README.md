# Kubernetes Wordpress + Azure MySQL Bundle
### "Because you need a database and probably don't want to manage it yourself"

This bundle provisions an Azure MySQL instance, creates a database, installs Wordpress on a given AKS cluster and connects the wordpress application to the newly provisioned Azure MySQL instance.

## Prerequistes
- Running Kubernetes cluster (we used AKS) with Helm enabled (Tiller running)
- Log into azure-cli locally to put your Azure credentials in place

## Install this bundle
1. Clone this repo: `git clone git@github.com:deis/bundles.git`
2. `cd bundles`
3. You'll need to pass in credentials to connect to your Kubernetes cluster and MySQL database server.
```console
$ duffle creds add wordpress-mysql/example-wordpress-mysql-credential-set.yaml
$ duffle creds show example-wordpress-mysql-credential-set
```
4. Use the `duffle install` command by passing in a name (`wordpress-mysql`), a bundle metadata file (`-f <bundle.json>`) and a credential set(`-c example-wordpress-mysql-credential-set`):
```console
$ duffle install wordpress-mysql -f wordpress-mysql/cnab/bundle.json -c example-wordpress-mysql-credential-set
```

_Note: You may just see `Executing install action...` and nothing happen for a while. Don't worry stuff is happening. You can tail your docker container logs to follow along using via docker logs -f <container_name> in another terminal. We're going to work on getting more feedback in the main terminal asap._

### Considerations for future iterations of this bundle
- Connect to azure-cli with a service prinicpal
