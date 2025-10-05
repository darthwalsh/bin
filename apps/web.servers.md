Several web application frameworks like Flask include a development HTTP server, but for *reasons* are not meant to service production traffic. Instead, a dedicated web server is often used:
- Apache HTTP Server AKA httpd
- Nginx
- Caddy
- Traefik
- HAProxy
- IIS
Many of the modern tools combine several roles: they act as web servers _and_ reverse proxies _and_ TLS terminators _and_ load balancers.
## Would default to Caddy
- Easier to configure, with sane defaults. Good docs, nice community.
- Plugin system is slightly goofy.
See [[Some notes on NixOS#why Caddy?]]
