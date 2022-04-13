### The {{ name }} orchestrator is capable of the following capabilities
- [{% if about.orchestrator[supportsCreateStore] == true %}x{% else %} {% endif %}] Test line
- [{{ about.orchestrator[supportsManagementAdd] }} ] Support Management Adds
- [{{ about.orchestrator[supportsManagementRemove] }} ] Support Management Remove
- [{{ about.orchestrator[supportsCreateStore] }} ] Support Create Store
- [{{ about.orchestrator[supportsDiscovery] }} ] Support Discovery
- [{{ about.orchestrator[supportsReenrollment] }} ] Support Reenrollment
