### 👨🏿‍🚀 Actions v2 Workflows 

These workflows are designed to work with the latest [keyfactor-bootstrap-workflow.yml "Keyfactor Bootstrap Workflow"](https://github.com/Keyfactor/.github/blob/main/workflow-templates/keyfactor-bootstrap-workflow.yml)
This *bootstrap workflow* passes 2 secrets to the starter.yml workflow. If you are testing or developing from a forked copy of this repository, but sure to set the secrets:

* V2BUILDTOKEN: This is required for all builds and must have full repo scope, and package:read permissions
* APPROVE_README_PUSH: full repo scope

The following are used for go lang builds and are set at the organization level. If you test or develop for a fork, you will need to add secrets to our local forked repository with the following definitions:
* gpg_key: This is a private gpg key stored as a secret
* gpg_pass: This is th private gpg passphrase stored as a secret

### 🚀The Bootstrap workflow for v2 Actions perform the following steps: 

* Checkout integration repository
* Get values from integration-manifest.json [***assign-env-from-json***]
* Discover primary programming language from the repository [***action-get-primary-language***]
* Determine event_name: create, push, pull_request, workflow_dispatch [***github-release]***
* Run the workflows and conditionalized steps to produce a build. If conditions match, release artifacts are delivered [***dotnet-build-and-release | go-build-and-release***]

### On Create:
* Configure repository settings - This will use the properties from the json to update topic and description, and will set the teams permissions on the repo accordingly. If the ref created is a branch that matches "release-*.*", branch protection is added [***kf-configure-repo***]

### On push or workflow_dispatch:
* Just run the build on the branch with the commit without producing release artifacts
* * C#: run the dotnet-build-and-release.yml workflow
* * Go builds: run the go-build-and-release.yml workflow (still in progress)
* All languages: Generate a readme and (conditionally) a catalog entry [***generate-readme, update-catalog***]

### On pull_request[opened, closed, synchronize, edited, reopened]:
[***dotnet-build-and-release | go-build-and-release***]
* If the pr destination is a release-*.* branch, set flags to produce release artifacts 
* If the pr is determined to be open or merged but not closed (synchronize), a prerelease artifact will be uploaded
* If the pr is determined to be merged and closed, a final release is built






### 📝Todo: 
* Add autolinking
* Remove default admin user when applying branch protection

---
