Customizing [Tab Copy - Chrome Web Store](https://chromewebstore.google.com/detail/tab-copy/micdllihgoppmejpecmkilggmaagfdmb)
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
                "title_matcher": "\[([^\]]+)\] (.*) - Example, Inc. JIRA",
                "unique": false,
                "url_matcher": ""
            },
            "url_fragment": "https://jira.example.com/browse"
        }
```
- Creating a custom title_matcher to remove the site URL isn't very sustainable
- Stopped using: [[browser.plugins#Tab Modifier]]
##### Solution customizing title with userscript
Installation: [[browser.plugins#Light scripting]]

resource: https://greasyfork.org/en/scripts/18253-github-title-notification/code
- [ ] Try creating new script to update `document.title`

#### NEXT Try One of these:
- Try forking Tab Copy extension, and add functionality there
- Obsidian functionality... Necessary for clean titles if using https://github.com/zolrath/obsidian-auto-link-title
- [IMDb Reelgood link](https://greasyfork.org/en/scripts/454802-imdb-reelgood-link)
