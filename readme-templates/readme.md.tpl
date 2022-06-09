# {{ name }}

{{ description }}

#### Integration status: {{ shared.integration_status[status] }}

## About the Keyfactor {{ shared.display_names[integration_type] }}

{{ shared.descriptions[integration_type] }}

---

{# Additional {{ integration_type }} platform template includes will go in this next section #}
{% if integration_type == "orchestrator" %}
{% include "./actions/readme-templates/readme_platform_orchestrator.tpl" ignore missing %}
{% endif %}
---
{# the readme_source.md file should be the general README content in markdown form #}
{% include "readme_source.md" %}

