# {{ name }}

{{ description }}

#### Integration status: {{ shared.integration_status[status] }}

{% if ((integration_type == "ca-gateway") or (integration_type == "orchestrator") or (integration_type == "pam") or (integration_type == "terraform-provider") and (about is defined)) %}
## About the Keyfactor {{ shared.display_names[integration_type] }}

{{ shared.descriptions[integration_type] }}
{% endif %}

{% if (support_level is defined) %}

## Support for {{ name }}

{{ name }} {{ shared.support_statement[support_level] }}

###### To report a problem or suggest a new feature, use the **[Issues](../../issues)** tab. If you want to contribute actual bug fixes or proposed enhancements, use the **[Pull requests](../../pulls)** tab.
{% endif %}

{% if ((integration_type == "ca-gateway") or (integration_type == "orchestrator") or (integration_type == "pam") or (integration_type == "terraform-provider") and (about is defined)) %}
---

{# Additional {{ integration_type }} platform template includes will go in this next section #}
{% if (integration_type == "orchestrator") and (about is defined) %}
{% include "./actions/readme-templates/readme_platform_orchestrator.md" ignore missing %}
{% endif %}
{% if (integration_type == "pam") and (about is defined) %}
{% include "./actions/readme-templates/readme_platform_pam.md" ignore missing %}
{% endif %}
{% if (integration_type == "ca-gateway") %}
{% include "./actions/readme-templates/readme_platform_cagateway.md" ignore missing %}
{% endif %}
---
{% endif %}
{# the readme_source.md file should be the general README content in markdown form #}
{% include "readme_source.md" %}

