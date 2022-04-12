# {{ name }}

{{ description }}

#### Integration status: {{ shared.integration_status[status] }}

## About the Keyfactor {{ shared.display_names[integration_type] }}

{{ shared.descriptions[integration_type] }}

---
## integration_type = {{ integration_type }}
{# the readme_source.md file should be the general README content in markdown form #}
{% include "readme_source.md" %}
{# This section does not evaluate correctly #}
{% if integration_type == "pam" %}
	## Additional {{ integration_type }} readme template information should go in here
	{% include "./actions/readme-templates/readme_pam2.md" ignore missing %}
	{% include "./actions/readme-templates/readme_pam.md" ignore missing %}
{% endif %}
{% if integration_type == "orchestrator" %}
	## Additional {{ integration_type }} readme template information should go in here
	{% include "./actions/readme-templates/readme_orchestrator.md" ignore missing %}
{% endif %}
{% if true %}
	## Fallback true assersion. integration_type = "{{ integration_type }}"
{% endif %}