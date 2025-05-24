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
### [Tab Copy - Chrome Web Store](https://chromewebstore.google.com/detail/tab-copy/micdllihgoppmejpecmkilggmaagfdmb)
- [ ] Want to remove the website name "- Chrome Web Store" but it's in `document.title`..
#### Doesn't work with existing functionality
[Custom formats](https://tabcopy.com/docs/formats/custom-formats/)  just has `[title]` which is "Tab Copy - Chrome Web Store" here, but I want just "Tab Copy" the majority of the time.
- To have semantic clickable links, don't want extra content
- On any StackExchange site, want to remove the first tag most of the time
- On Jira in particular, want to filter out literal `[]` from the title because it's awkward in markdown link
	- nit: I also remove the "component name" and move the title outside the link
- On youtube.com, I normally want to *include* the video creator
#### Solution customizing title with Tab Modifier 
Creating chrome extension / userscript / config that customizes `document.title` 
- [x] Installed [Tab Modifier - Chrome Web Store](https://chromewebstore.google.com/detail/tab-modifier/hcbgadmbdkiilgpifjgcakjehmafcjai?hl=en)
- [x] Created rule
```json
        {
            "detection": "STARTS_WITH",
            "id": "mvd6jxz",
            "is_enabled": true,
            "name": "Jira Brackets",
            "tab": {
                "group_id": null,
                "icon": null,
                "muted": false,
                "pinned": false,
                "protected": false,
                "title": "@1 @2",
                "title_matcher": "\\[([^\\]]+)\\] (.*) - Autodesk, Inc. JIRA",
                "unique": false,
                "url_matcher": ""
            },
            "url_fragment": "https://jira.autodesk.com/browse"
        }
```
- Creating a custom title_matcher to remove the site URL isn't very sustainable
#### Solution customizing title with TamperMonkey
Looked into [Violentmonkey - Chrome Web Store](https://chromewebstore.google.com/detail/violentmonkey/jinjaccalgkegednnccohejagnlnfdag) but that won't install in Chrome unless you re-enable Manifest v2
[Tampermonkey - Chrome Web Store](https://chromewebstore.google.com/detail/tampermonkey/dhdgffkkebhmkfjojejmpbldmpobfkfo)
resource: https://medium.com/@jmin499/tampermonkey-b53e57195177
resource: https://greasyfork.org/en/scripts/18253-github-title-notification/code
docs: https://www.tampermonkey.net/documentation.php#google_vignette
- [ ] Try creating new script to update `document.title`

#### NEXT Try One of these:
- Try forking Tab Copy extension, and add functionality there
- Obsidian functionality... Necessary for clean titles if using https://github.com/zolrath/obsidian-auto-link-title
- [IMDb Reelgood link](https://greasyfork.org/en/scripts/454802-imdb-reelgood-link)

### on manifest v2 and need to upgrade
Need to find some alternative for anything not upgrading to manifest v3
- [x] [Hide Hot Network Question on Stack Exchange](https://chromewebstore.google.com/detail/hide-hot-network-question/jommfgnflipjalbpbgcfghdpoeijpoab)
	- Not on github
	- [x] Disabled. As a workaround, at https://meta.stackexchange.com/users/preferences/313196 enable "Hide hot network questions"
	- Maybe that's even better, instead of having interesting questions to nerd-snipe me...
	- [-] See about enabling again ⏳ 2025-05-30 ❌ 2025-03-23
	- uninstalled
- [ ] [RescueTime for Chrome and Chrome OS](https://chromewebstore.google.com/detail/rescuetime-for-chrome-and/bdakmnplckeopfghnlpocafcepegjeap)
	- [x] pinged https://www.rescuetime.com/users/help
	- [x] heard back "You do not need the Chrome extension. Desktop app will sync websites from Chrome browser."
	- [x] Validated chrome for windows
	- [x] Validated chrome for macOS
	- [ ] Post on forum?

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
	- [ ] NEXT script [Scripty - Javascript Injector - Chrome Web Store](https://chromewebstore.google.com/detail/scripty-javascript-inject/milkbiaeapddfnpenedfgbfdacpbcbam)
- [ ] https://github.com/swyxio/Twitter-Links-beta

## Stopped using
### [Github Issue Reactions - Chrome Web Store](https://chromewebstore.google.com/detail/github-issue-reactions/enekincdenmmbpgkbhflknhaphpajnfd)
Now [archived](https://github.com/Norfeldt/github-issue-reactions-browser-extension) :(
- [ ] [Chrome extension link / webstore page broken · Issue #38 · Norfeldt/github-issue-reactions-browser-extension](https://github.com/Norfeldt/github-issue-reactions-browser-extension/issues/38)
- [ ] Try forking, add an entry for [this](https://github.com/PowerShell/PowerShell/issues/16812#event-13855745034) "closed this as" maybe with "added the `Resolution-No Activity` label"

## Light scripting

## Keybindings
https://keycombiner.com/collecting/collections/personal/36109/
