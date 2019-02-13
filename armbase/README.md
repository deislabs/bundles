## Installation

Create credentials for this app with:

```
$ az ad sp create-for-rbac -n "<yourAppName>" 
{
  "appId": "YOUR_CLIENT_ID",
  "displayName": "armbasetest",
  "name": "http://armbasetest",
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
AZURE_CLIENT_ID=<YOUR_CLIENT_ID>
AZURE_CLIENT_SECRET=<YOUR_CLIENT_SECRET>
AZURE_TENANT_ID=<YOUR_TENANT_ID>
AZURE_SUBSCRIPTION_ID=<YOUR_SUBSCRIPTION_ID>
```

## Templates

ARM templates are a declarative language for installing stuff.

The [template format](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-authoring-templates) looks essentially like this:

```json
{
    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "",
    "parameters": {  },
    "variables": {  },
    "functions": {  },
    "resources": [  ],
    "outputs": {  }
}
```

## Parameters

Parameters are passed in according to the format described here: https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-deploy-cli#parameter-files

Example:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
     "storageAccountType": {
         "value": "Standard_GRS"
     }
  }
}
```

### Using this as a base bundle

To create a new bundle that can use this ARM installer, simply start your Dockerfile with the following:

```Dockerfile
FROM cnab/armbase:0.1.0

# Then copy your ARM templates to the /cnab/app/arm folder:
COPY app/arm /cnab/app/arm
```

Make sure you expose the parameters and credentials in your `bundle.json`/`bundle.cnab`:

```json
{
    "name": "arm-aci",
    "version": "0.1.0",
    "invocationImages": [
        {
            "imageType": "docker",
            "image": "technosophos/arm-aci:0.1.0"
        }
    ],
    "images": [
        {
            "imageType": "docker",
            "image": "microsoft/aci-helloworld",
            "digest": "sha256:a3b2eb140e6881ca2c4df4d9c97bedda7468a5c17240d7c5d30a32850a2bc573"
        }
    ],
    "parameters": {
        "azure_resource_group": {
            "defaultValue": "armbase-default",
            "type": "string"
        },
        "azure_location": {
            "defaultValue": "useast",
            "type": "string"
        }
    },
    "credentials": {
        "tenant_id": {
            "env": "AZURE_TENANT_ID"
        },
        "client_id": {
            "env": "AZURE_CLIENT_ID"
        },
        "client_secret": {
            "env": "AZURE_CLIENT_SECRET"
        },
        "subscription_id": {
            "env": "AZURE_SUBSCRIPTION_ID"
        }
    }
}
```