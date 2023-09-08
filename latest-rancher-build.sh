#!/bin/bash

set -ue

CURRENT_DIR=$PWD

if [ -z "${GITHUB_WORKSPACE:-}" ]; then
    RANCHER_DIR="$(dirname -- "$0")/../rancher"
else
    RANCHER_DIR="${GITHUB_WORKSPACE}/rancher"
fi

# Update operator dependencies
cd "${RANCHER_DIR}"
go get "${OPERATOR_REPO}@${OPERATOR_COMMIT}"
go mod tidy
cd pkg/apis
go get "${OPERATOR_REPO}@${OPERATOR_COMMIT}"
go mod tidy
cd ../../

# Build rancher image
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo update

find ./scripts/ci -type f -exec sed -i -e "s/.\/test/# .\/test/g" {} \;
find ./scripts/ci -type f -exec sed -i -e "s/.\/validate/# .\/validate/g" {} \;

RANCHER_VERSION=$(helm search repo rancher-latest/rancher --devel -o json | jq -r '.[] | select(.name == "rancher-latest/rancher").version')
find ./package/Dockerfile -type f -exec sed -i -e "s/ENV CATTLE_AGENT_IMAGE .*/ENV CATTLE_AGENT_IMAGE \$\{IMAGE_REPO\}\/rancher-agent:v${RANCHER_VERSION}/g" {} \;

make ci
cd "${CURRENT_DIR}"

# Pull latest rancher chart and substitute image
mkdir -p charts/

helm pull --devel --untar -d charts/ rancher-latest/rancher

RANCHER_IMAGE="${RANCHER_IMAGE//\//\\/}"
find ./charts/rancher/values.yaml -type f -exec sed -i -e "s/rancherImage: .*/rancherImage: ${RANCHER_IMAGE}/g" {} \;
find ./charts/rancher/values.yaml -type f -exec sed -i -e "s/# rancherImageTag: .*/rancherImageTag: ${RANCHER_IMAGE_TAG}/g" {} \;

helm package -d charts/ charts/rancher/ --version "${RANCHER_IMAGE_TAG}" --app-version "${RANCHER_IMAGE_TAG}"
