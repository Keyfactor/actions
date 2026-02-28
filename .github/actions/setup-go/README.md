# Setup Go Action

[![Keyfactor](https://img.shields.io/badge/Keyfactor-blue?logo=github)](https://github.com/Keyfactor/actions)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?logo=github-actions&logoColor=white)](https://github.com/features/actions)

> Sets up Go with module caching, version detection from `go.mod`, and optional tool installation.

| Branding | |
|----------|---|
| Icon | `box` |
| Color | `blue` |

## Usage

```yaml
- uses: Keyfactor/actions/.github/actions/setup-go@v6
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `go-version` | Go version to install (or `'file'` to read from go.mod) | No | `'file'` |
| `go-version-file` | Path to go.mod for version detection | No | `'go.mod'` |
| `cache` | Whether to cache Go modules | No | `'true'` |
| `install-tools` | Space-separated list of Go tools to install | No | `''` |

## Outputs

| Output | Description |
|--------|-------------|
| `go-version` | Installed Go version |
| `cache-hit` | `'true'` if module cache was restored |

## Features

1. **Automatic Version Detection**: Reads Go version from `go.mod` by default
2. **Module Caching**: Caches `$GOPATH/pkg/mod` based on `go.sum`
3. **Module Download**: Runs `go mod download` after setup
4. **Tool Installation**: Installs additional Go tools via `go install`
5. **Step Summary**: Displays environment info in GitHub Actions summary

## Examples

### Basic Usage (Version from go.mod)

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: keyfactor/checkout@v4
      - uses: Keyfactor/actions/.github/actions/setup-go@v6
      - run: go build ./...
```

### Specific Go Version

```yaml
- uses: Keyfactor/actions/.github/actions/setup-go@v6
  with:
    go-version: '1.21'
```

### Latest Go Version

```yaml
- uses: Keyfactor/actions/.github/actions/setup-go@v6
  with:
    go-version: 'stable'
```

### Install Development Tools

```yaml
- uses: Keyfactor/actions/.github/actions/setup-go@v6
  with:
    install-tools: |
      golang.org/x/tools/cmd/goimports@latest
      github.com/golangci/golangci-lint/cmd/golangci-lint@latest
      gotest.tools/gotestsum@latest
```

### Custom go.mod Location

```yaml
- uses: Keyfactor/actions/.github/actions/setup-go@v6
  with:
    go-version: 'file'
    go-version-file: 'cmd/myapp/go.mod'
```

### Disable Module Caching

```yaml
- uses: Keyfactor/actions/.github/actions/setup-go@v6
  with:
    cache: 'false'
```

### Complete Build and Test Workflow

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: keyfactor/checkout@v4

      - uses: Keyfactor/actions/.github/actions/setup-go@v6
        with:
          install-tools: 'gotest.tools/gotestsum@latest'

      - name: Build
        run: go build -v ./...

      - name: Test
        run: gotestsum --format short-verbose ./...

      - name: Vet
        run: go vet ./...
```

### GoReleaser Build

```yaml
jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: keyfactor/checkout@v4
        with:
          fetch-depth: 0

      - uses: Keyfactor/actions/.github/actions/setup-go@v6

      - name: Run GoReleaser
        uses: goreleaser/goreleaser-action@v5
        with:
          version: latest
          args: release --clean
```

### Check Cache Hit

```yaml
- uses: Keyfactor/actions/.github/actions/setup-go@v6
  id: setup

- name: Report cache status
  run: |
    if [ "${{ steps.setup.outputs.cache-hit }}" == "true" ]; then
      echo "Go modules restored from cache"
    else
      echo "Go modules downloaded fresh"
    fi
```

### Cross-Platform Build Matrix

```yaml
jobs:
  build:
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: keyfactor/checkout@v4
      - uses: Keyfactor/actions/.github/actions/setup-go@v6
      - run: go build -v ./...
```

## Version Detection

When `go-version: 'file'` (default), the action:
1. Reads the `go` directive from `go.mod`
2. Extracts the version number (e.g., `go 1.21` → `1.21`)
3. Installs the matching Go version

Example `go.mod`:
```go
module github.com/example/myapp

go 1.21

require (
    ...
)
```

## Tool Installation

Tools are installed using `go install`. Each tool should include a version:

```yaml
install-tools: |
  github.com/golangci/golangci-lint/cmd/golangci-lint@v1.55.0
  golang.org/x/tools/cmd/goimports@latest
```

Failed tool installations produce warnings but don't fail the action.

## Step Summary Output

The action appends environment information to `$GITHUB_STEP_SUMMARY`:

```markdown
### Go Environment
- **Go Version:** go1.21.5
- **Cache Hit:** true
- **GOPATH:** /home/runner/go
```

## Requirements

- Ubuntu, Windows, or macOS runner
- Valid `go.mod` file (if using version detection)

## Related Actions

- [detect-language](../detect-language/) - Detect repository language
- [setup-dotnet](../setup-dotnet/) - Setup .NET environment
- [setup-java](../setup-java/) - Setup Java environment
