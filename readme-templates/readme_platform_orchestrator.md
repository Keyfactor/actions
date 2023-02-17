{% if about.orchestrator.UOFramework is defined %}
## Keyfactor Version Supported

The minimum version of the Keyfactor Universal Orchestrator Framework needed to run this version of the extension is {{ about.orchestrator.UOFramework }}
{% endif %}
## Platform Specific Notes

The Keyfactor Universal Orchestrator may be installed on either Windows or Linux based platforms. The certificate operations supported by a capability may vary based what platform the capability is installed on. The table below indicates what capabilities are supported based on which platform the encompassing Universal Orchestrator is running.
| Operation | Win | Linux |
|-----|-----|------|
|Supports Management Add|{% if about.orchestrator.win.supportsManagementAdd %}&check;{% else %} {% endif %} |{% if about.orchestrator.linux.supportsManagementAdd %}&check;{% else %} {% endif %} |
|Supports Management Remove|{% if about.orchestrator.win.supportsManagementRemove %}&check;{% else %} {% endif %} |{% if about.orchestrator.linux.supportsManagementRemove %}&check;{% else %} {% endif %} |
|Supports Create Store|{% if about.orchestrator.win.supportsCreateStore %}&check;{% else %} {% endif %} |{% if about.orchestrator.linux.supportsCreateStore %}&check;{% else %} {% endif %} |
|Supports Discovery|{% if about.orchestrator.win.supportsDiscovery %}&check;{% else %} {% endif %} |{% if about.orchestrator.linux.supportsDiscovery %}&check;{% else %} {% endif %} |
|Supports Renrollment|{% if about.orchestrator.win.supportsReenrollment %}&check;{% else %} {% endif %} |{% if about.orchestrator.linux.supportsReenrollment %}&check;{% else %} {% endif %} |
|Supports Inventory|{% if about.orchestrator.win.supportsInventory %}&check;{% else %} {% endif %} |{% if about.orchestrator.linux.supportsInventory %}&check;{% else %} {% endif %} |

{% if about.orchestrator.pam_support %}
## PAM Integration

This orchestrator extension has the ability to connect to a variety of supported PAM providers to allow for the retrieval of various client hosted secrets right from the orchestrator server itself.  This eliminates the need to set up the PAM integration on Keyfactor Command which may be in an environment that the client does not want to have access to their PAM provider.

The secrets that this orchestrator extension supports for use with a PAM Provider are:

{% include "./readme-src/readme-pam-support.md" %}

It is not necessary to implement all of the secrets available to be managed by a PAM provider.  For each value that you want managed by a PAM provider, simply enter the key value inside your specific PAM provider that will hold this value into the corresponding field when setting up the certificate store, discovery job, or API call.

Setting up a PAM provider for use involves adding an additional section to the manifest.json file for this extension as well as setting up the PAM provider you will be using.  Each of these steps is specific to the PAM provider you will use and are documented in the specific GitHub repo for that provider.  For a list of Keyfactor supported PAM providers, please reference the [Keyfactor Integration Catalog](https://keyfactor.github.io/integrations-catalog/content/pam).


### Register the PAM Provider

A PAM Provider needs to be registered on the Universal Orchestrator in the same way other extensions are. Create a folder for the specific PAM Provider to be added, and place the contents of the PAM Provider into the folder. There needs to be a manifest.json with the PAM Provider.

After a manifest.json is added, the final step for configuration is setting the "provider-level" parameters for the PAM Provider. These are also known as the "initialization-level" parameters. These need to be placed in a json file that gets loaded by the Orchestrator by default. 

example manifest.json for MY-PROVIDER-NAME
```
{
    "extensions": {
        "Keyfactor.Platform.Extensions.IPAMProvider": {
            "PAMProviders.MY-PROVIDER-NAME.PAMProvider": {
                "assemblyPath": "my-pam-provider.dll",
                "TypeFullName": "Keyfactor.Extensions.Pam.MyPamProviderClass"
            }
        }
    },
    "Keyfactor:PAMProviders:MY-PROVIDER-NAME:InitializationInfo": {
        "InitParam1": "InitValue1",
        "InitParam2": "InitValue2"
    }
}
```

{% endif %}
