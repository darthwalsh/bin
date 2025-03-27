---
aliases:
  - chrome.extensions
---
- [ ] Export what I use from Chrome

## Currently using

- [1Password – Password Manager](https://chromewebstore.google.com/detail/aeblfdkhhhdcdjpifhhbdiojplfjncoa)
- [Application Launcher For Drive (by Google)](https://chromewebstore.google.com/detail/lmjegmlicamnimmfhcmpkclmigmmcbeh)
- [Button for Google Calendar](https://chromewebstore.google.com/detail/lfjnmopldodmmdhddmeacgjnjeakjpki)
- [Chrome Remote Desktop](https://chromewebstore.google.com/detail/inomeogfingihgjfjlpeplalcfajhgai)
- [Crossword Scraper](https://chromewebstore.google.com/detail/lmneijnoafbpnfdjabialjehgohpmcpo)
- [Eye Dropper](https://chromewebstore.google.com/detail/hmdcmlfkchdmnmnmheododdhjedfccka)
- [Github Issue Reactions](https://chromewebstore.google.com/detail/enekincdenmmbpgkbhflknhaphpajnfd)
- [Google Docs Offline](https://chromewebstore.google.com/detail/ghbmnnjooekpmoecnnnilnnbdlolhkhi)
- [I don't care about cookies](https://chromewebstore.google.com/detail/fihnjjcciajhdojfnbdddfaoknhalnja)
- [iD Strava Heatmap](https://chromewebstore.google.com/detail/eglbcifjafncknmpmnelckombmgddlco)
- [Obsidian Web Clipper](https://chromewebstore.google.com/detail/cnjifjpddelmedmihgijeibhnjfabmlf)
- [Reddit Enhancement Suite](https://chromewebstore.google.com/detail/kbmfpngjjgdllneeigpgjifpgocmfgmb)
- [Remove W3Schools](https://chromewebstore.google.com/detail/gohnadkcefpdhblajddfnhapimpdjkje)
- [Save to Pocket](https://chromewebstore.google.com/detail/niloccemoadcdkdjlinkgdfekeahmflj)
- [Tab Copy](https://chromewebstore.google.com/detail/micdllihgoppmejpecmkilggmaagfdmb)
- [Wayback Machine](https://chromewebstore.google.com/detail/fpnmgdkabkmnadcjpehmlllkndpkmiak)

Found this from [SuperUser](https://superuser.com/questions/1164152/get-a-list-of-installed-chrome-extensions). From `chrome://extensions/` run

```js
copy(document.querySelector('extensions-manager').extensions_.filter(({state}) => state !== 'DISABLED').map(({name, webStoreUrl}) => `- [${name}](${webStoreUrl})`).join("\n"))
```

### Script improvements

- [ ] Get disabled extensions too
- [ ] In order to get permissions, try something like:
```js
copy(document.querySelector('extensions-manager').extensions_.map(({id, name, state, webStoreUrl, permissions}) => ({id, name, state, webStoreUrl, perms: permissions.simplePermissions.map(simple => simple.message)})))
```
- [ ] NEXT, try [Extension List Exporter - Chrome Web Store](https://chromewebstore.google.com/detail/extension-list-exporter/bhhfnfghihjhloegfchnfhcknbpdfmle)
### [Button for Google Calendar - Chrome Web Store](https://chromewebstore.google.com/detail/button-for-google-calenda/lfjnmopldodmmdhddmeacgjnjeakjpki)
Origin: a googler had a chrome extension that allowed adding calendar events from plain-text, but that API was deprecated...
Now the extension has been forked by a few groups, including one which advertises Manganum extension.
- [ ] Considering forking myself to remove ads, or maybe trying [Checker Plus for Google Calendar™ - Chrome Web Store](https://chromewebstore.google.com/detail/checker-plus-for-google-c/hkhggnncdpfibdhinjiegagmopldibha)
### [Github Issue Reactions - Chrome Web Store](https://chromewebstore.google.com/detail/github-issue-reactions/enekincdenmmbpgkbhflknhaphpajnfd)
- [ ] [Chrome extension link / webstore page broken · Issue #38 · Norfeldt/github-issue-reactions-browser-extension](https://github.com/Norfeldt/github-issue-reactions-browser-extension/issues/38)
- [ ] Try forking, add an entry for [this](https://github.com/PowerShell/PowerShell/issues/16812#event-13855745034) "closed this as" maybe with "added the `Resolution-No Activity` label"
### on manifest v2 and need to upgrade
Need to find some alternative for anything not upgrading to manifest v3
- [ ] [Hide Hot Network Question on Stack Exchange](https://chromewebstore.google.com/detail/hide-hot-network-question/jommfgnflipjalbpbgcfghdpoeijpoab)
	- Not on github
	- [x] Disabled. As a workaround, at https://meta.stackexchange.com/users/preferences/313196 enable "Hide hot network questions"
	- Maybe that's even better, instead of having interesting questions to nerd-snipe me...
	- [ ] Consider enabling HNQ again ⏳ 2025-05-30 
- [ ] [RescueTime for Chrome and Chrome OS](https://chromewebstore.google.com/detail/rescuetime-for-chrome-and/bdakmnplckeopfghnlpocafcepegjeap)
	- [x] pinged https://www.rescuetime.com/users/help
  - [ ] heard back ⏳ 2025-02-03
- [-] [JSON Resume Exporter](https://chromewebstore.google.com/detail/json-resume-exporter/caobgmmcpklomkcckaenhjlokpmfbdec) ❌ 2025-01-30
	- uninstalled
- [-] [Pushbullet](https://chromewebstore.google.com/detail/pushbullet/chlffgpmiacpedhhbkiomidkjlcfhogd) ❌ 2025-01-30
	- [devs are going to let it die](https://www.reddit.com/r/PushBullet/comments/1eidx6q/pushbullet_chrome_extension_uses_manifest_v2/)  -- maybe I'll switch to use gmail and/or obsidian sync to share data between devices?
- [x] [Remove W3Schools](https://chromewebstore.google.com/detail/remove-w3schools/gohnadkcefpdhblajddfnhapimpdjkje) 
	- [Fixed](https://github.com/GMaiolo/remove-w3schools/issues/16#issuecomment-2625358504)
## Interested to try
- [ ] [GitHub Issue Helper](https://chromewebstore.google.com/detail/github-issue-helper/ofckeainckjmmfocpjilclcdfcoajfno?source=sh/x/wa/m1/4&kgs=616b828c3939b6eb)
	- [ ] Solves part of the problem in [[FossUserVoice]]
- [ ] https://github.com/refined-github/refined-github
- [ ] [Find on Reddit](https://chromewebstore.google.com/detail/find-on-reddit/jbcdpeekakanklckgooknpbonojhjncm)
- [ ] Some UI when stackexchange post Accepted answer is lower voted than Best answer
	- [ ] or is really old, got less points/time
- [ ] [ChatGPT search - Chrome Web Store](https://chromewebstore.google.com/detail/chatgpt-search/ejcfepkfckglbgocfkanmcdngdijcgld)
- [ ] [z0ccc/comet: Browser extension to replace Youtube comments with Reddit comments or view the Reddit comments of any webpage.](https://github.com/z0ccc/comet)
- [ ] undo paste blocking JS: [Fireship youtube short](https://youtube.com/shorts/7bmsDg4BaKw?si=S2ZxrtdXTZz4JA2i)
- [ ] https://greasyfork.org/en/scripts/443250-remove-related-answers-on-quora
- [ ] https://github.com/swyxio/Twitter-Links-beta

## Keybindings
https://keycombiner.com/collecting/collections/personal/36109/
