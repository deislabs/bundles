#!/bin/sh

set -eo pipefail

function test_functional() {
  bundle="${1}"

  echo "Generating Creds for the ${bundle} bundle..."
  duffle creds generate "${bundle}-test-creds" -f "${bundle}/bundle.json" --insecure -q
  echo "Installing the ${bundle} bundle..."
  duffle install -d debug "${bundle}-test" -f "${bundle}/bundle.json" --insecure -c "${bundle}-test-creds"
}

# if BUNDLE in env non-null, run only on this bundle
if [[ -n "${BUNDLE}" ]]; then
  test_functional "${BUNDLE}"
else
  # run against all bundles
  for dir in $(ls -1); do
    if [[ -e "${dir}/bundle.json" ]]; then
      test_functional "${dir}"
    fi
  done
fi