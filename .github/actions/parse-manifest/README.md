# Parse Manifest Action

[![Keyfactor](https://img.shields.io/badge/Keyfactor-green?logo=github)](https://github.com/Keyfactor/actions)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?logo=github-actions&logoColor=white)](https://github.com/features/actions)

> Parses `integration-manifest.json` files and extracts configuration values for use in workflows.

| Branding | |
|----------|---|
| Icon | `file-text` |
| Color | `green` |

## Usage

```yaml
- uses: Keyfactor/actions/.github/actions/parse-manifest@v6
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `manifest-path` | Path to the manifest file | No | `integration-manifest.json` |

## Outputs

| Output | Description |
|--------|-------------|
| `name` | Integration name from the manifest |
| `release_dir` | Release directory path (defaults to `.`) |
| `release_project` | Project file to build (for .NET solutions) |
| `integration_type` | Integration type: `orchestrator`, `pam`, `gateway`, etc. |
| `update_catalog` | Whether to update the integration catalog (`'true'`/`'false'`) |
| `platform_matrix` | JSON array of target platforms for multi-platform builds |
| `status` | Parse status: `'success'` or `'not_found'` |

## Manifest Schema

The action expects manifests following the [Keyfactor Integration Manifest Schema](https://keyfactor.github.io/v2/integration-manifest-schema.json):

```json
{
  "$schema": "https://keyfactor.github.io/v2/integration-manifest-schema.json",
  "name": "my-integration",
  "integration_type": "orchestrator",
  "release_dir": "src/MyIntegration",
  "release_project": "MyIntegration.csproj",
  "update_catalog": true,
  "platform_matrix": ["linux/amd64", "linux/arm64", "windows/amd64"]
}
```

## Examples

### Basic Usage

```yaml
jobs:
  parse:
    runs-on: ubuntu-latest
    outputs:
      name: ${{ steps.manifest.outputs.name }}
      integration_type: ${{ steps.manifest.outputs.integration_type }}
    steps:
      - uses: keyfactor/checkout@v4
      - uses: Keyfactor/actions/.github/actions/parse-manifest@v6
        id: manifest
      - run: |
          echo "Integration: ${{ steps.manifest.outputs.name }}"
          echo "Type: ${{ steps.manifest.outputs.integration_type }}"
```

### Custom Manifest Path

```yaml
- uses: Keyfactor/actions/.github/actions/parse-manifest@v6
  id: manifest
  with:
    manifest-path: config/integration-manifest.json
```

### Conditional Catalog Update

```yaml
jobs:
  parse:
    runs-on: ubuntu-latest
    outputs:
      update_catalog: ${{ steps.manifest.outputs.update_catalog }}
    steps:
      - uses: keyfactor/checkout@v4
      - uses: Keyfactor/actions/.github/actions/parse-manifest@v6
        id: manifest

  update-catalog:
    needs: parse
    if: needs.parse.outputs.update_catalog == 'true'
    runs-on: ubuntu-latest
    steps:
      - run: echo "Updating integration catalog..."
```

### Multi-Platform Build

```yaml
jobs:
  parse:
    runs-on: ubuntu-latest
    outputs:
      platforms: ${{ steps.manifest.outputs.platform_matrix }}
    steps:
      - uses: keyfactor/checkout@v4
      - uses: Keyfactor/actions/.github/actions/parse-manifest@v6
        id: manifest

  build:
    needs: parse
    strategy:
      matrix:
        platform: ${{ fromJson(needs.parse.outputs.platform_matrix) }}
    runs-on: ubuntu-latest
    steps:
      - run: echo "Building for ${{ matrix.platform }}"
```

### Handle Missing Manifest

```yaml
- uses: Keyfactor/actions/.github/actions/parse-manifest@v6
  id: manifest

- name: Check manifest status
  run: |
    if [ "${{ steps.manifest.outputs.status }}" = "not_found" ]; then
      echo "No manifest found, using defaults"
    fi
```

### Build with Release Project

```yaml
jobs:
  parse:
    runs-on: ubuntu-latest
    outputs:
      release_dir: ${{ steps.manifest.outputs.release_dir }}
      release_project: ${{ steps.manifest.outputs.release_project }}
    steps:
      - uses: keyfactor/checkout@v4
      - uses: Keyfactor/actions/.github/actions/parse-manifest@v6
        id: manifest

  build:
    needs: parse
    runs-on: ubuntu-latest
    steps:
      - uses: keyfactor/checkout@v4
      - name: Build project
        working-directory: ${{ needs.parse.outputs.release_dir }}
        run: dotnet build ${{ needs.parse.outputs.release_project }}
```

## Default Values

When manifest fields are missing, the following defaults are used:

| Field | Default Value |
|-------|---------------|
| `release_dir` | `.` |
| `release_project` | `''` (empty) |
| `integration_type` | `''` (empty) |
| `update_catalog` | `'false'` |
| `platform_matrix` | `'[]'` (empty array) |

## Requirements

- Repository must be checked out before running this action
- `jq` is available on the runner (pre-installed on GitHub-hosted runners)

## Related Actions

- [detect-language](../detect-language/) - Detect repository language
- [check-file-exists](../check-file-exists/) - Check if files exist
