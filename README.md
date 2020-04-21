# (DEPRECATED) CNAB bundles

⛔ **Notice: This repository is deprecated.  Relevant examples have been moved to the [Duffle](https://github.com/cnabio/duffle) CNAB reference implementation repository.  The examples in this repo are no longer maintained.**

This repository contains an array of CNAB bundles. Those that contain `base` in the name
are base invocation images, intended to be used by other bundles. Most of those are
"stand alone" in the sense that they _can_ be installed. But they typically just create
placeholder data.

Clone this repository to work with these bundles.

## Prerequisites

 * The [duffle](https://github.com/deislabs/duffle) binary will be needed to work with these bundles.
It can be built and installed locally via instructions in the [duffle](https://github.com/deislabs/duffle) repo,
or the latest release can be fetched from the [duffle releases](https://github.com/deislabs/duffle/releases) page.

 * Docker

 * make

## Quick Start

Here we build the bundle and then install the bundle via `duffle`:

```console
$ BUNDLE=helloworld VERSION=latest make build

$ duffle install my-helloworld helloworld
Executing install action...
Port parameter was set to 8080
Install action
Action install complete for my-helloworld
```

We can then check the status of an installed bundle and then, optionally, uninstall the bundle:

```console
$ duffle status my-helloworld
Installation Name:    	my-helloworld
...
Bundle:               	helloworld
Last Action Performed:	install
Last Action Status:   	success
Last Action Message:
Executing status action in bundle...
Port parameter was set to 8080
Status action
Action status complete for my-helloworld

$ duffle uninstall my-helloworld
Executing uninstall action...
Port parameter was set to 8080
uninstall action
Action uninstall complete for my-helloworld
```

## Recommendations

Most demos also require credentials (`duffle install -c CREDS BUNDLE_NAME`). See the credential set documentation below to see how to create these.

We recommend starting with the following bundles:

- For Helm/Kubernetes: `duffle install my-hellohelm hellohelm...`
    - Requires a k8s cluster and credentials to that cluster
    - Creates an Alpine linux chart (pod)
- For Terraform: `duffle install my-terraform terraform ...` (The aks-terraform bundle takes a long time and requires some extra tuning)
    - Requires an Azure account
    - Creates a VM plus network resources and a storage account
- For ARM: `duffle install my-arm-aci arm-aci ...`
    - Requires an Azure account
    - Creates an container running in ACI
- For Ansible: `duffle install my-ansible-azurevm ansible-azurefm ...` (`ansiblebase` is faster, but just installs a resource group)
    - Requires an Azure account
    - Creates a VM plus network
- For ~pure awesomeness~ Kubernetes + Azure: `duffle install my-aks aks ...`
    - Requires an Azure account
    - Requires a DNS name that can be used to assign an IP
    - Creates an AKS Kubernetes cluster
    - Creates several Helm charts
    - Creates Kubernetes RBACs
    - Creates a Kubernetes Ingress
    - Maps a domain name to the Ingress controller

Note that `helloazure` requires a special Duffle driver. It provisions VMs instead of Docker images, and is considered expert-only.

## Azure Configuration

Many of the examples here use Azure as a public cloud. To use these images, you will need the following information:

- tenant ID (usually `AZURE_TENANT_ID` in the code)
- subscription ID (usually `AZURE_SUBSCRIPTION_ID`)
- client ID (usually `AZURE_CLIENT_ID`)
- client secret (usually `AZURE_CLIENT_SECRET`)

Typically, the process for obtaining this information is as follows.

Create a service principal:

```
$ az ad sp create-for-rbac -n "dufflepreview" 
{
  "appId": "YOUR_CLIENT_ID",
  "displayName": "dufflepreview",
  "name": "http://dufflepreview",
  "password": "YOUR_CLIENT_SECRET",
  "tenant": "YOUR_TENANT_ID"
}
```

You can get the subscription ID for the appropriate subscription using:

```console
$ az account list -o table
Name                                            CloudName    SubscriptionId                        State    IsDefault
----------------------------------------------  -----------  ------------------------------------  -------  -----------
# list of stuff
```

Now create the following environment variables:

```
export AZURE_CLIENT_ID=<YOUR_CLIENT_ID>
export AZURE_CLIENT_SECRET=<YOUR_CLIENT_SECRET>
export AZURE_TENANT_ID=<YOUR_TENANT_ID>
export AZURE_SUBSCRIPTION_ID=<YOUR_SUBSCRIPTION_ID>
```

(Note that Ansible uses slightly different names)

## Credential Sets

Most of the CNAB bundles in this repository require you to pass in at least _some_ credentials. With Duffle, this is done via credential sets.

The following command will generate stubbed credentials and put them in `$HOME/.duffle/credentials`. You will need to go edit those and complete them:

```console
$ duffle creds generate -f path/to/bundle.json $NAME
```

Where `$NAME` is the name you want to give to these credentials. For example:

```console
$ duffle creds generate example-helm-creds hello-helm
name: example-helm-creds
credentials:
- name: kubeconfig
  source:
    value: EMPTY
  destination:
    path: /root/.kube/config
$ edit $HOME/.duffle/credentials/example-helm-creds.yaml
```

The `source` can be one of:

- `value:` The literal value (e.g. `value: supersecretpassword`)
- `env:` The name of an environment variable (e.g. `env: AZURE_TENANT_ID`)
- `path:` The path to a file on your local filesystem (e.g. `path: $HOME/.kube/config`)

Note that in `path:`, environment variables are interpolated.

Once you have generated credential sets, you can list them like this: `duffle creds list`.

To use a credential set, supply it with the `-c` flag: 

```console
$ duffle install -c example-helm-creds my-helm-test hellohelm
```

## Developers

To invoke common commands on bundles in this repo, such as `make build`, `make docker-build` and `make docker-push`, one can run `BUNDLE=<bundle name> make <target>` (or simply `make <target>` to run against all bundles.)  See [DEVELOPERS.md](DEVELOPERS.md) for more details.

You can see three different "flavors" of CNAB bundle here.

- Declarative bundles that use base images
    - arm-aci (ACI app created via ARM templates)
    - hellohelm (Helm charts)
    - ansible-azurevm (Ansible)
    - aks-terraform (Terraform)
- Base bundles intended to be used by other bundles
    - terraform
    - ansiblebase
    - armbase
    - makebase
    - k8sbase
- Highly specific "expert" bundles
    - wordpress
    - aks
