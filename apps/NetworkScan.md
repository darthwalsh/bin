*Can* open Android: Google Home > Wifi > Devices > search/scroll-down > tap > IP Address

*OR*, use a CLI tool [from stackexchange](https://superuser.com/a/261823/282374)
```bash
sudo arp-scan --interface=en0 --localnet
```