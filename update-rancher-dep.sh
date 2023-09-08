#!/bin/bash

set -ue

if [ -z "${GITHUB_WORKSPACE:-}" ]; then
    RANCHER_DIR="$(dirname -- "$0")/../../../rancher"
else
    RANCHER_DIR="${GITHUB_WORKSPACE}/rancher"
fi


if [ ! -e ~/.gitconfig ]; then
    git config --global user.name "highlander-ci-bot"
    git config --global user.email "highlander-ci@proton.me"
fi

# Update operator dependencies
cd "${RANCHER_DIR}"
go get "${OPERATOR_REPO}@v${OPERATOR_VERSION}"
go mod tidy
cd pkg/apis
go get "${OPERATOR_REPO}@v${OPERATOR_VERSION}"
go mod tidy
cd ../../

# Commit changes
git add go.* pkg/apis/go.*
git commit -m "Updating ${OPERATOR_REPO} to v${OPERATOR_VERSION}"
