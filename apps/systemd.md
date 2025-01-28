There used to be different `init` systems for linux, but now nearly all major distros have switched to RedHat's creation
## systemctl
`systemctl` is the main CLI for interacting with systemd
- [ ] Try [isd](https://isd-project.github.io/isd/#__tabbed_1_3) next time
## Creating a service
template for `pull_mention.service` that starts after network, redirects HTTP port 80 to app's non-privileged 8001 using [[iptables]].
```systemd
[Unit]
Description=TODO some text
Documentation=TODO url
Wants=network-online.target
After=network-online.target

[Service]
Environment=PORT=8001
Type=simple
User=TODO low-privilege account

# Redirect non-privileged port 8001 to receive traffic from port 80 using PLUS for sudo
ExecStartPre=+/usr/sbin/iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8001
WorkingDirectory=TODO path
ExecStart=/usr/bin/node server.js
Restart=on-failure

[Install]
WantedBy=multi-user.target
```
- [ ] There might be a better way to just un-privilege 80, or give this user just the port-80 super-privilege

Installing the service:
```bash
sudo cp pull_mention.service /lib/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable pull_mention
sudo systemctl start pull_mention
```

Tail the daemon logs:
```
sudo journalctl -u pull_mention --follow
```