# Check File Exists Action

[![Keyfactor](https://img.shields.io/badge/Keyfactor-yellow?logo=github)](https://github.com/Keyfactor/actions)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?logo=github-actions&logoColor=white)](https://github.com/features/actions)

> Checks whether specified files exist in the repository, with support for glob patterns.

| Branding | |
|----------|---|
| Icon | `search` |
| Color | `yellow` |

## Usage

```yaml
- uses: Keyfactor/actions/.github/actions/check-file-exists@v6
  with:
    files: "*.config"
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `files` | File path or glob pattern to check | Yes | - |
| `working-directory` | Directory to search in | No | `.` |

## Outputs

| Output | Description |
|--------|-------------|
| `exists` | `'true'` if any matching files exist, `'false'` otherwise |
| `matched_files` | Space-separated list of matched file paths |
| `count` | Number of matched files |

## Glob Pattern Support

The action supports standard glob patterns:

| Pattern | Matches |
|---------|---------|
| `*.yml` | All `.yml` files in current directory |
| `**/*.yml` | All `.yml` files recursively |
| `.goreleaser.y*ml` | `.goreleaser.yml` or `.goreleaser.yaml` |
| `src/**/*.cs` | All `.cs` files under `src/` |
| `{Dockerfile,*.dockerfile}` | `Dockerfile` or any `.dockerfile` file |

## Examples

### Basic File Check

```yaml
- uses: Keyfactor/actions/.github/actions/check-file-exists@v6
  id: check
  with:
    files: "Dockerfile"

- run: echo "Dockerfile exists: ${{ steps.check.outputs.exists }}"
```

### Check for GoReleaser Config

```yaml
jobs:
  detect:
    runs-on: ubuntu-latest
    outputs:
      has_goreleaser: ${{ steps.check.outputs.exists }}
    steps:
      - uses: keyfactor/checkout@v4
      - uses: Keyfactor/actions/.github/actions/check-file-exists@v6
        id: check
        with:
          files: ".goreleaser.y*ml"

  build-go:
    needs: detect
    if: needs.detect.outputs.has_goreleaser == 'true'
    uses: Keyfactor/actions/.github/workflows/go-build-and-release.yml@v6
```

### Check Multiple File Types

```yaml
- uses: Keyfactor/actions/.github/actions/check-file-exists@v6
  id: csharp-check
  with:
    files: "**/*.csproj"

- uses: Keyfactor/actions/.github/actions/check-file-exists@v6
  id: go-check
  with:
    files: "go.mod"

- run: |
    echo "Has C# projects: ${{ steps.csharp-check.outputs.exists }}"
    echo "Has Go module: ${{ steps.go-check.outputs.exists }}"
```

### Check in Subdirectory

```yaml
- uses: Keyfactor/actions/.github/actions/check-file-exists@v6
  id: check
  with:
    files: "*.csproj"
    working-directory: "src/MyProject"
```

### Use Matched Files

```yaml
- uses: Keyfactor/actions/.github/actions/check-file-exists@v6
  id: check
  with:
    files: "**/*.sln"

- name: Build all solutions
  if: steps.check.outputs.exists == 'true'
  run: |
    for sln in ${{ steps.check.outputs.matched_files }}; do
      echo "Building $sln..."
      dotnet build "$sln"
    done
```

### Check for Docker Configuration

```yaml
- uses: Keyfactor/actions/.github/actions/check-file-exists@v6
  id: docker-check
  with:
    files: "{Dockerfile,docker-compose.yml,*.dockerfile}"

- name: Docker build
  if: steps.docker-check.outputs.exists == 'true'
  run: docker build -t myapp .
```

### Count Matched Files

```yaml
- uses: Keyfactor/actions/.github/actions/check-file-exists@v6
  id: check
  with:
    files: "**/*.test.js"

- run: echo "Found ${{ steps.check.outputs.count }} test files"
```

## Requirements

- Repository must be checked out before running this action
- Bash shell (available on all GitHub-hosted runners)

## Implementation Details

The action uses bash glob expansion with `nullglob` and `globstar` options:
- `nullglob`: Returns empty if no matches (instead of literal pattern)
- `globstar`: Enables `**` for recursive matching

## Related Actions

- [detect-language](../detect-language/) - Detect repository language
- [parse-manifest](../parse-manifest/) - Parse integration-manifest.json
