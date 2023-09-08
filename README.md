# hostedprovidersworkflows

This repository is dedicated to sharing workflows for hosted providers.

## Workflows and Usage

### `update-rancher-dep`

This workflow updates the operator version in the `rancher/rancher` repository and opens a PR.

Required inputs:

- `ref` - The branch to use for the GitHub action workflow. Default: `master`.
- `rancher_ref` - The target branch in the `rancher/rancher` repository (e.g., `release/v2.7`). Default: `release/v2.8`.
- `operator_repo` - The operator repository (e.g., `github.com/rancher/aks-operator`).
- `new_operator_version` - The new operator version (e.g., `1.1.0-rc2`). Do not include the 'v'.
- `token` - GitHub token with permissions to push to the Rancher fork and open PRs.

Example usage:

```yaml
jobs:
  update-rancher-dep:
    uses: rancher-sandbox/highlander-reusable-workflows/.github/workflows/update-rancher-dep.yaml@main
    with:
      ref: ${{ github.event.inputs.ref }}
      rancher_ref: ${{ github.event.inputs.rancher_ref }}
      operator_repo: ${{ github.event.inputs.operator_repo }}
      new_operator_version: ${{ github.event.inputs.new_operator_version }}
    secrets:
      token: ${{ secrets.CI_BOT_TOKEN }}
```

### `update-rancher-charts`

This workflow updates the operator version in the `rancher/charts` repository and opens a PR.

Required inputs:

- `ref` - The branch to use for the GitHub action workflow. Default: `master`.
- `charts_ref` - The target branch in the `rancher/charts` repository (e.g., `dev-v2.7`). Default: `dev-v2.8`.
- `operator` - The operator name (e.g., `aks-operator`).
- `prev_operator_version` - The previous operator version (e.g., `1.1.0-rc2`).
- `new_operator_version` - The new operator version.
- `prev_chart_version` - The previous Rancher Chart version (e.g., `101.1.0`).
- `new_chart_version` - The new Rancher Chart version.
- `should_replace` - Should the old operator version be replaced/removed (e.g., `true` in case of release candidate bumps).
- `token` - GitHub token with permissions to push to the Rancher fork and open PRs.

Example usage:

```yaml
jobs:
  update-rancher-charts:
    uses: rancher-sandbox/highlander-reusable-workflows/.github/workflows/update-rancher-charts.yaml@main
    with:
      ref: ${{ github.event.inputs.ref }}
      charts_ref: ${{ github.event.inputs.charts_ref }}
      operator: ${{ github.event.inputs.operator }}
      prev_operator_version: ${{ github.event.inputs.prev_operator_version }}
      new_operator_version: ${{ github.event.inputs.new_operator_version }}
      prev_chart_version: ${{ github.event.inputs.prev_chart_version }}
      new_chart_version: ${{ github.event.inputs.new_chart_version }}
      should_replace: ${{ github.event.inputs.should_replace }}
    secrets:
      token: ${{ secrets.CI_BOT_TOKEN }}
```

### `latest-rancher-build`

This workflow updates operator versions in `rancher/rancher` and builds a Helm chart with these changes.

Required inputs:

- `ref` - The branch to use for the GitHub action workflow. Default: `master`.
- `rancher_ref` - The target branch in the `rancher/rancher` repository (e.g., `release/v2.7`). Default: `release/v2.8`.
- `operator_repo` - Operator repository (e.g., `github.com/rancher/aks-operator`).
- `operator_commit` - Operator commit to use for updating `rancher/rancher`.
- `rancher_image` - Rancher image name.
- `rancher_helm_repo` - Rancher Helm repository to push to.

Example usage:

```yaml
jobs:
  nightly_custom_rancher_charts:
    needs: 
      - set_build_date
      - nightly_operator_charts
    uses: rancher-sandbox/highlander-reusable-workflows/.github/workflows/latest-rancher-build.yaml@main
    with:
      ref: main
      rancher_ref: release/v2.8
      operator_repo: github.com/rancher/aks-operator
      operator_commit: ${{ github.sha }}
      rancher_image: ttl.sh/rancher-aks-operator-nightly-${{ needs.set_build_date.outputs.BUILD_DATE }}
      rancher_helm_repo:  oci://ttl.sh/rancher-aks-operator-nightly
```

### `operator-with-latest-rancher-build.yaml`

This build a Helm chart for specified provider and using builds rancher using `latest-rancher-build`.

Required inputs:

- `operator_name` - The operator name (e.g., `aks-operator`).
- `rancher_ref` - The target branch in the `rancher/rancher` repository (e.g., `release/v2.7`). Default: `release/v2.8`.
- `operator_commit` - Operator commit to use for updating `rancher/rancher`.

Example usage:

```yaml
  publish_nightly:
    uses: rancher-sandbox/highlander-reusable-workflows/.github/workflows/operator-with-latest-rancher-build.yaml@main
    with:
      operator_name: aks-operator
      rancher_ref: release/v2.8
      operator_commit: ${{ github.sha }}
```
