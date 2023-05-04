{% include "./readme-src/readme-pre.md" ignore missing %}

### Initial Configuration of PAM Provider
In order to allow Keyfactor to use the new {{ name }}, the definition needs to be added to the application database.
This is done by running the provided `kfutil` tool to install the PAM definition, which only needs to be done one time. It uses API credentials to access the Keyfactor instance and create the PAM definition.

The `kfutil` tool, after being [configured for API access](https://github.com/Keyfactor/kfutil#quickstart), can be run in the following manner to install the PAM definition from the Keyfactor repository:

```
kfutil pam types-create -r {{ about.pam.assemblyName }} -n {{ about.pam.dbName }}
```

### Configuring Parameters
The following are the parameter names and a description of the values needed to configure the {{ name }}.

{% include "./readme-src/readme-paramtable.md" %}

![](images/config.png)

{% include "./readme-src/readme-config.md" %}

#### In Keyfactor - PAM Provider
##### Installation
In order to setup a new PAM Provider in the Keyfactor Platform for the first time, you will need to run the `kfutil` tool (see Initial Configuration of PAM Provider).

After the installation is run, the DLLs need to be installed to the correct location for the PAM Provider to function. From the release, the {{ about.pam.assemblyName }}.dll should be copied to the following folder locations in the Keyfactor installation. Once the DLL has been copied to these folders, edit the corresponding config file. You will need to add a new Unity entry as follows under `<container>`, next to other `<register>` tags.

| Install Location | DLL Binary Folder | Config File |
| --- | --- | --- |
| WebAgentServices | WebAgentServices\bin\ | WebAgentServices\web.config |
| Service | Service\ | Service\CMSTimerService.exe.config |
| KeyfactorAPI | KeyfactorAPI\bin\ | KeyfactorAPI\web.config |
| WebConsole | WebConsole\bin\ | WebConsole\web.config |

When enabling a PAM provider for Orchestrators only, the first line for `WebAgentServices` is the only installation needed.

The Keyfactor service and IIS Server should be restarted after making these changes.

```xml
<register type="IPAMProvider" mapTo="{{ about.pam.fullyQualifiedClassName }}, {{ about.pam.assemblyName }}" name="{{ about.pam.dbName }}" />
```


{% include "./readme-src/readme-register.md" ignore missing %}

##### Usage
In order to use the PAM Provider, the provider's configuration must be set in the Keyfactor Platform. In the settings menu (upper right cog) you can select the ___Priviledged Access Management___ option to configure your provider instance.

![](images/setting.png)

After it is set up, you can now use your PAM Provider when configuring certificate stores. Any field that is treated as a Keyfactor secret, such as server passwords and certificate store passwords can be retrieved from your PAM Provider instead of being entered in directly as a secret.

![](images/password.png)
