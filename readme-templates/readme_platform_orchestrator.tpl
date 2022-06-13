## Platform notes

This plugin performs different capabilities depending on the platform where Keyfactor Command is installed

On Windows: {{ about.orchestrator.win.platformSupport }} 

On Linux: {{ about.orchestrator.linux.platformSupport }} 

| Operation | Win | Linux |
|-----|-----|------|
|Supports Management Add|{% if about.orchestrator.win.supportsManagementAdd %}&check;{% else %} {% endif %} |{% if about.orchestrator.linux.supportsManagementAdd %}&check;{% else %} {% endif %} |
|Supports Management Remove|{% if about.orchestrator.win.supportsManagementRemove %}&check;{% else %} {% endif %} |{% if about.orchestrator.linux.supportsManagementRemove %}&check;{% else %} {% endif %} |
|Supports Create Store|{% if about.orchestrator.win.supportsCreateStore %}&check;{% else %} {% endif %} |{% if about.orchestrator.linux.supportsCreateStore %}&check;{% else %} {% endif %} |
|Supports Discovery|{% if about.orchestrator.win.supportsDiscovery %}&check;{% else %} {% endif %} |{% if about.orchestrator.linux.supportsDiscovery %}&check;{% else %} {% endif %} |
|Supports Renrollment|{% if about.orchestrator.win.supportsReenrollment %}&check;{% else %} {% endif %} |{% if about.orchestrator.linux.supportsReenrollment %}&check;{% else %} {% endif %} |
|Supports Inventory|{% if about.orchestrator.win.supportsInventory %}&check;{% else %} {% endif %} |{% if about.orchestrator.linux.supportsInventory %}&check;{% else %} {% endif %} |

