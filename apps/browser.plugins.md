---
aliases:
  - chrome.extensions
---
See [[PluginPhilosophy]] for evaluation criteria.

## ✅ Currently Using
- [1Password – Password Manager](https://chromewebstore.google.com/detail/aeblfdkhhhdcdjpifhhbdiojplfjncoa)
- [Application Launcher For Drive (by Google)](https://chromewebstore.google.com/detail/lmjegmlicamnimmfhcmpkclmigmmcbeh)
- [Chrome Remote Desktop](https://chromewebstore.google.com/detail/inomeogfingihgjfjlpeplalcfajhgai)
- [Crossword Scraper](https://chromewebstore.google.com/detail/lmneijnoafbpnfdjabialjehgohpmcpo)
- [Eye Dropper](https://chromewebstore.google.com/detail/hmdcmlfkchdmnmnmheododdhjedfccka)
- [Google Docs Offline](https://chromewebstore.google.com/detail/ghbmnnjooekpmoecnnnilnnbdlolhkhi)
- [I don't care about cookies](https://chromewebstore.google.com/detail/fihnjjcciajhdojfnbdddfaoknhalnja)
- [iD Strava Heatmap](https://chromewebstore.google.com/detail/eglbcifjafncknmpmnelckombmgddlco)
- [Obsidian Web Clipper](https://chromewebstore.google.com/detail/cnjifjpddelmedmihgijeibhnjfabmlf)
- [Reddit Enhancement Suite](https://chromewebstore.google.com/detail/kbmfpngjjgdllneeigpgjifpgocmfgmb)
- [Remove W3Schools](https://chromewebstore.google.com/detail/gohnadkcefpdhblajddfnhapimpdjkje)
- [Tab Copy](https://chromewebstore.google.com/detail/micdllihgoppmejpecmkilggmaagfdmb)
- [Tampermonkey](https://chromewebstore.google.com/detail/dhdgffkkebhmkfjojejmpbldmpobfkfo)
- [Wayback Machine](https://chromewebstore.google.com/detail/fpnmgdkabkmnadcjpehmlllkndpkmiak)

- [ ] Export what I use from Chrome using below script 🔁 every 3 months 🏁 delete ⏳ 2026-02-03

### Usage notes

#### Obsidian Web Clipper
- [[TabCopy]] > "Save clipped note without opening it" = TRUE

### Management
Found this from [SuperUser](https://superuser.com/questions/1164152/get-a-list-of-installed-chrome-extensions). From `chrome://extensions/` run:
```js
copy(document.querySelector('extensions-manager').extensions_.filter(({state}) => state !== 'DISABLED').map(({name, webStoreUrl}) => `- [${name}](${webStoreUrl})`).join("\n"))
```
improvements:
- [ ] Get disabled extensions too
- [ ] In order to get permissions, try something like:
```js
copy(document.querySelector('extensions-manager').extensions_.map(({id, name, state, webStoreUrl, permissions}) => ({id, name, state, webStoreUrl, perms: permissions.simplePermissions.map(simple => simple.message)})))
```
- [ ] NEXT, try [Extension List Exporter - Chrome Web Store](https://chromewebstore.google.com/detail/extension-list-exporter/bhhfnfghihjhloegfchnfhcknbpdfmle)
## 🔍 Considering / Someday-Maybe
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
	- [ ] NEXT script [Scripty - Javascript Injector - Chrome Web Store](https://chromewebstore.google.com/detail/scripty-javascript-inject/milkbiaeapddfnpenedfgbfdacpbcbam)
- [ ] https://github.com/swyxio/Twitter-Links-beta
- [ ] vim mode
- [ ] Fix [Github Issue Reactions - Chrome Web Store](https://chromewebstore.google.com/detail/github-issue-reactions/enekincdenmmbpgkbhflknhaphpajnfd)
	- [ ] Now [archived](https://github.com/Norfeldt/github-issue-reactions-browser-extension) :(
	- [ ] [Chrome extension link / webstore page broken · Issue #38 · Norfeldt/github-issue-reactions-browser-extension](https://github.com/Norfeldt/github-issue-reactions-browser-extension/issues/38)
	- [ ] Try forking, add an entry for [this](https://github.com/PowerShell/PowerShell/issues/16812#event-13855745034) "closed this as" maybe with "added the `Resolution-No Activity` label"
## ❌ Tried / Stopped Using
### Tab Modifier
[Tab Modifier](https://chromewebstore.google.com/detail/hcbgadmbdkiilgpifjgcakjehmafcjai)
- chrome extension was removed for malware? top github issues indicates it's a mistake
- New version is at [Tabee: Tab Modifier - Chrome Web Store](https://chromewebstore.google.com/detail/tabee-tab-modifier/penegkenfmliefdbmnfkidlgjfjcidia?hl=en)
### [Button for Google Calendar - Chrome Web Store](https://chromewebstore.google.com/detail/button-for-google-calenda/lfjnmopldodmmdhddmeacgjnjeakjpki)
*Removed for privacy reasons*

Origin: a googler had a chrome extension that allowed adding calendar events from plaintext, but that API was deprecated...
Fix! On mobile, use gemini to select plaintext and make a calendar event!

The extension has been forked by a few groups, including one which advertises Manganum extension.
Instead of a plugin, now using macOS/Windows system calendar to view google calendar.
### Extensions needing Manifest V3 upgrade
- [x] [Hide Hot Network Question on Stack Exchange](https://chromewebstore.google.com/detail/hide-hot-network-question/jommfgnflipjalbpbgcfghdpoeijpoab)
	- Not on github
	- [x] Disabled. As a workaround, at https://meta.stackexchange.com/users/preferences/313196 enable "Hide hot network questions"
	- Maybe that's even better, instead of having interesting questions to nerd-snipe me...
- [x] [RescueTime for Chrome and Chrome OS](https://chromewebstore.google.com/detail/rescuetime-for-chrome-and/bdakmnplckeopfghnlpocafcepegjeap)
	- [x] pinged https://www.rescuetime.com/users/help
	- [x] heard back "You do not need the Chrome extension. Desktop app will sync websites from Chrome browser."
	- [x] Validated chrome for windows
	- [x] Validated chrome for macOS
	- [-] Post on forum? ❌ 2025-11-03

> Unfortunately, we do not currently have plans to build a Chrome extension that works with manifest v3.  
>   
> This is because to achieve full tracking of websites and applications, you do not need the Chrome extension if you are using the RescueTime desktop app. The desktop app will track all of our supported browsers: Chrome, Safari, Edge, Firefox (Firefox does require the Firefox extension for macOS only), and Arc.  
>   
> If you have any further questions or need help with anything else, feel free to get in touch.

- [-] [JSON Resume Exporter](https://chromewebstore.google.com/detail/json-resume-exporter/caobgmmcpklomkcckaenhjlokpmfbdec) ❌ 2025-01-30
	- uninstalled
- [-] [Pushbullet](https://chromewebstore.google.com/detail/pushbullet/chlffgpmiacpedhhbkiomidkjlcfhogd) ❌ 2025-01-30
	- [devs are going to let it die](https://www.reddit.com/r/PushBullet/comments/1eidx6q/pushbullet_chrome_extension_uses_manifest_v2/)  -- maybe I'll switch to use gmail and/or obsidian sync to share data between devices?
	- uninstalled
- [x] [Remove W3Schools](https://chromewebstore.google.com/detail/remove-w3schools/gohnadkcefpdhblajddfnhapimpdjkje) 
	- [Fixed](https://github.com/GMaiolo/remove-w3schools/issues/16#issuecomment-2625358504) - *Moved back to Currently Using*
## Light scripting
Looked into [Violentmonkey - Chrome Web Store](https://chromewebstore.google.com/detail/violentmonkey/jinjaccalgkegednnccohejagnlnfdag) but that won't install in Chrome unless you re-enable Manifest v2
Instead should install [Tampermonkey - Chrome Web Store](https://chromewebstore.google.com/detail/tampermonkey/dhdgffkkebhmkfjojejmpbldmpobfkfo)
- docs: https://www.tampermonkey.net/documentation.php
- resource: https://medium.com/@jmin499/tampermonkey-b53e57195177

Have working example in [[GooglePhotosInbox#JS userscript to easily add photos to album]]

## Keybindings
https://keycombiner.com/collecting/collections/personal/36109/
