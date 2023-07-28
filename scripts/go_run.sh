#!/usr/bin/env bash

# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
# `-u`: Errors if a variable is referenced before being set
# `-o pipefail`: Prevent errors in a pipeline (`|`) from being masked
set -uo pipefail

# cd into the bundle and use relative paths
if [[ $BASH_SOURCE = */* ]]; then
    cd -- "${BASH_SOURCE%/*}/"
    cd ..
fi

# Import environment variables from .env
set -o allexport && source .env && set +o allexport

# Set variable from environment variable PROJECT_VERSION, if the latter exists.
# If not, fall back to the specified default value (excluding the leading `-`).
declare -r build_version="${BUILD_VERSION:-1.0.0-alpha}"

./build/gokit-stringservice