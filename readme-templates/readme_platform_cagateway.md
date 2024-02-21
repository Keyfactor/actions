## Keyfactor AnyCA Gateway Framework Supported
The Keyfactor gateway framework implements common logic shared across various gateway implementations and handles communication with Keyfactor Command. The gateway framework hosts gateway implementations or plugins that understand how to communicate with specific CAs. This allows you to integrate your third-party CAs with Keyfactor Command such that they behave in a manner similar to the CAs natively supported by Keyfactor Command.

{% if (integration_type == "ca-gateway")  %}
This gateway extension was compiled against version {{ gateway_framework }} of the AnyCA Gateway DCOM Framework.  You will need at least this version of the framework Installed.  If you have a later AnyGateway Framework Installed you will probably need to add binding redirects in the CAProxyServer.exe.config file to make things work properly.
{% endif %}

{% if (integration_type == "anyca-gateway")  %}
This gateway extension was compiled against version {{ gateway_framework }} of the AnyCA Gateway REST Framework.  You will need at least this version of the framework Installed.  
{% endif %}



[Keyfactor CAGateway Install Guide](https://software.keyfactor.com/Guides/AnyGateway_Generic/Content/AnyGateway/Introduction.htm)


