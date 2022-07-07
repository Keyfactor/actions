# {{ name }}

{{ description }}

#### Integration status: {{ shared.integration_status[status] }}

## About the Keyfactor {{ shared.display_names[integration_type] }}

{{ shared.descriptions[integration_type] }}

---
{{ name }} {{ shared.support_statement[support_level] }}

To report a problem or suggest a new feature, use the **[Issues](../../issues)** tab. If you want to contribute actual bug fixes or proposed enhancements, use the **[Pull requests](../../pulls)** tab.
___
{# Additional {{ integration_type }} platform template includes will go in this next section #}
{% if (integration_type == "orchestrator") and (about is defined) %}
{% include "./actions/readme-templates/readme_platform_orchestrator.md" ignore missing %}
{% endif %}
{% if (integration_type == "pam") and (pamRegDLL is defined) %}
{% include "./actions/readme-templates/readme_platform_pam.md" ignore missing %}
{% endif %}
---
{# the readme_source.md file should be the general README content in markdown form #}
{% include "readme_source.md" %}

