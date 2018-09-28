# Proxy Stuff!

Proxies can be TRICKY!! Here, we aggregate some interesting resources about proxied stuff:

## Nginx

- [how to do redirects](https://www.digitalocean.com/community/tutorials/how-to-create-temporary-and-permanent-redirects-with-nginx)
- [the map module](http://nginx.org/en/docs/http/ngx_http_map_module.html)
- [the proxy module](http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_redirect)

## Apache

- Apparently `RequestHeader set Blah "%{REQUEST_SCHEME}s..."` does not work...
  it sets `X-RSC-Header: (null)://(null)(null)`, which generates an internal
  server error (500) at `/__api__/server_settings`
- [Variables in Apache](https://httpd.apache.org/docs/2.4/expr.html)
