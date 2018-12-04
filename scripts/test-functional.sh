#!/bin/sh

set -eo pipefail

function test_functional() {
  bundle="${1}"
  bundle_file="${bundle}/bundle.cnab"
  insecure=""
  params=""

  if [[ -n "${INSECURE}" ]]; then
    echo "Duffle is running in insecure mode..."
    bundle_file="${bundle}/bundle.json"
    insecure="--insecure"
  fi

  # get required params and supply default values
  if ! params=$(get_required_params ${bundle}); then
    echo "Unable to get required params: ${params}"
    return 1
  fi

  # run tests
  echo "Generating creds for the ${bundle} bundle..."
  duffle creds generate "${bundle}-test-creds" -f "${bundle_file}" -q ${insecure}
  echo "Installing the ${bundle} bundle..."
  duffle install \
    -d debug \
    -f "${bundle_file}" \
    -c "${bundle}-test-creds" \
    "${bundle}-test" ${params} ${insecure}
}

function get_required_params() {
  bundle="${1}"
  required_params=""

  if param_and_types="$(cat "${bundle}/bundle.json" \
    | jq -r '.parameters | to_entries[] | select(.value.required==true) | "\(.key)=\(.value.type)"' 2> /dev/null)"; then

    for param_and_type in ${param_and_types}; do
      param="${param_and_type%=*}"
      type="${param_and_type#*=}"

      case $type in
      string)
        required_params="${required_params} --set ${param}=BOGUS"
        ;;
      int)
        required_params="${required_params} --set ${param}=0"
        ;;
      bool)
        required_params="${required_params} --set ${param}=true"
        ;;
      *)
        echo "type ${type} not supported"
        return 1
        ;;
      esac
    done

  fi

  echo "${required_params}"
}

function main() {
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
}

main