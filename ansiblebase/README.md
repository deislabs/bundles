# Ansible Base Bundle

This is a base invocation image for [Ansible + Azure RM](https://docs.ansible.com/ansible/latest/scenario_guides/guide_azure.html#).

## Usage

- Create your Ansible playbooks
  - install.yaml is used for the `install` and `upgrade` targets
  - uninstall.yaml is used for the `uninstall` target
- Write a `bundle.json`
- Write your Dockerfile
- ??? (or run `make docker-build`)
- Profit

### The `bundle.json` Config

You probably want to copy the `bundle.json` from this directory to use as the basis
for your project. Specifically, the credentials Ansible expects are:

```json
"credentials": {
    "tenant_id": {
        "env": "AZURE_TENANT"
    },
    "client_id": {
        "env": "AZURE_CLIENT_ID"
    },
    "client_secret": {
        "env": "AZURE_SECRET"
    },
    "subscription_id": {
        "env": "AZURE_SUBSCRIPTION_ID"
    }
}
```

If the `check` parameter is passed in (via the provided `destination` method, as seen below), then this will
run Ansible in `--check` mode instead of regular mode:

```json
"parameters": {
    "check": {
        "defaultValue": false,
        "type": "boolean",
        "destination": {
            "env": "CHECK"
        }
    }
}
```

### Dockerfile

The following Dockerfile should work:

```Dockerfile
FROM cnab/ansiblebase:latest

COPY your/ansible/*.yaml /cnab/app/playbooks
COPY your/Dockerfile /cnab
```

Then `make docker-build`