# AKS with Cert Management Bundle
### "Your personalized Kubernetes cluster"

This bundle creates an AKS cluster, configures helm with RBAC, installs an nginx-ingress-controller, installs kube-lego for certificate management, and modifies your domain to point to the newly provisioned nginx ingress controller service IP address.

## Credentials
By default, the `example-aks-credentials.yaml` file and the `run` script are configured to mount the necessary pieces to the authenticate to Azure. Another route to take is to configure a service principal. The necessary `az account login` line is included but commented out in the `run` script if you choose to use this in non-demo environment.

For the default way, make sure you have logged in via `az login` on your machine and run `az account -s <target-azure-subscription>` before beginning. This will set the right tokens in your `$HOME/.azure/azureTokens.json` and the right profile in `$HOME/.azure/azureProfile.json`

# Parameters
The default parameters set in this bundle are `domain`, `resource_group`, `lego_email`. See below for what the default configuration looks like. You can change these defaults in the file before running `duffle install`. You can also pass in overrides on the command line. See `$ duffle install --help` for more information.

In `bundle.json`:
```json
"parameters": {
  "domain": {
    "defaultValue": "containernativelabs.io",
    "type": "string",
    "destination": {
      "env": "DOMAIN"
    }
  },
  "resource_group": {
    "defaultValue": "duffle-aks",
    "type": "string",
    "destination": {
      "env": "RESOURCE_GROUP"
    }
  },
  "lego_email": {
    "defaultValue": "minooral@microsoft.com",
    "type": "string",
    "destination": {
      "env": "LEGO_EMAIL"
    }
  }
},
"credentials": {
  "subscription": {
    "env": "SUBSCRIPTION"
  }
}
```
