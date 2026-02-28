# Keyfactor Actions

Reusable GitHub Actions workflows and composite actions for Keyfactor integration CI/CD pipelines.

## Table of Contents

- [What's New in v6](#whats-new-in-v6)
- [Quick Start](#quick-start)
- [Architecture](#architecture)
- [Workflows](#workflows)
- [Composite Actions](#composite-actions)
- [Permissions](#permissions)
- [Configuration](#configuration)
- [Migration from v4](#migration-from-v4)

---

## What's New in v6

### Major Changes

| Feature | Description |
|---------|-------------|
| **PR Quality Checks** | 15 automated checks including secrets scanning, dependency review, license compliance, unit tests, and code quality |
| **Signoff Summary** | Automated PR comments with check status and self-review checklist |
| **Signoff Notification** | Email notifications with Azure DevOps integration when PRs are ready for signoff |
| **Composite Actions** | 7 reusable actions for language detection, manifest parsing, and environment setup |
| **SBOM Generation** | Automatic Software Bill of Materials generation on releases (CycloneDX format) |
| **.NET Unit Tests** | Automated test discovery and execution with `allow_failure` support |
| **Upstream Actions** | Replaced forked actions with upstream versions for better maintenance |
| **Modular Architecture** | Workflows split into focused, single-responsibility components |

### Quality Checks

| Check | Blocking | Description |
|-------|----------|-------------|
| Secrets Scan | Yes | TruffleHog secret detection |
| Dependency Review | Yes | CVE and license scanning via GitHub |
| Vulnerability Scan | Yes | Language-specific (`govulncheck`, `dotnet list --vulnerable`) |
| License Compliance | Yes | GPL/AGPL detection |
| PR Title Validation | Yes | Conventional Commits enforcement |
| PR Size Check | Yes (>3000 lines) | Encourages smaller, reviewable PRs |
| CHANGELOG Updated | Yes | Ensures changes are documented |
| Commit PII Check | Yes | Scans for emails/phone numbers in commits |
| Code Quality | Yes | Language-specific linting (Roslyn, golangci-lint, Checkstyle) |
| Manifest Validation | Yes | JSON schema validation |
| Unit Tests | Configurable | .NET test execution with `allow_test_failure` option |
| Code Formatting | Warning | Style enforcement |
| Prohibited Keywords | Warning | TODO/FIXME detection |
| Breaking Changes | Info | Flags for release notes |

### Removed (Legacy)

- `assign-env-from-json.yml` - Replaced by `parse-manifest` action
- `check-todos-license-headers.yml` - Replaced by `pr-quality-checks.yml`
- `github-release.yml` - Split into `create-release.yml` + `pr-quality-checks.yml`

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
    types: [opened, closed, synchronize, edited, reopened, labeled]
  push:
    branches: [main]
  create:
    branches:
      - 'release-*'

jobs:
  call-starter-workflow:
    uses: Keyfactor/actions/.github/workflows/starter.yml@v6
    secrets:
      token: ${{ secrets.V2BUILDTOKEN }}
      gpg_key: ${{ secrets.KF_GPG_PRIVATE_KEY }}
      gpg_pass: ${{ secrets.KF_GPG_PASSPHRASE }}
      scan_token: ${{ secrets.SAST_TOKEN }}
      entra_username: ${{ secrets.DOCTOOL_ENTRA_USERNAME }}
      entra_password: ${{ secrets.DOCTOOL_ENTRA_PASSWD }}
      command_client_id: ${{ secrets.COMMAND_CLIENT_ID }}
      command_client_secret: ${{ secrets.COMMAND_CLIENT_SECRET }}
    with:
      command_token_url: ${{ vars.COMMAND_TOKEN_URL }}
      command_hostname: ${{ vars.COMMAND_HOSTNAME }}
      command_base_api_path: ${{ vars.COMMAND_API_PATH }}
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
Phase 1: Context Detection
  - detect-language (C#, Go, Java)
  - parse-manifest (integration-manifest.json)
  - check-file-exists (.goreleaser.yml, etc.)

Phase 2: Quality Gates (PR only)
  - pr-quality-checks.yml (15 parallel checks)
  - signoff-summary.yml (PR comment)

Phase 3: Release Management (PR to release-* branch)
  - create-release.yml (version computation, GitHub release)

Phase 4: Build (language-specific)
  - dotnet-build-and-release.yml (C#)
  - go-build-and-release.yml (Go + GoReleaser)
  - maven-build-and-release.yml (Java)

Phase 5: Post-Release (on merge)
  - sbom-generation.yml (CycloneDX SBOM)
  - kf-post-release.yml (PR to main)
  - kf-delete-prereleases.yml (cleanup RC tags)
  - generate-readme.yml (doctool screenshots)
  - update-catalog.yml (integration catalog)

Phase 6: Repository Config (on release-* branch creation)
  - kf-configure-repo.yml (branch protection, teams)
```

### Event Handling

| Event | Trigger | Actions |
|-------|---------|---------|
| `pull_request` (open) | PR opened/updated to `release-*` | Quality checks, pre-release build |
| `pull_request` (merged) | PR merged to `release-*` | Full release, SBOM, cleanup, PR to main |
| `pull_request` (labeled) | PR labeled "ready for signoff" | Email notification (if configured) |
| `push` (main) | Push to main | README generation, catalog update |
| `create` | `release-*` branch created | Repository configuration |

---

## Workflows

### Core Workflows

#### `starter.yml`

The main orchestrator workflow. Call this from downstream repositories.

```yaml
uses: Keyfactor/actions/.github/workflows/starter.yml@v6
secrets:
  token: ${{ secrets.V2BUILDTOKEN }}
  gpg_key: ${{ secrets.KF_GPG_PRIVATE_KEY }}
  gpg_pass: ${{ secrets.KF_GPG_PASSPHRASE }}
```

---

#### `pr-quality-checks.yml`

Runs all PR quality checks in parallel.

```yaml
uses: Keyfactor/actions/.github/workflows/pr-quality-checks.yml@v6
with:
  primary_language: 'C#'
  allow_test_failure: false  # Set true for projects without tests
```

**Inputs:**

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `primary_language` | string | `''` | Repository language (C#, Go, Java) |
| `allow_test_failure` | boolean | `false` | Allow test failures without blocking PR |

**Outputs:** All check results (`*_passed`, `*_findings`)

---

#### `dotnet-test.yml`

Runs .NET unit tests with coverage reporting.

```yaml
uses: Keyfactor/actions/.github/workflows/dotnet-test.yml@v6
with:
  dotnet-version: |
    6.0.x
    8.0.x
  allow_failure: true  # For projects without tests
  collect_coverage: true
secrets:
  token: ${{ secrets.GITHUB_TOKEN }}
```

**Inputs:**

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `dotnet-version` | string | `6.0.x, 8.0.x` | .NET SDK versions |
| `allow_failure` | boolean | `false` | Don't fail if tests fail |
| `test_filter` | string | `''` | Test filter expression |
| `collect_coverage` | boolean | `true` | Collect code coverage |
| `coverage_threshold` | number | `0` | Minimum coverage % |

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

#### `signoff-notification.yml`

Sends email notifications when PR is labeled "ready for signoff".

```yaml
uses: Keyfactor/actions/.github/workflows/signoff-notification.yml@v6
with:
  recipients: 'team@example.com'
  devops_org: 'Keyfactor'
  devops_project: 'Integration'
  sync_devops_tag: true
secrets:
  token: ${{ secrets.GITHUB_TOKEN }}
  smtp_server: ${{ secrets.SMTP_SERVER }}
  smtp_username: ${{ secrets.SMTP_USERNAME }}
  smtp_password: ${{ secrets.SMTP_PASSWORD }}
  email_from: ${{ secrets.EMAIL_FROM }}
  azure_devops_token: ${{ secrets.AZURE_DEVOPS_PAT }}
```

**Features:**
- Extracts Azure DevOps work item from branch name (`ab#1234`)
- Sends HTML email with PR details and links
- Tags DevOps work item with "Ready for Signoff"
- Includes links: PR, RC (pre-release), Working Branch, Changelog

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

### `detect-language`

Detects the primary programming language of the repository.

```yaml
- uses: Keyfactor/actions/.github/actions/detect-language@v6
  id: language

- run: echo "Language: ${{ steps.language.outputs.primary_language }}"
```

| Output | Description |
|--------|-------------|
| `primary_language` | Detected language (`C#`, `Go`, `Java`) |
| `is_csharp` | `true` if C# |
| `is_go` | `true` if Go |
| `is_java` | `true` if Java |

---

### `parse-manifest`

Parses `integration-manifest.json` and extracts configuration.

```yaml
- uses: Keyfactor/actions/.github/actions/parse-manifest@v6
  id: manifest

- run: |
    echo "Name: ${{ steps.manifest.outputs.name }}"
    echo "Type: ${{ steps.manifest.outputs.integration_type }}"
```

| Output | Description |
|--------|-------------|
| `name` | Integration name |
| `integration_type` | Type (orchestrator, gateway, etc.) |
| `release_dir` | Release artifacts directory |
| `release_project` | Project file to build |
| `update_catalog` | Whether to update catalog |
| `manifest_exists` | Whether manifest exists |

---

### `check-file-exists`

Checks if files exist, supporting glob patterns.

```yaml
- uses: Keyfactor/actions/.github/actions/check-file-exists@v6
  id: check
  with:
    files: '.goreleaser.y*ml'

- if: steps.check.outputs.exists == 'true'
  run: echo "Found ${{ steps.check.outputs.count }} files"
```

---

### `setup-dotnet`

Sets up .NET environment with NuGet authentication.

```yaml
- uses: Keyfactor/actions/.github/actions/setup-dotnet@v6
  with:
    dotnet-version: '8.0.x'
    nuget-auth-token: ${{ secrets.GITHUB_TOKEN }}
```

---

### `setup-go`

Sets up Go environment with module caching.

```yaml
- uses: Keyfactor/actions/.github/actions/setup-go@v6
  with:
    go-version: 'file'  # reads from go.mod
    install-tools: 'golang.org/x/vuln/cmd/govulncheck@latest'
```

---

### `setup-java`

Sets up Java JDK with Maven caching.

```yaml
- uses: Keyfactor/actions/.github/actions/setup-java@v6
  with:
    java-version: '17'
    distribution: 'temurin'
```

---

### `determine-release-type`

Determines release type from PR context.

```yaml
- uses: Keyfactor/actions/.github/actions/determine-release-type@v6
  id: release

- run: |
    echo "Version: ${{ steps.release.outputs.next_version }}"
    echo "Full release: ${{ steps.release.outputs.is_full_release }}"
```

---

## Permissions

### Workflow Permissions

Each workflow requires specific permissions. Here's a reference:

| Workflow | Permissions |
|----------|-------------|
| `starter.yml` | Inherited from caller |
| `pr-quality-checks.yml` | `contents: read`, `pull-requests: write` |
| `create-release.yml` | `contents: write` |
| `dotnet-test.yml` | `contents: read` |
| `signoff-notification.yml` | `contents: read`, `pull-requests: read` |
| `go-build-and-release.yml` | `contents: write`, `packages: write` |
| `sbom-generation.yml` | `contents: write` |

### Example with Explicit Permissions

```yaml
jobs:
  quality-checks:
    permissions:
      contents: read
      pull-requests: write
      security-events: write
    uses: Keyfactor/actions/.github/workflows/pr-quality-checks.yml@v6
```

---

## Configuration

### PR Auto-Labeling

Copy the labeler template to enable auto-labeling:

```bash
cp .github/labeler.yml.template .github/labeler.yml
```

Labels applied:
- `documentation` - `*.md`, `docs/**`
- `dependencies` - `*.csproj`, `go.mod`, `pom.xml`
- `ci/cd` - `.github/**`
- `tests` - Test files
- `bug-fix` - Branch `fix/*`, `bugfix/*`, `hotfix/*`
- `feature` - Branch `feature/*`, `feat/*`

### Signoff Email Notifications

Configure email notifications when PRs are labeled "ready for signoff":

```yaml
# In your keyfactor-starter-workflow.yml
jobs:
  call-starter-workflow:
    uses: Keyfactor/actions/.github/workflows/starter.yml@v6
    with:
      signoff_recipients: 'lead@example.com,team@example.com'
    secrets:
      token: ${{ secrets.V2BUILDTOKEN }}
      smtp_server: ${{ secrets.SMTP_SERVER }}
      smtp_username: ${{ secrets.SMTP_USERNAME }}
      smtp_password: ${{ secrets.SMTP_PASSWORD }}
      email_from: ${{ secrets.EMAIL_FROM }}
      azure_devops_token: ${{ secrets.AZURE_DEVOPS_TOKEN }}  # Optional
```

**Required secrets for signoff notifications:**
- `SMTP_SERVER` - SMTP server hostname
- `SMTP_USERNAME` - SMTP username
- `SMTP_PASSWORD` - SMTP password
- `EMAIL_FROM` - From email address
- `SMTP_PORT` (optional) - Defaults to 587
- `AZURE_DEVOPS_TOKEN` (optional) - For DevOps work item tagging

### Custom PII Patterns

Create `.github/pii-patterns.txt`:

```
customer-specific-pattern
internal-domain\.com
```

### TruffleHog Configuration

TruffleHog is used for secrets scanning with the `--only-verified` flag, which reduces false positives by only reporting secrets that can be verified against their respective APIs.

---

## Migration from v4

### Breaking Changes

1. **Workflow references**: Update `@v4` to `@v6`
2. **Removed workflows**: `assign-env-from-json.yml`, `check-todos-license-headers.yml`, `github-release.yml`
3. **New quality gates**: PRs to release branches require passing checks
4. **PR title format**: Conventional Commits now enforced

### Migration Steps

1. Update workflow reference:
   ```yaml
   # Before
   uses: Keyfactor/actions/.github/workflows/starter.yml@v4

   # After
   uses: Keyfactor/actions/.github/workflows/starter.yml@v6
   ```

2. Add `labeled` to PR event types (for signoff notifications):
   ```yaml
   pull_request:
     types: [opened, closed, synchronize, edited, reopened, labeled]
   ```

3. (Optional) Add labeler config:
   ```bash
   curl -o .github/labeler.yml \
     https://raw.githubusercontent.com/Keyfactor/actions/v6/.github/labeler.yml.template
   ```

4. Update PR titles to Conventional Commits:
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
| `SMTP_SERVER` | Signoff notifications | SMTP server hostname |
| `SMTP_PORT` | Signoff notifications | SMTP server port (optional, default 587) |
| `SMTP_USERNAME` | Signoff notifications | SMTP username |
| `SMTP_PASSWORD` | Signoff notifications | SMTP password |
| `EMAIL_FROM` | Signoff notifications | From email address |
| `AZURE_DEVOPS_TOKEN` | Signoff notifications | Azure DevOps PAT (optional) |
| `SMTP_SERVER` | Signoff emails | SMTP server hostname |
| `SMTP_USERNAME` | Signoff emails | SMTP username |
| `SMTP_PASSWORD` | Signoff emails | SMTP password |
| `EMAIL_FROM` | Signoff emails | Sender email address |
| `AZURE_DEVOPS_PAT` | DevOps tagging | Azure DevOps PAT |

---

## Upstream Action References

v6 uses upstream actions instead of Keyfactor forks for better maintenance:

| Purpose | Action |
|---------|--------|
| Checkout | `actions/checkout@v4` |
| .NET Setup | `actions/setup-dotnet@v4` |
| Go Setup | `actions/setup-go@v5` |
| Java Setup | `actions/setup-java@v4` |
| Node Setup | `actions/setup-node@v4` |
| MSBuild Setup | `microsoft/setup-msbuild@v2` |
| Artifacts | `actions/upload-artifact@v4`, `actions/download-artifact@v4` |
| Caching | `actions/cache@v4` |
| Docker | `docker/build-push-action@v6`, `docker/login-action@v3`, etc. |
| GoReleaser | `goreleaser/goreleaser-action@v6` |
| Helm | `azure/setup-helm@v4`, `helm/chart-releaser-action@v1` |
| GPG | `crazy-max/ghaction-import-gpg@v6` |
| Releases | `softprops/action-gh-release@v2` |
| Linting | `golangci/golangci-lint-action@v6` |
| Secrets | `trufflesecurity/trufflehog@main` |

---

## License

Apache 2.0
