{% if gateway_framework is defined %}
## Keyfactor AnyGateway Framework Supported

This gateway was compiled against version {{ gateway_framework  }} of the AnyGateway Framework.  You will need at least this version of the AnyGateway Framework Installed.  If you have a later AnyGateway Framework Installed you will probably need to add binding redirects in the CAProxyServer.exe.config file to make things work properly.
{% endif %}

