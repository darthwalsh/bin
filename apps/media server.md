*Outcome: Plex on RasPi 3 seems to be a working solution*
# Plex
## Windows
Works OK, but I normally sleep PC.
If the PC is asleep and you start the Roku TV Plex app, it will see the server is offline and refuse to connect without hard resetting the client.
Annoying workaround: Need to wake the PC a minute before turning on the TV

## Raspberry Pi 1
Main guide: https://pimylifeup.com/raspberry-pi-plex-server/
- This was more secure, using GPG key for `/etc/apt/sources.list.d/plexmediaserver.list`
Also followed along with [nem25's](https://medium.com/@nem25/plex-media-server-on-raspberry-pi-3-using-raspbian-lite-b2f67761e674) and [makeuseof's](https://www.makeuseof.com/tag/raspberry-pi-plex-media-server/) guides.

- [x] Updated OS, but /etc/os-release shows 10 (buster) which is recently EOL...
During `apt full-upgrade`, my computer went to sleep and the SSH connecting hung up!!!
```
Could not get lock /var/lib/dpkg/lock-frontend
```
Ended up watching the `apt` logs that it seemed to stop, then killing the apt process, then re-running upgrade seemed to work...

Online, the upgrade to debian 12 suggested starting with a fresh SD card

- [x] Installed plex
Found something weird [Plex folders are owned by "root:root" - should be "plex:plex"](https://www.reddit.com/r/PleX/comments/6d6u8h/new_server_plex_folders_are_owned_by_rootroot/)
- [x] Did `chmod -R`  to give ownership to `plex:plex`

Fails with signal 11 for SEGFAULT:
```
plexmediaserver.service. failed (Result: signal) code=killed, signal=SEGV
```

So removed:
```bash
sudo apt remove plexmediaserver
sudo rm /etc/apt/sources.list.d/plexmediaserver.list
```

Instead, try self-contained jellyfin server:
### Jellyfin instead of Plex
Main Guide: https://itsfoss.com/jellyfin-raspberry-pi/
Also following along: https://pimylifeup.com/raspberry-pi-jellyfin/

- [x] installed jellyfin
Died with the same `signal=SEGV`
```
$ sudo service jellyfin status
 jellyfin.service - Jellyfin Media Server
   Active: failed (Result: signal) since Thu 2024-08-29 20:47:50 BST; 1h 41min ago
 Main PID: 2913 (code=killed, signal=SEGV)
```

Likely died to 256MB RAM not being enough to load up Jellyfin server, same as plex

## Raspberry Pi 3
- [x] Followed [[#Raspberry Pi 1]] guide

`sudo systemctl status plexmediaserver` shows active, woohoo!

Steps to claim headless linux server:
1. `ssh -L 8888:127.0.0.1:32400 $USER@$SERVER`
2. From desktop, open http://127.0.0.1:8888/web
3. Click click to claim it

`http://$HOSTNAME:32400/web/` works for login, but not for claiming ownership
- [x] Go to http://$IP_ADDRESS:32400/web/


- [ ] low power mode for pi3? use a usb power meter? some command to run to half-sleep it? 🛫 2024-09-29 