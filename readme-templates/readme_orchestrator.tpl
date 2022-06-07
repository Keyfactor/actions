### The {{ name }} orchestrator is hcapable of the following operations

- [{% if about.orchestrator.win.supportsManagementAdd %}x{% else %} {% endif %}] Supports Magnagement Add
- [{% if about.orchestrator.win.supportsManagementRemove %}x{% else %} {% endif %}] Supports Management Remove
- [{% if about.orchestrator.win.supportsCreateStore %}x{% else %} {% endif %}] Supports Create Store
- [{% if about.orchestrator.win.supportsDiscovery %}x{% else %} {% endif %}] Supports Discovery
- [{% if about.orchestrator.win.supportsReenrollment %}x{% else %} {% endif %}] Supports Renrollment

| Operation | Windows | Linux |
|-----|-----|------|
|Supports Management Add|{% if about.orchestrator.win.supportsManagementAdd %}&check;{% else %} {% endif %} |{% if about.orchestrator.linux.supportsManagementAdd %}&check;{% else %} {% endif %} |
|Supports Management Remove|{% if about.orchestrator.win.supportsManagementRemove %}&check;{% else %} {% endif %} |{% if about.orchestrator.linux.supportsManagementRemove %}&check;{% else %} {% endif %} |
|Supports Create Store|{% if about.orchestrator.win.supportsCreateStore %}&check;{% else %} {% endif %} |{% if about.orchestrator.linux.supportsCreateStore %}&check;{% else %} {% endif %} |
|Supports Discovery|{% if about.orchestrator.win.supportsDiscovery %}&check;{% else %} {% endif %} |{% if about.orchestrator.linux.supportsDiscovery %}&check;{% else %} {% endif %} |
|Supports Renrollment|{% if about.orchestrator.win.supportsReenrollment %}&check;{% else %} {% endif %} |{% if about.orchestrator.linux.supportsReenrollment %}&check;{% else %} {% endif %} |

