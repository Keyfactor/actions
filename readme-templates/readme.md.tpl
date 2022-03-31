# {{ name }}

{{ description }}

#### Integration status: {{ shared.integration_status[status] }}

## About the Keyfactor {{ shared.display_names[integration_type] }}

{{ shared.descriptions[integration_type] }}

---
## integration_type = {{ integration_type }} <!-- This correctly prints integration_type = pam -->
{# the readme_source.md file should be the general README content in markdown form #}
{% include "readme_source.md" %}
<!-- {% if {{ integration_type }} == "pam" %}  ## This does not work -->
	{% if "pam" == "pam" %} <!-- This works -->
	{% if { integration_type } == "pam" %} <!-- Fail -->
	{% if integration_type == "pam" %}
	## Additional {{ integration_type }} readme template information should go in here <!-- Variable substitution works in this instamce -->
{% endif %}