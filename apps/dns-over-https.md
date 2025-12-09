First private DNS was DNS-over-TLS. For consumers DNS-over-HTTPS is preferred.
DNSSEC is different: it signs the DNS response, but the hostname is still in plaintext.
For more explanation: Dave's Garage [video](https://youtu.be/lxFd5xAN4cg?si=IdrX_0CSi4WEZqpd)
## Android
[Docs](https://support.google.com/googlepixeltablet/answer/13591533?hl=en#zippy=%2Cprivate-dns) show the default is Automatic Private DNS, but for me at https:/1.1.1.1/help that was showing NO to DoH...
Instead, [manually configured Cloudflare 1.1.1.1](https://developers.cloudflare.com/1.1.1.1/setup/android/)
Chrome defaults to using the Secure DNS from the system.

*But then at a corporate location, I couldn't get any Internet!*
The fix was switching from manual `one.one.one.one` back to "Automatic" :(
- [ ] Is it possible to automatically switch back and forth based on the WiFi network you're on?
## Desktop
- [ ] DoH #windows 
- [-] DoH #macbook ❌ 2025-11-17
## Google Home
Not supported (maybe a DHCP limitation?)
