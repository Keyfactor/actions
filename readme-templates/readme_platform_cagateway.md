{% if gateway_framework is defined %}
## Keyfactor Gateway Framework Supported

This gateway was compiled against version {{ gateway_framework  }} of the Gateway Framework.  You will need at least this version of the Gateway Framework Installed.  If you have a later Gateway Framework Installed you will probably need to add binding redirects in the CAProxyServer.exe.config file to make things work properly.
{% endif %}

