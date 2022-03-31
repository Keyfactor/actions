# {{ name }}

{{ description }}

#### Integration status: {{ shared.integration_status[status] }}

## About the Keyfactor {{ shared.display_names[integration_type] }}

{{ shared.descriptions[integration_type] }}

---
## integration_type = {{ integration_type }}
{# the readme_source.md file should be the general README content in markdown form #}
{% include "readme_source.md" %}
{% if {{ integration_type }} == "pam" %}
	## Additional {{ integration_type }} readme template information should go in here
{% endif %}