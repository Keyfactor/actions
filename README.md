### 👨🏿‍🚀 Actions v4 Workflows

### What's new in v4

* The v4 Actions make use of [doctool](https://github.com/Keyfactor/doctool) to take Command screenshots for Universal
  Orchestrator extension store-type creation.

### Usage

#### Prerequisites

- Ensure an `integration-manifest.json` file is present in the root of your repository. For the schema, see the
  v2 [integration-manifest-schema.json](https://keyfactor.github.io/v2/integration-manifest-schema.json)

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
  "release_project": "example-caplugin\\example_extension.csproj",
  "about": {
    "carest": {
      "ca_plugin_config": [
        {
          "name": "ApiKey",
          "description": "The API Key for the The CA API"
        },
        {
          "name": "Username",
          "description": "Username for the CA API service account"
        },
        {
          "name": "Password",
          "description": "Password for the CA API service account"
        },
        {
          "name": "BaseUrl",
          "description": "The Base URL for the CA API"
        },
        {
          "name": "Enabled",
          "description": "Flag to Enable or Disable gateway functionality. Disabling is primarily used to allow creation of the CA prior to configuration information being available."
        }
      ],
      "enrollment_config": [
        {
          "name": "CertificateValidityInYears",
          "description": "Number of years the certificate will be valid for"
        },
        {
          "name": "Email",
          "description": "Email address of the requestor"
        },
        {
          "name": "OrganizationName",
          "description": "Name of the organization to be validated against"
        }
      ],
      "product_ids": [
        "ExampleProductSslOvBasic",
        "ExampleProductSslEvBasic",
        "ExampleProductSslDvGeotrust",
        "ExampleProductSslDvThawte",
        "ExampleProductSslOvThawteWebserver",
        "ExampleProductSslEvThawteWebserver",
        "ExampleProductSslOvGeotrustTruebizid",
        "ExampleProductSslEvGeotrustTruebizid",
        "ExampleProductSslOvSecuresite",
        "ExampleProductSslEvSecuresite",
        "ExampleProductSslOvSecuresitePro",
        "ExampleProductSslEvSecuresitePro"
      ]
    }
  }
}
```

#### Example workflow `keyfactor-bootsrap-workflow.yml`

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
    uses: keyfactor/actions/.github/workflows/starter.yml@v4
    with:
      command_token_url: ${{ vars.COMMAND_TOKEN_URL }} # Only required for doctool generated screenshots
      command_hostname: ${{ vars.COMMAND_HOSTNAME }} # Only required for doctool generated screenshots
      command_base_api_path: ${{ vars.COMMAND_API_PATH }} # Only required for doctool generated screenshots
    secrets:
      token: ${{ secrets.V2BUILDTOKEN}} # REQUIRED
      gpg_key: ${{ secrets.KF_GPG_PRIVATE_KEY }} # Only required for golang builds
      gpg_pass: ${{ secrets.KF_GPG_PASSPHRASE }} # Only required for golang builds
      scan_token: ${{ secrets.SAST_TOKEN }} # REQUIRED
      entra_username: ${{ secrets.DOCTOOL_ENTRA_USERNAME }} # Only required for doctool generated screenshots
      entra_password: ${{ secrets.DOCTOOL_ENTRA_PASSWD }} # Only required for doctool generated screenshots
      command_client_id: ${{ secrets.COMMAND_CLIENT_ID }} # Only required for doctool generated screenshots
      command_client_secret: ${{ secrets.COMMAND_CLIENT_SECRET }} # Only required for doctool generated screenshots

```

#### Inputs

| Parameter             | Type   | Description                                                    | Required/Optional              |
|-----------------------|--------|----------------------------------------------------------------|--------------------------------|
| command_token_url     | Input  | URL for command token, used by doctool for screenshots         | Optional (doctool screenshots) |
| command_hostname      | Input  | Hostname for command, used by doctool for screenshots          | Optional (doctool screenshots) |
| command_base_api_path | Input  | Base API path for command, used by doctool for screenshots     | Optional (doctool screenshots) |
| token                 | Secret | Build token for workflow execution                             | Required                       |
| gpg_key               | Secret | GPG private key for signing golang builds                      | Optional (golang builds)       |
| gpg_pass              | Secret | GPG passphrase for signing golang builds                       | Optional (golang builds)       |
| scan_token            | Secret | Token for SAST/Polaris scan                                    | Required                       |
| entra_username        | Secret | Username for doctool Entra authentication (screenshots)        | Optional (doctool screenshots) |
| entra_password        | Secret | Password for doctool Entra authentication (screenshots)        | Optional (doctool screenshots) |
| command_client_id     | Secret | Client ID for command API, used by doctool for screenshots     | Optional (doctool screenshots) |
| command_client_secret | Secret | Client secret for command API, used by doctool for screenshots | Optional (doctool screenshots) |

### 🚀The Bootstrap workflow for v4 Actions perform the following steps:

* Checkout integration repository
* Call [starter.yml](.github/workflows/starter.yml) workflow
* Get values from integration-manifest.json [assign-env-from-json](.github/workflows/assign-env-from-json.yml)
* Discover primary programming language from the repository [***action-get-primary-language***]
* Determine event_name:
  `create, push, pull_request, workflow_dispatch` [github-release.yml](.github/workflows/github-release.yml)
* Run the workflows and conditionalized steps to produce a build. If conditions match, release artifacts are delivered
  [dotnet-build-and-release.yml](.github/workflows/dotnet-build-and-release.yml)
  or [go-build-and-release.yml](.github/workflows/go-build-and-release.yml)
  workflow will be run depending on the `detected-primary-language` step in [starter.yml](.github/workflows/starter.yml)

#### On Create:

* Configure repository settings - This will use the properties from the json to update topic and description, and will
  set the teams permissions on the repo accordingly. If the ref created is a branch that matches "release-\*.\*", branch
  protection is added, autlink reference set ab# to devops [***kf-configure-repo***]

#### On push or workflow_dispatch:

* Just run the build on the branch with the commit without producing release artifacts
*
    * C#: run the [dotnet-build-and-release.yml](.github/workflows/dotnet-build-and-release.yml) workflow
*
    * Go builds: run the go-build-and-release.yml workflow (still in progress)
* All languages:
*
    * Generate/Update `README.md` using `doctool` [generate-readme.yml](.github/workflows/generate-readme.yml)
*
    * (conditionally) a catalog entry [update-catalog](.github/workflows/update-catalog.yml) will be created/updated if
      the json manifest has `"update_catalog": true` in the `integration-manifest.json` file

#### On pull_request[opened, closed, synchronize, edited, reopened]:

[dotnet-build-and-release.yml](.github/workflows/dotnet-build-and-release.yml) workflow
or [go-build-and-release.yml](.github/workflows/go-build-and-release.yml) workflow will be run depending on the detected
primary language

* If the pr destination is a `release-*.*` branch, set flags to produce release artifacts
* If the pr is determined to be `open` or `merged` but not `closed` (synchronize), a prerelease artifact will be
  uploaded
* If the pr is determined to be `merged` and `closed`, a final "official" release is built and published to GitHub
  releases, and if `"update_catalog": true` is set in the json manifest, a catalog entry will be created/updated
* Polaris SAST/SCAN scans run when push to `release-*` or main occurs
* If PR to release branch is `merged/closed`, a new PR will be automatically generated. This will need to be approved
  manually and **should not** be approved for hotfix branches

### 📝Todo:

* Remove default admin user when applying branch protection
* Add overrides for detected language, readme build(?), etc. into json manifest
* Set repo license

---
