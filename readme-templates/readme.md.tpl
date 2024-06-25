{% if (integration_type != "ejbca") and (integration_type != "signserver") %}
{# Boilerplate section #}
# {{ name }}

{{ description }}

#### Integration status: {{ shared.integration_status[status] }}

## About the Keyfactor {{ shared.display_names[integration_type] }}

{{ shared.descriptions[integration_type] }}
{% if ((integration_type == "ca-gateway") or (integration_type == "anyca-gateway") or (integration_type == "orchestrator") or (integration_type == "pam") or (integration_type == "terraform-provider")) %}

## Support for {{ name }}

{{ name }}{% endif %} {{ shared.support_statement[support_level] }}

###### To report a problem or suggest a new feature, use the **[Issues](../../issues)** tab. If you want to contribute actual bug fixes or proposed enhancements, use the **[Pull requests](../../pulls)** tab.
{# End of Boilerplate section #}
---
{# Important information can go in the readme-pre.md to appear near the top of the document #}
{% include "./readme-src/readme-pre.md" ignore missing %}
---
{# Additional {{ integration_type }} platform template includes will go in this next section #}
{% if ((integration_type == "ca-gateway") or (integration_type == "anyca-gateway") or (integration_type == "orchestrator") or (integration_type == "pam") or (integration_type == "terraform-provider")) %}
{% if (integration_type == "orchestrator") %}
{% include "./actions/readme-templates/readme_platform_orchestrator.md" %}
{% endif %}
{% if (integration_type == "pam") and (about is defined) %}
{% include "./actions/readme-templates/readme_platform_pam.md" %}
{% endif %}
{% if ((integration_type == "ca-gateway") or (integration_type == "anyca-gateway")) %}
{% include "./actions/readme-templates/readme_platform_cagateway.md" %}
{% endif %}
---
{% endif %}
{% endif %}
{# the readme_source.md file should be the general README content in markdown form #}
{% include "readme_source.md" %}
{% if (integration_type == "orchestrator") %}
When creating cert store type manually, that store property names and entry parameter names are case sensitive
{% endif %}

