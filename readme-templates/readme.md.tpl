# {{ name }}

{{ description }}

#### Integration status: {{ shared.integration_status[status] }}

## About the Keyfactor {{ shared.display_names[integration_type] }}

{{ shared.descriptions[integration_type] }}

{% if ((integration_type == "orchestrator") or (integration_type == "pam") and (about is defined)) %}
---

{# Additional {{ integration_type }} platform template includes will go in this next section #}
{% if (integration_type == "orchestrator") and (about is defined) %}
{% include "./actions/readme-templates/readme_platform_orchestrator.md" ignore missing %}
{% endif %}
{% if (integration_type == "pam") and (about is defined) %}
{% include "./actions/readme-templates/readme_platform_pam.md" ignore missing %}
{% endif %}
---
{% endif %}
{# the readme_source.md file should be the general README content in markdown form #}
{% include "readme_source.md" %}

