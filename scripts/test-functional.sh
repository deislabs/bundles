#!/bin/sh

set -euo pipefail

bundle="${1}"

echo "Generating Creds for the ${bundle} bundle..."
duffle creds generate "${bundle}-test-creds" -f "${bundle}/bundle.json" --insecure -q
echo "Installing the ${bundle} bundle..."
duffle install -d debug "${bundle}-test" -f "${bundle}/bundle.json" --insecure -c "${bundle}-test-creds"
