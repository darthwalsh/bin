https://keep.google.com/
Google Keep was my primary sink of FleetingNotes from 2015-2024
I found it was too hard to reliably archive all inbox notes while also keeping several Project notes at the same time.
## No public API
Eventually Google implemented an API on corporate google workspace accounts, but there's still no support for regular consumer gmail accounts: https://developers.google.com/keep/api
- [-] Try google keep API on carl@carlwa.com account, then file FR to https://issuetracker.google.com/issues/new?component=1064155&template=1587095 for Adding Label support ❌ 2025-01-27
## Exporting Keep using Obsidian import
It worked great to try the [Obsidian import](https://help.obsidian.md/import/google-keep) which uses Google Takeout, then can import all 600MB ZIP file in a few minutes. 
For now unsure what to do about [[obsidian.archive|Archived notes]] -- for now I'm just importing the non-archived, and might extract Archive later.
### My import process
1. Ran the import 
	1. ignoring Keep's Archived notes to `~/OneDrive/TODO/google-keep-import/`
	2. Later ran `obslink google-keep-import` to move into vault (much easier than switching between two vaults)
2. At first, symlinked over just the attachments dir
	1. `new-item -ItemType SymbolicLink -path ~/notes/MyNotes/KeepAttachments  -target (Resolve-Path ~/OneDrive/TODO/google-keep-import/Assets)`
	2. *maybe could have used [[obslink.ps1]]*
3. Set Settings > Editor > Properties in document = “Source" 
4. As I process a note from Keep, I am 
	1. Optionally extracting content of all notes containing a label into one note:
		1.  `gci | ? { sls $l "Keep/Label/Game" } | % { printkeep $_ } | in`
	2. *Don't bother archiving in Keep web app, consider markdown as the source of truth*
	3. Deleting MD file from keep import
		1. `gci | ? { sls "Keep/Label/Game" $_ }` then deleting with `| ri`
	4. Coping over any attached images to my normal notes attachment dir
		1. Search for any attachments `"![[1"` to validate nothing was left
5. As I finish all notes with some label, unless many existing items already were archived, deleting label
6. Archive *everything* in Keep web app
7. Cleanup symlinks created above
### Making word cloud
To keep it interesting, grouped notes by topic based on a wordcloud
`gci -file | % { printkeep $_ } | pipx run wordcloud --imagefile /tmp/output.png --stopwords ~/stopwords.txt --min_word_length 3 --width 1000 --height 800`
### Feature Requests for obsidian-importer
- [ ] Make an issue on https://github.com/obsidianmd/obsidian-importer/issues ⏫ 
#### Note annotation URL not included
Many keep notes have a "chip" at the bottom with URL links. In the raw JSON it's `.annotations[].url`.

Most Keep workflows adding URLs annotations would also add the link to the text, but if you used Gmail sidebar to create keep notes then the link is missing i.e. if you search https://keep.google.com/u/0/#search/text%253Dmail.google.com you'll find keep notes with gmail links that didn't get copied into the exported markdown.

Workaround: I created script [keep_url.py](../keep_url.py) to try to help find non-redundant URLS 

Many of the missing URLs were trivial: there's many links that lead to the canonical source (multiple host names, language in URL, expanding shortlinks, etc.), or the text content made it easy enought to re-find the web context.

But, it did help me find one tiktok link I didn't know I had saved. The JSON was like:
```json
{
  "annotations": [ { "url": "https://www.tiktok.com/@grade3withms.e/video/7059496051148999982" } ],
  "textContent": "https://vm.tiktok.com/TTPdkXjner/"
}
```
and only the annotation link works.
### Feature Requests for Google Keep Takeout
- [ ] Make a webapps stackoverflow post or support forum requests

Some of these would need to be fixed in the Takeout Process. Checking the JSON/HTML I don't see any hint of the missing data in the export format.
#### No Reminders
The Reminder date is not included in the exported markdown, but that is a limitation of the Takeout process.

Workaround: open https://keep.google.com/u/0/#reminders 

Missing from Takeout.
#### Lists lose hierarchy
Nested lists with sub-bullets lose the hierarchy and become flat list

I.e. keep content
```
- Proj A
	- Getting Started
- Proj B
	- Plan Design
```
Gets exported as flast list:
- Proj A
- Getting Started
- Proj B
- Plan Design

This also affects checklists, which in Keep can have some subtasks that are checked and show below the fold, nested under unchecked main item.

Missing from Takeout.
## Exporting Keep using keep-it-markdown
https://github.com/djsudduth/keep-it-markdown
Uses [`gkeepapi`](https://github.com/kiwiz/gkeepapi) to interact with Google Keep.

Never tried this, but doesn't seem to support annotions either.
## Updating `No_LABEL` tag with TagTheKeep
It's slow to label multiple notes, and there's [no keyboard extension to label](https://support.google.com/docs/thread/9266447?hl=en) or way to filter for unlabelled notes.

https://github.com/darthwalsh/TagTheKeep tries to automate 
>You can use this script to create the label `NO_LABEL` which allows you to easily find all un-labed notes. Each time you run it, it will loop through all your notes and assign the `NO_LABEL` label for all un-labeled notes, and remove the `NO_LABEL` label if there is also another label.
>Visit [https://keep.google.com/#label/NO_LABEL](https://keep.google.com/#label/NO_LABEL) and add labels or archive notes.
>Uses [`gkeepapi`](https://github.com/kiwiz/gkeepapi) to interact with Google Keep.

- [-] If can't get password to work, then check browser cookie step in https://github.com/djsudduth/keep-it-markdown?tab=readme-ov-file#step-4 ❌ 2025-01-07
*Not needed if I use [[#Exporting Keep using Obsidian import]]*
