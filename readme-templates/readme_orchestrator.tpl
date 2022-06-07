### The {{ name }} orchestrator is hcapable of the following operations

- [{% if about.orchestrator.win.supportsManagementAdd %}x{% else %} {% endif %}] Supports Magnagement Add
- [{% if about.orchestrator.win.supportsManagementRemove %}x{% else %} {% endif %}] Supports Management Remove
- [{% if about.orchestrator.win.supportsCreateStore %}x{% else %} {% endif %}] Supports Create Store
- [{% if about.orchestrator.win.supportsDiscovery %}x{% else %} {% endif %}] Supports Discovery
- [{% if about.orchestrator.win.supportsReenrollment %}x{% else %} {% endif %}] Supports Renrollment

| Operation | Windows | Linux |
|-----|-----|------|
|Supports Management Add|{% if about.orchestrator.win.supportsManagementAdd %}x{% else %} {% endif %} |{% if about.orchestrator.linux.supportsManagementAdd %}x{% else %} {% endif %} |
|Supports Management Remove|{% if about.orchestrator.win.supportsManagementRemove %}x{% else %} {% endif %} |{% if about.orchestrator.linux.supportsManagementRemove %}x{% else %} {% endif %} |
|Supports Create Store|{% if about.orchestrator.win.supportsCreateStore %}x{% else %} {% endif %} |{% if about.orchestrator.linux.supportsCreateStore %}x{% else %} {% endif %} |
|Supports Discovery|{% if about.orchestrator.win.supportsDiscovery %}x{% else %} {% endif %} |{% if about.orchestrator.linux.supportsDiscovery %}x{% else %} {% endif %} |
|Supports Renrollment|{% if about.orchestrator.win.supportsReenrollment %}x{% else %} {% endif %} |{% if about.orchestrator.linux.supportsReenrollment %}x{% else %} {% endif %} |

