# Proxy Stuff!

Proxies can be TRICKY!! Here, we aggregate some interesting resources about proxied stuff:

## Helpful Tidbits

- `tcpdump` is a super useful tool...
    - In a docker container, it may be necessary to `mv /usr/sbin/tcpdump /usr/bin/tcpdump` (if you get a `libcrypto` error)
    - Then something like `/usr/bin/tcpdump -i any -w outputfile -nn -s0 port 3939 or port 80` can be helpful
    - [tcpdump examples](https://hackertarget.com/tcpdump-examples/)
    - [monitor many ports](https://stackoverflow.com/questions/2187932/monitoring-multiple-ports-in-tcpdump)
    - [capturing for wireshark](https://www.wireshark.org/docs/wsug_html_chunked/AppToolstcpdump.html)

## Nginx

- [how to do redirects](https://www.digitalocean.com/community/tutorials/how-to-create-temporary-and-permanent-redirects-with-nginx)
- [the map module](http://nginx.org/en/docs/http/ngx_http_map_module.html)
- [the proxy module](http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_redirect)
- [nginx request size limit](https://serverfault.com/questions/814767/413-request-entity-too-large-in-nginx-with-client-max-body-size-set)
- [epic nginx customization through javascript (njs)](https://nginx.org/en/docs/njs/reference.html)

## Apache

- `ProxyPass` and `ProxyPassReverse` are not allowed within an `<If>` block...
  sad. Trying to use variables has also been painful...
- Apparently `RequestHeader set Blah "%{REQUEST_SCHEME}s..."` does not work...
  it sets `X-RSC-Header: (null)://(null)(null)`, which generates an internal
  server error (500) at `/__api__/server_settings`
- [Variables in Apache](https://httpd.apache.org/docs/2.4/expr.html)
- `Header echo .` is a helpful line that returns all Request headers as
  Response headers. However, beware! Multiple `Content-Length` headers can get
put in the response this way, which blows up Chrome... especially for RStudio
Server Pro. In this case, you cannot start an R session.
- Websockets in Apache can be painful... if you're in HTTPS, use WSS!!
- Always make sure that the right modules are loaded!! Otherwise you get weird
  behavior, thinking you have capabilities you do not
- [Logging in Apache](https://www.loggly.com/ultimate-guide/apache-logging-basics/)
- [Advanced Apache customization through RewriteMap](https://stackoverflow.com/questions/21032461/how-to-base64-encode-apache-header)
    - [RewriteMap docs](https://httpd.apache.org/docs/2.4/rewrite/rewritemap.html)
- [Custom Expressions](https://httpd.apache.org/docs/trunk/expr.html)

### CGI

- CGI scripts can be helpful for debugging
- [Overview of different ways to enable](https://mediatemple.net/community/products/dv/204643090/running-scripts-outside-of-the-cgi-bin)
- [How to load module](https://tecadmin.net/enable-or-disable-cgi-in-apache24/)
- [More about how to enable](https://www.techrepublic.com/blog/diy-it-guy/diy-enable-cgi-on-your-apache-server/)
- [Useful script example](https://www.askapache.com/shellscript/apache-printenv-improvement/)

