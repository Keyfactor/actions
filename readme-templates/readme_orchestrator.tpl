### The {{ name }} orchestrator is capable of the following capabilities
- [{% if about.orchestrator.supportsCreateStore %}x{% else %} {% endif %}] Test line with dotted notation
- [{% if about.orchestrator['supportsCreateStore'] %}x{% else %} {% endif %}] Test line2 with single-quote
- [about.orchestrator['supportsManagementAdd'] ] Support Management Adds
- [about.orchestrator['supportsManagementRemove']] Support Management Remove
- [{{ about.orchestrator['supportsCreateStore'] }} ] Support Create Store
- [{{ about.orchestrator['supportsDiscovery'] }} ] Support Discovery
- [{{ about.orchestrator['supportsReenrollment'] }} ] Support Reenrollment
