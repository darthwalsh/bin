For source code, I'd often use a tool like [[prettier]] to avoid putting mental cycles into how to format code.
There should be a similar tool for Markdown files. 

- Ideally I could run it from CLI, vscode, and obsidian
- Maybe make it some git precommit hook 

- [x] Try running https://github.com/executablebooks/mdformat on git repo first ⏫
	- [x] `pipx run mdformat .`
	- ❌ yikes, messed up frontmatter. AND, not GFM aware...
	- ✅ Converted tab indents to two spaces
- [ ] retry mdformat, wit above plugins: https://mdformat.readthedocs.io/en/stable/users/plugins.html#id1 ⏫
	- [ ] See https://github.com/topics/mdformat
- [ ] NEXT, try `prettier`: https://prettier.io/blog/2017/11/07/1.8.0.html
- [ ] NEXT, try https://platers.github.io/obsidian-linter/ just against bin/ 
- [ ] THEN, make sure there's some way to rollback the OneDrive notes... cron job that zips it?

### Fixing indents
If initial indent is 4 spaces, then later indent of 6 spaces should be fixed.

### Deleting empty files
Easy to script
```pwsh
gci | gci -r | ? Size -eq 0 | ri
```

note: one complication is that from `~/notes` just running `gci -r`  doesn't recurse into the symlinks
- [ ] Look if this is a bug in pwsh or if there's some workaround
- [ ] could run `find ~/notes/MyNotes/ -empty` -- not recursive though?
### Wiki urls
Fix any `[[Obsidian wiki links]]` into `[Obsidian wiki links](../../Obsidian wiki links.md)`

### Bare URLs
URLs that are links: `[https://example.com](https://example.com)` should just be turned to plaintext link: `https://example.com`
...if it links to any other URL, don't fix but should be lint error. (Ignore the fragment instead of erroring though.)

