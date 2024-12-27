- [ ] Make a symlink like [[dotfiles]]

Current:
```json
{
  "promptDelete": false,
  "alwaysUpdateLinks": true,
  "newFileLocation": "current",
  "readableLineLength": false,
  "attachmentFolderPath": "./",
  "showUnsupportedFiles": true,
  "showInlineTitle": true,
  "showRibbon": false,
  "userIgnoreFilters": [
    "RunTheGlobe/functions/node_modules/",
    "walshca/jenkins_wfapi/env/"
  ]
}
```

- [ ] try the effect of:  “Use [[Wikilinks]]” - "off" 
- [x] Detect all file extensions - enabled
	- [x] Add on #windows

## Ignoring huge node_modules folders
Setting: Files and links > Excluded files

However, an [open feature request](https://forum.obsidian.md/t/ignore-exclude-completely-files-or-a-folder-from-all-obsidian-indexers-and-parsers/52025?u=darthwalsh) is that all these excluded files shouldn't be parsed. Still slowdown app open times.

- Delete `venv` folders and replace with `.venv` and should't won't be indexed
- Easiest to just delete old node_modules folders?
- [ ] Try using a [custom prefix](https://stackoverflow.com/a/14867050/771768) to rename `node_modules` -- still on PATH?

