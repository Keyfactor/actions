### The following workflows are available through the actions repository

### Note: if reading a json file for properties, you must first checkout the repo using actions/checkout@v3 first

## assign-env-from-json.yml
* Create a variable for use in a workflow from a property set in a json file. This utilizes the action fiddlermikey/assign-from-json
```
    - name: Assign variable
       uses: fiddlermikey/assign-from-json@v1.0
        id: read-name
        with:
          input-file: 'src/integration-manifest.json'
          input-property: 'name'

```
The output property will be available as:
```
steps.read-name.outputs.output-value
```
---
## update-store-types.yml

This workflow contains two functions. One is to update the store_types.json in kfutil, and the second part creates the markdown stub to be included in the repository readme file.

Add this through your repo action tab. Select New Workflow and then select the 'Keyfactor Merge Cert Store Types' reusable workflow. No additional configuration is necessary. Simple select the workflow and run it manually.

---
## Configuration workflows

The following workflows will assist in creating the default repository settings for topic, team access, and description. 

* kf-update-description.yml
* kf-update-teams.yml
* kf-update-topics.yml

### Todo: 
* Add Branch protection and autolinking
* Create workflow template
* Add configuration options to json properties
* Create reusable workflow in .github repo
---
## The original build workflows

* update-catalog.yml
* generate-readme.yml
* dotnet-build-and-release.yml
* github-release.yml
