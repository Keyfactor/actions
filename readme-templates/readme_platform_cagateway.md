## Keyfactor AnyCA Gateway Framework Supported
The Keyfactor gateway framework implements common logic shared across various gateway implementations and handles communication with Keyfactor Command. The gateway framework hosts gateway implementations or plugins that understand how to communicate with specific CAs. This allows you to integrate your third-party CAs with Keyfactor Command such that they behave in a manner similar to the CAs natively supported by Keyfactor Command.




This gateway extension was compiled against version {{ gateway_framework }} of the AnyCA Gateway 
{%- if (integration_type == "ca-gateway")  %} DCOM{% endif %} 
{%- if (integration_type == "anyca-gateway")  %} REST{% endif %} Framework.  You will need at least this version of the framework Installed.  
{% if (integration_type == "ca-gateway")  %} If you have a later AnyGateway Framework Installed you will probably need to add binding redirects in the CAProxyServer.exe.config file to make things work properly.{% endif %}


[Keyfactor CAGateway Install Guide](https://software.keyfactor.com/Guides/AnyGateway_Generic/Content/AnyGateway/Introduction.htm)


