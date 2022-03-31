# {{ name }}

{{ description }}

#### Integration status: {{ shared.integration_status[status] }}

## About the Keyfactor {{ shared.display_names[integration_type] }}

{{ shared.descriptions[integration_type] }}

---
## Test-String
{# the readme_source.md file should be the general README content in markdown form #}
{% include "readme_source.md" %}
{% include "./actions/readme-templates/readme_pam.md" %}