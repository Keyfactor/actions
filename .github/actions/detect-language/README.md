# Detect Language Action

[![Keyfactor](https://img.shields.io/badge/Keyfactor-blue?logo=github)](https://github.com/Keyfactor/actions)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?logo=github-actions&logoColor=white)](https://github.com/features/actions)

> Detects the primary programming language of a repository using the GitHub Linguist API with file extension fallback.

| Branding | |
|----------|---|
| Icon | `code` |
| Color | `blue` |

## Usage

```yaml
- uses: Keyfactor/actions/.github/actions/detect-language@v6
```

## Inputs

This action has no inputs. It automatically detects the repository language.

## Outputs

| Output | Description |
|--------|-------------|
| `primary_language` | The detected primary language (lowercase): `csharp`, `go`, `java`, or `unknown` |
| `is_csharp` | `'true'` if the primary language is C# |
| `is_go` | `'true'` if the primary language is Go |
| `is_java` | `'true'` if the primary language is Java |

## Detection Logic

1. **GitHub Linguist API** (primary method):
   - Queries `GET /repos/{owner}/{repo}/languages`
   - Uses the language with the highest byte count
   - Maps language names to normalized identifiers

2. **File Extension Fallback** (if API fails):
   - `.csproj`, `.cs` → `csharp`
   - `.go`, `go.mod` → `go`
   - `.java`, `pom.xml` → `java`

## Language Mapping

| GitHub Linguist | Output Value |
|-----------------|--------------|
| C# | `csharp` |
| Go | `go` |
| Java | `java` |
| Other | `unknown` |

## Examples

### Basic Usage

```yaml
jobs:
  detect:
    runs-on: ubuntu-latest
    outputs:
      language: ${{ steps.detect.outputs.primary_language }}
    steps:
      - uses: keyfactor/checkout@v4
      - uses: Keyfactor/actions/.github/actions/detect-language@v6
        id: detect
      - run: echo "Detected language: ${{ steps.detect.outputs.primary_language }}"
```

### Conditional Job Execution

```yaml
jobs:
  detect:
    runs-on: ubuntu-latest
    outputs:
      is_go: ${{ steps.detect.outputs.is_go }}
    steps:
      - uses: keyfactor/checkout@v4
      - uses: Keyfactor/actions/.github/actions/detect-language@v6
        id: detect

  build-go:
    needs: detect
    if: needs.detect.outputs.is_go == 'true'
    runs-on: ubuntu-latest
    steps:
      - uses: keyfactor/checkout@v4
      - run: go build ./...
```

### Multi-Language Build Matrix

```yaml
jobs:
  detect:
    runs-on: ubuntu-latest
    outputs:
      primary_language: ${{ steps.detect.outputs.primary_language }}
      is_csharp: ${{ steps.detect.outputs.is_csharp }}
      is_go: ${{ steps.detect.outputs.is_go }}
      is_java: ${{ steps.detect.outputs.is_java }}
    steps:
      - uses: keyfactor/checkout@v4
      - uses: Keyfactor/actions/.github/actions/detect-language@v6
        id: detect

  build:
    needs: detect
    runs-on: ubuntu-latest
    steps:
      - uses: keyfactor/checkout@v4

      - name: Build C#
        if: needs.detect.outputs.is_csharp == 'true'
        run: dotnet build

      - name: Build Go
        if: needs.detect.outputs.is_go == 'true'
        run: go build ./...

      - name: Build Java
        if: needs.detect.outputs.is_java == 'true'
        run: mvn package
```

## Requirements

- Repository must be checked out before running this action
- `GITHUB_TOKEN` must have `contents: read` permission (default)

## Related Actions

- [parse-manifest](../parse-manifest/) - Parse integration-manifest.json
- [setup-dotnet](../setup-dotnet/) - Setup .NET environment
- [setup-go](../setup-go/) - Setup Go environment
- [setup-java](../setup-java/) - Setup Java environment
