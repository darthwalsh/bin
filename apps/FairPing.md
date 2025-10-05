#app-idea 
- [ ] expand on this

Problem: Figure out who should host the factorio game. Having high latency or dropped packets means the game has to resync, sometimes by rejoining.

Solution: 
Generate a share link: `ping.carlwa.com/abc123` and everybody opens it. 
Webpage uses WebRTC to compare all connections.
Simulates each person hosting and how happy every other person would be.
Maybe in your prefs you could set "how sensitive are you to lag?" to give your times a little more preference.

v2: Consider if a cloud-hosted game instance would be a better server, and up-sell an affiliate link?

*Terrible evil idea: Gold level access: if you pay premium, you secretly get better preference?*