### 👨🏿‍🚀 Actions v6 Workflows

### What's new in v6

The monolithic `starter.yml` has been split into three focused, self-contained entry points and a
small set of shared building blocks:

| Entry point | For |
|-------------|-----|
| [`starter-dotnet.yml`](.github/workflows/starter-dotnet.yml) | .NET integrations (build, sign, package, release) |
| [`starter-golang.yml`](.github/workflows/starter-golang.yml) | Go integrations (GoReleaser) |
| [`starter-helm.yml`](.github/workflows/starter-helm.yml) | Container + Helm chart integrations |

Each entry point composes four reusable building blocks:

* [`version.yml`](.github/workflows/version.yml) — pure, side-effect-free computation of the
  release/pre-release version and branch flags. **Never** creates a release or tag.
* [`compliance.yml`](.github/workflows/compliance.yml) — one-shot pre-release gate: Apache license
  headers, TODO report, and the Polaris (Black Duck) SCA/SAST scan.
* [`lifecycle.yml`](.github/workflows/lifecycle.yml) — repo housekeeping (README via doctool,
  integrations-catalog update, release-branch configuration, and the post-release PR to `main`),
  each job self-gated on the triggering event.
* [`publish-release.yml`](.github/workflows/publish-release.yml) — creates the GitHub release **and**
  attaches build artifacts atomically.

#### Key behavioral change

Publishing (an RC on an open PR, or the full release on merge) now **depends on** the build and
compliance jobs succeeding. A release can no longer be created before the checks that protect it
have passed. RCs continue to publish on every open PR to a `release-*.*` branch, exactly as before —
they just publish *after* the build and compliance run rather than ahead of it.

### Usage

#### Prerequisites

- Ensure an `integration-manifest.json` file is present in the root of your repository. For the
  schema, see the v2
  [integration-manifest-schema.json](https://keyfactor.github.io/v2/integration-manifest-schema.json).
  The .NET build reads `release_dir` and `release_project` from it directly; the catalog update reads
  `update_catalog`; the Helm build reads `platform_matrix`.

#### Example `integration-manifest.json`

```json
{
  "$schema": "https://keyfactor.github.io/v2/integration-manifest-schema.json",
  "integration_type": "anyca-plugin",
  "name": "Example AnyCA REST Gateway Plugin",
  "status": "pilot",
  "support_level": "kf-supported",
  "link_github": true,
  "update_catalog": true,
  "description": "Example Plugin for the AnyCA REST Gateway framework",
  "gateway_framework": "25.0.0",
  "release_dir": "example-caplugin\\bin\\Release",
  "release_project": "example-caplugin\\example_extension.csproj"
}
```

#### Example bootstrap workflow (`.github/workflows/keyfactor-bootstrap-workflow.yml`)

Call the entry point matching your project. For a .NET integration:

```yaml
name: Keyfactor Bootstrap Workflow

on:
  workflow_dispatch:
  pull_request:
    types: [ opened, closed, synchronize, edited, reopened ]
  push:
  create:
    branches:
      - 'release-*.*'

jobs:
  call-starter-workflow:
    uses: keyfactor/actions/.github/workflows/starter-dotnet.yml@v6
    secrets:
      scan_token: ${{ secrets.SAST_TOKEN }}      # Optional — Polaris scan (skipped if absent)
      # signing_cert: ${{ secrets.SIGNING_CERT }}  # Reserved — code signing is not yet wired
      # signing_pass: ${{ secrets.SIGNING_PASS }}
```

For Go, call `starter-golang.yml@v6` and additionally pass `gpg_key` / `gpg_pass`. For
container/Helm, call `starter-helm.yml@v6` and pass `docker_user` / `docker_token`.

**No PAT.** These workflows use the implicit `GITHUB_TOKEN` for everything they can — NuGet restore
(`packages: read`; the Keyfactor packages must grant Actions access to the integration repo),
release publishing, GoReleaser, image push, and the post-release PR. There is no `token` secret.

> ⚠️ The cross-repo / org-admin lifecycle jobs **cannot** run on `GITHUB_TOKEN` and are retained as
> placeholders that will fail until their structural replacements land: **doctool** README generation
> (reads the private `keyfactor/doctooldotnet` repo), the **catalog** update (writes another repo —
> being moved to a pull-model workflow in the catalog repo), and **configure-repo/branch** (topics,
> description, teams, branch protection require org admin scopes `GITHUB_TOKEN` does not have). See
> the per-job notes in [lifecycle.yml](.github/workflows/lifecycle.yml).

#### Secrets

| Secret        | Used by                       | Required/Optional                       |
|---------------|-------------------------------|-----------------------------------------|
| scan_token    | all (compliance / Polaris)    | Optional (scan skipped if absent)       |
| gpg_key       | golang                        | Required for Go                         |
| gpg_pass      | golang                        | Required for Go                         |
| docker_user   | helm                          | Optional (image push)                   |
| docker_token  | helm                          | Optional (image push)                   |
| signing_cert  | dotnet                        | Reserved — signing not yet wired        |
| signing_pass  | dotnet                        | Reserved — signing not yet wired        |

### Behavior by event

#### On `create` of a `release-*.*` branch
Configure repository settings — topics and description from the manifest, team permissions, and
branch protection ([`lifecycle.yml`](.github/workflows/lifecycle.yml) `configure-*` jobs).

#### On `push` (non-`main`) or `workflow_dispatch`
Build and run compliance as validation; regenerate `README.md` via doctool. No release is published.

#### On `push` to `main`
If `"update_catalog": true`, create/update the integrations-catalog entry.

#### On `pull_request` to a `release-*.*` branch
* **Open / synchronize:** build → compliance → publish a `-rc.N` **prerelease** (unsigned for now).
* **Merged / closed:** build → compliance → **signing stage** (dotnet, full release only) → publish
  the final release, then open an automated PR back to `main` (approve manually).

`main` is a placeholder that records the most-recently-released version. The post-release job will
**not** open a PR that moves `main` backwards (e.g. merging `1.2.3` when `main` already records
`1.3.4`) — it compares the release against the highest release tag reachable from `main`. To merge an
intentional older-line hotfix to `main` anyway, add the `allow-backtrack` label to the release PR.

### Supply chain

Third-party actions are pinned to full commit SHAs with `# vX.Y.Z` comments. The only retained
`keyfactor/*` references are first-party actions (`action-assign-topics`, `action-update-description`,
`action-gh-teams-update`, `action-set-branch-protection`, `doctooldotnet`) plus two documented
exceptions that diverge from upstream: `keyfactor/action-bump-semver` (adds a `preID` input) and
`Keyfactor/jinja2-action` (custom multi-data-file support).

### 📝 Todo

* Wire up the .NET binary signing stage (`signing_cert` / `signing_pass`) in
  [`starter-dotnet.yml`](.github/workflows/starter-dotnet.yml).
* Upstream-or-replace the forked actions still used by the self-hosted
  [`keyfactor-sign-files.yml`](.github/workflows/keyfactor-sign-files.yml)
  (`find-latest-tag`, `release-downloader`, `release-action`).
* Remove default admin user when applying branch protection.
* Set repo license.

---
