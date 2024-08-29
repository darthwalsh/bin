Google Keep: https://keep.google.com/
## Exporting Keep using Obsidian import
Worked great to try the [Obsidian import](https://help.obsidian.md/import/google-keep) which uses Google Takeout, then can import all 600MB ZIP file in maybe 10 minutes. 

- [ ] Need to figure out the Archive format though... what should I do in general with Archived notes? Instead of a tag, an archive folder? How to exclude from search?
## Exporting Keep using keep-it-markdown
https://github.com/djsudduth/keep-it-markdown
Uses [`gkeepapi`](https://github.com/kiwiz/gkeepapi) to interact with Google Keep.

Haven't tried this
## Updating `No_LABEL` tag with TagTheKeep
https://github.com/darthwalsh/TagTheKeep
>You can use this script to create the label `NO_LABEL` which allows you to easily find all un-labed notes. Each time you run it, it will loop through all your notes and assign the `NO_LABEL` label for all un-labeled notes, and remove the `NO_LABEL` label if there is also another label.
>Visit [https://keep.google.com/#label/NO_LABEL](https://keep.google.com/#label/NO_LABEL) and add labels or archive notes.
>Uses [`gkeepapi`](https://github.com/kiwiz/gkeepapi) to interact with Google Keep.

- [ ] If can't get password to work, then check browser cookie step in https://github.com/djsudduth/keep-it-markdown?tab=readme-ov-file#step-4