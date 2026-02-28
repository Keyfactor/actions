# Keyfactor Actions

Reusable GitHub Actions workflows and composite actions for Keyfactor integration CI/CD pipelines.

## Table of Contents

- [What's New in v6](#whats-new-in-v6)
- [Quick Start](#quick-start)
- [Architecture](#architecture)
- [Workflows](#workflows)
- [Composite Actions](#composite-actions)
- [Configuration](#configuration)
- [Migration from v4](#migration-from-v4)

---

## What's New in v6

### Major Changes

| Feature | Description |
|---------|-------------|
| **PR Quality Checks** | 10 automated checks including secrets scanning, dependency review, license compliance, and code quality |
| **Signoff Summary** | Automated PR comments with check status and self-review checklist |
| **Composite Actions** | 7 reusable actions for language detection, manifest parsing, and environment setup |
| **SBOM Generation** | Automatic Software Bill of Materials generation on releases (CycloneDX format) |
| **Modular Architecture** | Workflows split into focused, single-responsibility components |

### New Quality Checks

| Check | Blocking | Description |
|-------|----------|-------------|
| Secrets Scan | Yes | Gitleaks + TruffleHog secret detection |
| Dependency Review | Yes | CVE and license scanning via GitHub |
| Vulnerability Scan | Yes | Language-specific (`govulncheck`, `dotnet list --vulnerable`) |
| License Compliance | Yes | GPL/AGPL detection |
| PR Title Validation | Yes | Conventional Commits enforcement |
| PR Size Check | Yes (>3000 lines) | Encourages smaller, reviewable PRs |
| CHANGELOG Updated | Yes | Ensures changes are documented |
| Commit PII Check | Yes | Scans for emails/phone numbers in commits |
| Code Quality | Yes | Language-specific linting |
| Manifest Validation | Yes | JSON schema validation |
| Code Formatting | Warning | Style enforcement |
| Prohibited Keywords | Warning | TODO/FIXME detection |
| Breaking Changes | Info | Flags for release notes |

### Removed (Legacy)

- `assign-env-from-json.yml` → Replaced by `parse-manifest` action
- `check-todos-license-headers.yml` → Replaced by `pr-quality-checks.yml`
- `github-release.yml` → Split into `create-release.yml` + `pr-quality-checks.yml`

---

## Quick Start

### Prerequisites

1. An `integration-manifest.json` file in your repository root
2. Required secrets configured in your repository

### Basic Usage

Create `.github/workflows/keyfactor-bootstrap-workflow.yml`:

```yaml
name: Keyfactor Bootstrap Workflow

on:
  workflow_dispatch:
  pull_request:
    types: [opened, closed, synchronize, edited, reopened]
  push:
  create:
    branches:
      - 'release-*.*'

jobs:
  call-starter-workflow:
    uses: Keyfactor/actions/.github/workflows/starter.yml@v6
    secrets:
      token: ${{ secrets.V2BUILDTOKEN }}
      gpg_key: ${{ secrets.KF_GPG_PRIVATE_KEY }}
      gpg_pass: ${{ secrets.KF_GPG_PASSPHRASE }}
      scan_token: ${{ secrets.SAST_TOKEN }}
    # Optional: For doctool README screenshots
    with:
      command_token_url: ${{ vars.COMMAND_TOKEN_URL }}
      command_hostname: ${{ vars.COMMAND_HOSTNAME }}
      command_base_api_path: ${{ vars.COMMAND_API_PATH }}
    secrets:
      entra_username: ${{ secrets.DOCTOOL_ENTRA_USERNAME }}
      entra_password: ${{ secrets.DOCTOOL_ENTRA_PASSWD }}
      command_client_id: ${{ secrets.COMMAND_CLIENT_ID }}
      command_client_secret: ${{ secrets.COMMAND_CLIENT_SECRET }}
```

### Example `integration-manifest.json`

```json
{
  "$schema": "https://keyfactor.github.io/v2/integration-manifest-schema.json",
  "name": "My Integration",
  "integration_type": "orchestrator",
  "status": "production",
  "support_level": "kf-supported",
  "link_github": true,
  "update_catalog": true,
  "release_dir": "MyIntegration/bin/Release",
  "release_project": "MyIntegration/MyIntegration.csproj",
  "description": "Description of the integration"
}
```

---

## Architecture

### Workflow Phases

The `starter.yml` workflow executes in 6 phases:

```
┌─────────────────────────────────────────────────────────────────┐
│ Phase 1: Context Detection                                       │
│   ├── detect-language (C#, Go, Java)                            │
│   ├── parse-manifest (integration-manifest.json)                │
│   └── check-file-exists (.goreleaser.yml, etc.)                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ Phase 2: Quality Gates (PR only)                                 │
│   ├── pr-quality-checks.yml (10 checks)                         │
│   └── signoff-summary.yml (PR comment)                          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ Phase 3: Release Management (PR to release-* branch)            │
│   └── create-release.yml (version computation, GitHub release)  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ Phase 4: Build (language-specific)                               │
│   ├── dotnet-build-and-release.yml (C#)                         │
│   ├── go-build-and-release.yml (Go)                             │
│   └── maven-build-and-release.yml (Java)                        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ Phase 5: Post-Release                                            │
│   ├── sbom-generation.yml (CycloneDX SBOM)                      │
│   ├── generate-readme.yml (doctool screenshots)                 │
│   ├── update-catalog.yml (integration catalog)                  │
│   └── kf-post-release.yml (PR to main)                          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ Phase 6: Repository Config (on release-* branch creation)       │
│   └── kf-configure-repo.yml (branch protection, teams)         │
└─────────────────────────────────────────────────────────────────┘
```

### Event Handling

| Event | Trigger | Actions |
|-------|---------|---------|
| `pull_request` (open) | PR opened/updated to `release-*` | Quality checks, pre-release build |
| `pull_request` (merged) | PR merged to `release-*` | Full release, SBOM, post-release PR |
| `push` (main) | Push to main | README generation, catalog update |
| `create` | `release-*` branch created | Repository configuration |

---

## Workflows

### Core Workflows

#### `starter.yml`

The main orchestrator workflow. Call this from downstream repositories.

```yaml
uses: Keyfactor/actions/.github/workflows/starter.yml@v6
```

**Inputs:**

| Input | Type | Required | Description |
|-------|------|----------|-------------|
| `command_token_url` | string | No | Command API token URL (doctool) |
| `command_hostname` | string | No | Command API hostname (doctool) |
| `command_base_api_path` | string | No | Command API base path (doctool) |

**Secrets:**

| Secret | Required | Description |
|--------|----------|-------------|
| `token` | Yes | GitHub token for API access |
| `gpg_key` | Yes* | GPG private key for Go signing |
| `gpg_pass` | Yes* | GPG passphrase |
| `scan_token` | No | Polaris scan token |
| `entra_username` | No | Entra username (doctool) |
| `entra_password` | No | Entra password (doctool) |
| `command_client_id` | No | Command client ID (doctool) |
| `command_client_secret` | No | Command client secret (doctool) |

*Required for Go builds

---

#### `pr-quality-checks.yml`

Runs all PR quality checks in parallel.

```yaml
uses: Keyfactor/actions/.github/workflows/pr-quality-checks.yml@v6
with:
  primary_language: 'C#'  # or 'Go', 'Java'
```

**Outputs:** All check results (`*_passed`, `*_findings`)

---

#### `create-release.yml`

Handles version computation and GitHub release creation.

```yaml
uses: Keyfactor/actions/.github/workflows/create-release.yml@v6
```

**Outputs:**

| Output | Description |
|--------|-------------|
| `release_version` | Computed version (e.g., `1.2.3-rc.0`) |
| `release_url` | Upload URL for artifacts |
| `is_full_release` | `true` if merged PR |
| `is_pre_release` | `true` if open PR |
| `is_release_branch` | `true` if targeting `release-*` |

---

#### `signoff-summary.yml`

Posts a formatted summary comment on PRs.

```yaml
uses: Keyfactor/actions/.github/workflows/signoff-summary.yml@v6
with:
  secrets_scan_passed: ${{ needs.quality-checks.outputs.secrets_scan_passed }}
  # ... all other check outputs
```

---

#### `sbom-generation.yml`

Generates Software Bill of Materials in CycloneDX format.

```yaml
uses: Keyfactor/actions/.github/workflows/sbom-generation.yml@v6
with:
  primary_language: 'C#'
  release_version: '1.2.3'
secrets:
  token: ${{ secrets.GITHUB_TOKEN }}
```

---

## Composite Actions

### Using Composite Actions Directly

You can use the composite actions in your own workflows for more control.

---

### `detect-language`

Detects the primary programming language of the repository.

```yaml
- name: Detect language
  id: language
  uses: Keyfactor/actions/.github/actions/detect-language@v6
  with:
    token: ${{ secrets.GITHUB_TOKEN }}

- name: Use results
  run: |
    echo "Language: ${{ steps.language.outputs.primary_language }}"
    echo "Is C#: ${{ steps.language.outputs.is_csharp }}"
    echo "Is Go: ${{ steps.language.outputs.is_go }}"
    echo "Is Java: ${{ steps.language.outputs.is_java }}"
```

**Outputs:**

| Output | Description |
|--------|-------------|
| `primary_language` | Detected language (`C#`, `Go`, `Java`, etc.) |
| `is_csharp` | `true` if C# |
| `is_go` | `true` if Go |
| `is_java` | `true` if Java |

---

### `parse-manifest`

Parses `integration-manifest.json` and extracts configuration values.

```yaml
- name: Parse manifest
  id: manifest
  uses: Keyfactor/actions/.github/actions/parse-manifest@v6
  with:
    manifest_path: 'integration-manifest.json'  # optional, default

- name: Use results
  run: |
    echo "Name: ${{ steps.manifest.outputs.name }}"
    echo "Type: ${{ steps.manifest.outputs.integration_type }}"
    echo "Release Dir: ${{ steps.manifest.outputs.release_dir }}"
    echo "Update Catalog: ${{ steps.manifest.outputs.update_catalog }}"
```

**Outputs:**

| Output | Description |
|--------|-------------|
| `name` | Integration name |
| `description` | Integration description |
| `integration_type` | Type (orchestrator, gateway, etc.) |
| `status` | Status (production, pilot, etc.) |
| `release_dir` | Release artifacts directory |
| `release_project` | Project file to build |
| `update_catalog` | Whether to update catalog |
| `platform_matrix` | JSON array of platforms |
| `manifest_exists` | Whether manifest file exists |

---

### `check-file-exists`

Checks if files exist, supporting glob patterns.

```yaml
- name: Check for GoReleaser
  id: goreleaser
  uses: Keyfactor/actions/.github/actions/check-file-exists@v6
  with:
    files: '.goreleaser.y*ml'

- name: Use results
  if: steps.goreleaser.outputs.exists == 'true'
  run: echo "GoReleaser config found!"
```

**Inputs:**

| Input | Required | Description |
|-------|----------|-------------|
| `files` | Yes | File path or glob pattern |

**Outputs:**

| Output | Description |
|--------|-------------|
| `exists` | `true` if any file matches |
| `matched_files` | Comma-separated list of matches |
| `count` | Number of matched files |

---

### `setup-dotnet`

Sets up .NET environment with NuGet authentication and caching.

```yaml
- name: Setup .NET
  uses: Keyfactor/actions/.github/actions/setup-dotnet@v6
  with:
    dotnet-version: '8.0.x'
    nuget-auth-token: ${{ secrets.GITHUB_TOKEN }}
    restore: 'true'
    cache: 'true'
```

**Inputs:**

| Input | Default | Description |
|-------|---------|-------------|
| `dotnet-version` | `8.0.x` | .NET SDK version |
| `nuget-auth-token` | - | Token for GitHub Packages auth |
| `nuget-source-url` | Keyfactor URL | NuGet source URL |
| `restore` | `true` | Run `dotnet restore` |
| `cache` | `true` | Cache NuGet packages |

---

### `setup-go`

Sets up Go environment with module caching.

```yaml
- name: Setup Go
  uses: Keyfactor/actions/.github/actions/setup-go@v6
  with:
    go-version: 'file'  # reads from go.mod
    cache: 'true'
    install-tools: 'golang.org/x/vuln/cmd/govulncheck@latest'
```

**Inputs:**

| Input | Default | Description |
|-------|---------|-------------|
| `go-version` | `file` | Go version or `file` for go.mod |
| `go-version-file` | `go.mod` | Path to go.mod |
| `cache` | `true` | Cache Go modules |
| `install-tools` | - | Space-separated tools to install |

---

### `setup-java`

Sets up Java JDK with Maven caching.

```yaml
- name: Setup Java
  uses: Keyfactor/actions/.github/actions/setup-java@v6
  with:
    java-version: '17'
    distribution: 'temurin'
    cache: 'maven'
```

**Inputs:**

| Input | Default | Description |
|-------|---------|-------------|
| `java-version` | `17` | Java version |
| `distribution` | `temurin` | JDK distribution |
| `cache` | `maven` | Build tool to cache |
| `maven-settings` | - | Custom settings.xml path |

---

### `determine-release-type`

Determines release type from PR context.

```yaml
- name: Determine release type
  id: release
  uses: Keyfactor/actions/.github/actions/determine-release-type@v6

- name: Use results
  run: |
    echo "Full release: ${{ steps.release.outputs.is_full_release }}"
    echo "Pre-release: ${{ steps.release.outputs.is_pre_release }}"
    echo "Next version: ${{ steps.release.outputs.next_version }}"
```

---

## Configuration

### PR Auto-Labeling

To enable auto-labeling on PRs, copy the labeler template to your repository:

```bash
cp .github/labeler.yml.template .github/labeler.yml
```

Labels applied automatically:
- `documentation` - Changes to `*.md`, `docs/**`
- `dependencies` - Changes to `*.csproj`, `go.mod`, `pom.xml`
- `ci/cd` - Changes to `.github/**`
- `tests` - Changes to test files
- `bug-fix` - Branch starts with `fix/`, `bugfix/`, `hotfix/`
- `feature` - Branch starts with `feature/`, `feat/`
- `breaking-change` - PR body contains "BREAKING CHANGE"

### Custom PII Patterns

Create `.github/pii-patterns.txt` to add custom PII patterns:

```
customer-specific-pattern
internal-email-domain\.com
```

### Custom Gitleaks Config

Create `.gitleaks.toml` for custom secret allowlists:

```toml
[allowlist]
description = "Allowlisted patterns"
paths = [
  '''test/fixtures/.*''',
]
```

---

## Migration from v4

### Breaking Changes

1. **Workflow references**: Update `@v4` to `@v6`
2. **Removed workflows**: `assign-env-from-json.yml`, `check-todos-license-headers.yml`, `github-release.yml`
3. **New quality gates**: PRs to release branches now require passing quality checks

### Migration Steps

1. Update your workflow file:
   ```yaml
   # Before
   uses: Keyfactor/actions/.github/workflows/starter.yml@v4

   # After
   uses: Keyfactor/actions/.github/workflows/starter.yml@v6
   ```

2. (Optional) Add labeler config for auto-labeling:
   ```bash
   curl -o .github/labeler.yml \
     https://raw.githubusercontent.com/Keyfactor/actions/v6/.github/labeler.yml.template
   ```

3. (Optional) Update PR title format to Conventional Commits:
   ```
   feat: add new feature
   fix: resolve bug
   docs: update documentation
   chore: maintenance task
   ```

---

## Secrets Reference

| Secret | Required For | Description |
|--------|--------------|-------------|
| `V2BUILDTOKEN` | All builds | GitHub token for API access |
| `KF_GPG_PRIVATE_KEY` | Go builds | GPG private key for signing |
| `KF_GPG_PASSPHRASE` | Go builds | GPG passphrase |
| `SAST_TOKEN` | Polaris scans | Polaris scan token |
| `DOCTOOL_ENTRA_USERNAME` | README screenshots | Entra authentication |
| `DOCTOOL_ENTRA_PASSWD` | README screenshots | Entra password |
| `COMMAND_CLIENT_ID` | README screenshots | Command API client ID |
| `COMMAND_CLIENT_SECRET` | README screenshots | Command API client secret |

---

## License

Apache 2.0
