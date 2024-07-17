### 👨🏿‍🚀 Actions v3 Workflows 

### What's new in v3
* The v3 Actions make use of [doctool](https://github.com/Keyfactor/doctool)
* Polaris SAST/SCA scans run on push to release and main branches
* All actions are being migrated to forks in the keyfactor org for security hardening purposes. AB#55122
  * Access to 3rd party actions will be restrcited in the keyfactor org
  * The keyfactor-action-staging organization can be used for developing workflows that will need to be transferred to the keyfactor org before making it public
* Post-release workflow added: Auto-create PR from release branch to main
    * Additional jobs/actions may be added to the kf-post-release.yml workflow in this repository (.github/workflows folder)

These workflows are designed to work with the latest [keyfactor-bootstrap-workflow.yml "Keyfactor Bootstrap v3 Workflow"](https://github.com/Keyfactor/.github/blob/main/workflow-templates/keyfactor-bootstrap-workflow-v3.yml)

### 🚀The Bootstrap workflow for v3 Actions perform the following steps: 

* Checkout integration repository
* Get values from integration-manifest.json [***assign-env-from-json***]
* Discover primary programming language from the repository [***action-get-primary-language***]
* Determine event_name: create, push, pull_request, workflow_dispatch [***github-release]***
* Run the workflows and conditionalized steps to produce a build. If conditions match, release artifacts are delivered [***dotnet-build-and-release | go-build-and-release***]

#### On Create:
* Configure repository settings - This will use the properties from the json to update topic and description, and will set the teams permissions on the repo accordingly. If the ref created is a branch that matches "release-\*.\*", branch protection is added, autlink reference set ab# to devops [***kf-configure-repo***]

#### On push or workflow_dispatch:
* Just run the build on the branch with the commit without producing release artifacts
* * C#: run the dotnet-build-and-release.yml workflow
* * Go builds: run the go-build-and-release.yml workflow (still in progress)
* All languages: Generate a readme using doctool and (conditionally) a catalog entry [***generate-readme, update-catalog***]

#### On pull_request[opened, closed, synchronize, edited, reopened]:
[***dotnet-build-and-release | go-build-and-release***]
* If the pr destination is a release-*.* branch, set flags to produce release artifacts 
* If the pr is determined to be open or merged but not closed (synchronize), a prerelease artifact will be uploaded
* If the pr is determined to be merged and closed, a final release is built
*  Polaris SAST/SCAN scans run when push to release-* or main occurs
* If PR to release branch is merged/closed, a new PR will be automatically generated. This will need to be approved manually and **should not** be approved for hotfix branches 






### 📝Todo: 
* Remove default admin user when applying branch protection
* Add overrides for detected language, readme build(?), etc. into json manifest
* Set repo license

---
