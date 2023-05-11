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

It is not necessary to use a PAM Provider for all of the secrets available above. If a PAM Provider should not be used, simply enter in the actual value to be used, as normal.

If a PAM Provider will be used for one of the fields above, start by referencing the [Keyfactor Integration Catalog](https://keyfactor.github.io/integrations-catalog/content/pam). The GitHub repo for the PAM Provider to be used contains important information such as the format of the `json` needed. What follows is an example but does not reflect the `json` values for all PAM Providers as they have different "instance" and "initialization" parameter names and values.

<details><summary>General PAM Provider Configuration</summary>
<p>



### Example PAM Provider Setup

To use a PAM Provider to resolve a field, in this example the __Server Password__ will be resolved by the `Hashicorp-Vault` provider, first install the PAM Provider extension from the [Keyfactor Integration Catalog](https://keyfactor.github.io/integrations-catalog/content/pam) on the Universal Orchestrator.

Next, complete configuration of the PAM Provider on the UO by editing the `manifest.json` of the __PAM Provider__ (e.g. located at extensions/Hashicorp-Vault/manifest.json). The "initialization" parameters need to be entered here:

~~~ json
  "Keyfactor:PAMProviders:Hashicorp-Vault:InitializationInfo": {
    "Host": "http://127.0.0.1:8200",
    "Path": "v1/secret/data",
    "Token": "xxxxxx"
  }
~~~

After these values are entered, the Orchestrator needs to be restarted to pick up the configuration. Now the PAM Provider can be used on other Orchestrator Extensions.

### Use the PAM Provider
With the PAM Provider configured as an extenion on the UO, a `json` object can be passed instead of an actual value to resolve the field with a PAM Provider. Consult the [Keyfactor Integration Catalog](https://keyfactor.github.io/integrations-catalog/content/pam) for the specific format of the `json` object.

To have the __Server Password__ field resolved by the `Hashicorp-Vault` provider, the corresponding `json` object from the `Hashicorp-Vault` extension needs to be copied and filed in with the correct information:

~~~ json
{"Secret":"my-kv-secret","Key":"myServerPassword"}
~~~

This text would be entered in as the value for the __Server Password__, instead of entering in the actual password. The Orchestrator will attempt to use the PAM Provider to retrieve the __Server Password__. If PAM should not be used, just directly enter in the value for the field.
</p>
</details> 
{% endif %}
