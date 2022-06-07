### The {{ name }} orchestrator is has the following capabilities
Capability | Windows | Linux
------------ |------------ | -------------
 Supports Management Add | - [{% if about.orchestrator.supportsManagementAddWin %}x{% else %} {% endif %}] | - [{% if about.orchestrator.supportsManagementAddLinux %}x{% else %} {% endif %}]
- [{% if about.orchestrator.supportsManagementRemoveWin %}x{% else %} {% endif %}] Supports Management Remove
- [{% if about.orchestrator.supportsCreateStoreWin %}x{% else %} {% endif %}] Supports Create Store
- [{% if about.orchestrator.supportsDiscoveryWin %}x{% else %} {% endif %}] Supports Discovery
- [{% if about.orchestrator.supportsReenrollmentWin %}x{% else %} {% endif %}] Supports Renrollment
