# {{ name }}

{{ description }}

#### Integration status: {{ shared.integration_status[status] }}

## About the Keyfactor {{ shared.display_names[integration_type] }}

{{ shared.descriptions[integration_type] }}

---
{# the readme_source.md file should be the general README content in markdown form #}
{% include "readme_source.md" %}

{# Additional {{ integration_type }} readme template includes will go in this next section #}
{% if integration_type == "pam" %}
{% include "./actions/readme-templates/readme_pam.tpl" ignore missing %}
{% endif %}
{% if integration_type == "orchestrator" %}
{% include "./actions/readme-templates/readme_orchestrator.tpl" ignore missing %}
{% endif %}
