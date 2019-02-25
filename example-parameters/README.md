# example-parameters

This bundle exhibits how to use parameters to inject environment variables into the invocation image.

To build this demo, run the following from the root of the `bundles` repo:

```
$ export BUNDLE=example-parameters
$ make sign-local
$ make docker-build
```

## Using This Bundle

Now, change directories into this `example-parameters` sub-directory.

The relevant portion of the `bundle.json` looks like this:

```json
"parameters": {
    "port": {
        "defaultValue": 8080,
        "type": "int",
        "metadata": {
            "description": "this will be $CNAB_P_PORT"
        }
    },
    "greeting": {
        "defaultValue": "hello",
        "type": "string",
        "destination": {
            "env": "GREETING"
        },
        "metadata":{
            "description": "this will be in $GREETING"
        }
    },
    "config": {
        "defaultValue": "",
        "type": "string",
        "destination": {
            "path": "/opt/example-parameters/config.txt"
        },
        "metadata": {
            "description": "this will be located in a file"
        }
    }
}
```

This declares three parameters: `port`, `greeting`, and `config`. The first is injected using the default environment variable scheme (`$CNAB_P_PORT`). The second is given a custom environment variable name (`$GREETING`). The third is stored in a file (`/opt/example-parameters/config.txt`).


To inject values into these parameters, experiment with the `--set` and `--set-file` flags on Duffle:

```console
$ duffle install example -f ./bundle.cnab --set-file config=./README.md --set greeting="HELLO" --set port=1234
```

When a parameter is not specified, it's `defaultValue` is used.
