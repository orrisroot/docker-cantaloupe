#!/bin/bash

BASE_IMAGE="gcr.io/distroless/java11-debian11:latest"
TARGET_IMAGE="docker.io/orrisroot/cantaloupe:latest"
GITHUB_PROJECT="cantaloupe-project/cantaloupe"

REQUIRED_COMMANDS=("skopeo" "jq" "basename")

cd $(dirname $0)

for COMMAND in "${REQUIRED_COMMANDS[@]}"; do
    if ! command -v ${COMMAND} > /dev/null; then
        echo "Error: ${COMMAND} command is required." 1>&2
        exit 2
    fi
done

check_version () {
    local PROJECT=$1
    local CURRENT_VERSION=$(cat ./build.sh | grep '^VERSION=' | sed -e 's/^VERSION=//g')
    local LATEST_VERSION=$(curl -sL "https://api.github.com/repos/${PROJECT}/releases/latest" | jq -r ".tag_name" | sed -e "s/^v//g")

    if [ "${CURRENT_VERSION}" != "${LATEST_VERSION}" ]; then
        echo "The Latest version has been released."
        echo "- https://github.com/${PROJECT} - ${LATEST_VERSION}"
        echo ""
        return 1
    fi

    return 0
}


check_image () {
    local BASE_CONTAINER=$1
    local TARGET_CONTAINER=$2
    local BASE_JSON=$(skopeo inspect docker://${BASE_CONTAINER})
    [ $? -eq 0 ] || return $?
    local TARGET_JSON=$(skopeo inspect docker://${TARGET_CONTAINER})
    [ $? -eq 0 ] || return $?
    local BASE_LAYER_ID=$(echo ${BASE_JSON} | jq "(.Layers | reverse)[0]")
    local FOUND_LAYER_ID=$(echo ${TARGET_JSON} | jq ".Layers[] | select(. == ${BASE_LAYER_ID})")

    if [ "${BASE_LAYER_ID}" != "${FOUND_LAYER_ID}" ]; then
        echo "The Docker image needs to be updated."
        echo "- ${TARGET_CONTAINER}"
        echo "  |- ${BASE_CONTAINER}  [newer version found]"
        echo ""
        return 1
    fi

    return 0
}

check_version "${GITHUB_PROJECT}"
[ $? -eq 0 ] || exit $?

check_image "${BASE_IMAGE}" "${TARGET_IMAGE}"
