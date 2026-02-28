# Setup .NET Action

[![Keyfactor](https://img.shields.io/badge/Keyfactor-blue?logo=github)](https://github.com/Keyfactor/actions)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?logo=github-actions&logoColor=white)](https://github.com/features/actions)

> Sets up .NET SDK with NuGet authentication, package caching, and dependency restoration.

| Branding | |
|----------|---|
| Icon | `package` |
| Color | `blue` |

## Usage

```yaml
- uses: Keyfactor/actions/.github/actions/setup-dotnet@v6
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `dotnet-version` | .NET SDK version(s) to install | No | `8.0.x` |
| `nuget-auth-token` | Token for GitHub Packages NuGet authentication | No | `''` |
| `nuget-source-url` | NuGet source URL for private packages | No | `https://nuget.pkg.github.com/Keyfactor/index.json` |
| `restore` | Whether to run `dotnet restore` | No | `'true'` |
| `cache` | Whether to cache NuGet packages | No | `'true'` |

## Outputs

| Output | Description |
|--------|-------------|
| `dotnet-version` | Installed .NET SDK version |
| `cache-hit` | `'true'` if NuGet cache was restored |

## Features

1. **SDK Installation**: Installs specified .NET SDK version(s)
2. **NuGet Caching**: Caches `~/.nuget/packages` based on project files
3. **GitHub Packages Auth**: Configures NuGet source for Keyfactor private packages
4. **Dependency Restoration**: Optionally runs `dotnet restore`
5. **Step Summary**: Displays environment info in GitHub Actions summary

## Examples

### Basic Usage

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: keyfactor/checkout@v4
      - uses: Keyfactor/actions/.github/actions/setup-dotnet@v6
      - run: dotnet build
```

### Specific .NET Version

```yaml
- uses: Keyfactor/actions/.github/actions/setup-dotnet@v6
  with:
    dotnet-version: '6.0.x'
```

### Multiple .NET Versions

```yaml
- uses: Keyfactor/actions/.github/actions/setup-dotnet@v6
  with:
    dotnet-version: |
      6.0.x
      7.0.x
      8.0.x
```

### With Private NuGet Packages

```yaml
- uses: Keyfactor/actions/.github/actions/setup-dotnet@v6
  with:
    nuget-auth-token: ${{ secrets.GITHUB_TOKEN }}
```

### Custom NuGet Source

```yaml
- uses: Keyfactor/actions/.github/actions/setup-dotnet@v6
  with:
    nuget-auth-token: ${{ secrets.NUGET_TOKEN }}
    nuget-source-url: 'https://pkgs.dev.azure.com/myorg/_packaging/myfeed/nuget/v3/index.json'
```

### Skip Restore

```yaml
- uses: Keyfactor/actions/.github/actions/setup-dotnet@v6
  with:
    restore: 'false'

- name: Restore with specific options
  run: dotnet restore --no-cache --force
```

### Disable Caching

```yaml
- uses: Keyfactor/actions/.github/actions/setup-dotnet@v6
  with:
    cache: 'false'
```

### Complete Build Workflow

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: keyfactor/checkout@v4

      - uses: Keyfactor/actions/.github/actions/setup-dotnet@v6
        with:
          dotnet-version: '8.0.x'
          nuget-auth-token: ${{ secrets.GITHUB_TOKEN }}

      - name: Build
        run: dotnet build --configuration Release

      - name: Test
        run: dotnet test --no-build --configuration Release

      - name: Publish
        run: dotnet publish --no-build --configuration Release -o ./publish
```

### Check Cache Hit

```yaml
- uses: Keyfactor/actions/.github/actions/setup-dotnet@v6
  id: setup

- name: Report cache status
  run: |
    if [ "${{ steps.setup.outputs.cache-hit }}" == "true" ]; then
      echo "NuGet packages restored from cache"
    else
      echo "NuGet packages downloaded fresh"
    fi
```

## Cache Key Generation

The cache key is generated from:
- Runner OS (`${{ runner.os }}`)
- Hash of all `.csproj` files
- Hash of all `packages.lock.json` files

```
{runner.os}-nuget-{hash}
```

Fallback restore keys:
```
{runner.os}-nuget-
```

## NuGet Source Configuration

When `nuget-auth-token` is provided, the action:
1. Removes any existing `keyfactor-github` source
2. Adds the authenticated source with provided credentials

The source is configured with `--store-password-in-clear-text` as required by .NET CLI on Linux.

## Step Summary Output

The action appends environment information to `$GITHUB_STEP_SUMMARY`:

```markdown
### .NET Environment
- **SDK Version:** 8.0.100
- **Cache Hit:** true
```

## Requirements

- Ubuntu, Windows, or macOS runner
- `contents: read` permission for checkout

## Related Actions

- [detect-language](../detect-language/) - Detect repository language
- [setup-go](../setup-go/) - Setup Go environment
- [setup-java](../setup-java/) - Setup Java environment
