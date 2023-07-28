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

echo "Starting container for image '$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG'"
echo "Container Name: '$DOCKER_NAME'"
echo "Container Port: 8080/tcp"
docker run \
    -p 8080:8080 \
    --detach \
    --name $DOCKER_NAME \
    --label runtime.context="local testing" \
    --label runtime.end-of-life="$(date -v$DOCKER_runtime_end_of_life -u +"%Y-%m-%dT%H:%M:%SZ")" \
    "$DOCKER_IMAGE_NAME":"$DOCKER_IMAGE_TAG"