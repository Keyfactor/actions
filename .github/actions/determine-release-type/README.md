# Determine Release Type Action

[![Keyfactor](https://img.shields.io/badge/Keyfactor-purple?logo=github)](https://github.com/Keyfactor/actions)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?logo=github-actions&logoColor=white)](https://github.com/features/actions)

> Determines the release type from pull request context and computes the next semantic version.

| Branding | |
|----------|---|
| Icon | `tag` |
| Color | `purple` |

## Usage

```yaml
- uses: Keyfactor/actions/.github/actions/determine-release-type@v6
```

## Inputs

This action has no inputs. It uses GitHub context variables automatically.

## Outputs

| Output | Description |
|--------|-------------|
| `is_full_release` | `'true'` if this is a full release (PR merged to release branch) |
| `is_pre_release` | `'true'` if this is a pre-release (PR open to release branch) |
| `is_release_branch` | `'true'` if the PR targets a `release-*` branch |
| `base_version` | Version extracted from branch name (e.g., `1.0` from `release-1.0`) |
| `latest_tag` | Most recent git tag matching `v{base_version}.*` |
| `next_version` | Computed next version (e.g., `1.0.0`, `1.0.1-rc.1`) |

## Version Computation Logic

### Release Branch Detection
- Checks if PR base branch matches pattern `release-*`
- Extracts base version from branch name: `release-1.0` → `1.0`

### Tag Discovery
- Finds latest tag matching `v{base_version}.*`
- Examples: `v1.0.0`, `v1.0.1`, `v1.0.2-rc.1`

### Next Version Calculation

| Scenario | Latest Tag | Next Version |
|----------|------------|--------------|
| No existing tags | - | `{base_version}.0` |
| PR merged (full release) | `v1.0.2` | `1.0.3` |
| PR merged (full release) | `v1.0.2-rc.1` | `1.0.3` |
| PR open (pre-release) | `v1.0.2` | `1.0.3-rc.1` |
| PR open (pre-release) | `v1.0.2-rc.1` | `1.0.3-rc.2` |

## Examples

### Basic Usage

```yaml
jobs:
  release:
    runs-on: ubuntu-latest
    outputs:
      version: ${{ steps.release-type.outputs.next_version }}
      is_release: ${{ steps.release-type.outputs.is_full_release }}
    steps:
      - uses: keyfactor/checkout@v4
        with:
          fetch-depth: 0  # Required for tag discovery

      - uses: Keyfactor/actions/.github/actions/determine-release-type@v6
        id: release-type

      - run: |
          echo "Next version: ${{ steps.release-type.outputs.next_version }}"
          echo "Is full release: ${{ steps.release-type.outputs.is_full_release }}"
```

### Conditional Release Build

```yaml
jobs:
  determine:
    runs-on: ubuntu-latest
    outputs:
      is_release_branch: ${{ steps.release-type.outputs.is_release_branch }}
      is_full_release: ${{ steps.release-type.outputs.is_full_release }}
      version: ${{ steps.release-type.outputs.next_version }}
    steps:
      - uses: keyfactor/checkout@v4
        with:
          fetch-depth: 0
      - uses: Keyfactor/actions/.github/actions/determine-release-type@v6
        id: release-type

  build:
    needs: determine
    if: needs.determine.outputs.is_release_branch == 'true'
    runs-on: ubuntu-latest
    steps:
      - uses: keyfactor/checkout@v4
      - run: |
          echo "Building version ${{ needs.determine.outputs.version }}"
          # Build commands here

  publish:
    needs: [determine, build]
    if: needs.determine.outputs.is_full_release == 'true'
    runs-on: ubuntu-latest
    steps:
      - run: echo "Publishing release..."
```

### Create GitHub Release

```yaml
jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: keyfactor/checkout@v4
        with:
          fetch-depth: 0

      - uses: Keyfactor/actions/.github/actions/determine-release-type@v6
        id: release-type

      - name: Create GitHub Release
        if: steps.release-type.outputs.is_full_release == 'true'
        uses: softprops/action-gh-release@v1
        with:
          tag_name: v${{ steps.release-type.outputs.next_version }}
          name: Release ${{ steps.release-type.outputs.next_version }}
          prerelease: false

      - name: Create Pre-Release
        if: steps.release-type.outputs.is_pre_release == 'true'
        uses: softprops/action-gh-release@v1
        with:
          tag_name: v${{ steps.release-type.outputs.next_version }}
          name: Pre-Release ${{ steps.release-type.outputs.next_version }}
          prerelease: true
```

### Version Badge in PR Comment

```yaml
- uses: Keyfactor/actions/.github/actions/determine-release-type@v6
  id: release-type

- name: Comment on PR
  uses: peter-evans/create-or-update-comment@v4
  with:
    issue-number: ${{ github.event.pull_request.number }}
    body: |
      ## Release Information

      | Property | Value |
      |----------|-------|
      | Target Branch | `${{ github.event.pull_request.base.ref }}` |
      | Base Version | `${{ steps.release-type.outputs.base_version }}` |
      | Latest Tag | `${{ steps.release-type.outputs.latest_tag }}` |
      | Next Version | `${{ steps.release-type.outputs.next_version }}` |
      | Release Type | ${{ steps.release-type.outputs.is_full_release == 'true' && 'Full Release' || 'Pre-Release' }} |
```

## Requirements

- Repository must be checked out with `fetch-depth: 0` for tag discovery
- Must run in a `pull_request` event context
- PR must target a `release-*` branch for release detection

## GitHub Context Used

| Context | Purpose |
|---------|---------|
| `github.event.pull_request.base.ref` | Target branch name |
| `github.event.pull_request.merged` | Whether PR was merged |

## Related Actions

- [parse-manifest](../parse-manifest/) - Parse integration-manifest.json
- [check-file-exists](../check-file-exists/) - Check if files exist
