Simple firewall utility, can do port forwarding.

i.e. in a systemctl `.service` setting up a server to listen on nonpriveledged port 8001, but redirecting traffic from port 80 to it.

```service
# Redirect nonpriveledged port 8001 to receive traffic from port 80 using PLUS for sudo
ExecStartPre=+/usr/sbin/iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8001
```
