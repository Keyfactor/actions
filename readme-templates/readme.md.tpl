# {{ name }}

{{ description }}

## About the Keyfactor {{ shared.display_names[integration_type] }}

### Integration status: {{ shared.integration_status[status] }}

{{ shared.descriptions[integration_type] }}

---
{# the readme_source.md file should be the general README content in markdown form #}
{% include "readme_source.md" %}
