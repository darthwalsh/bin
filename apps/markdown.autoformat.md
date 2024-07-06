For source code, I'd often use a tool like [[prettier]] to avoid putting mental cycles into how to format code.
There should be a similar tool for Markdown files. 

- Ideally I could run it from CLI, vscode, and obsidian
- Maybe make it some git precommit hook 

- [ ] Try running https://github.com/executablebooks/mdformat

### Deleting empty files
Easy to script
```pwsh
gci | gci -r | ? Size -eq 0 | ri
```

note: one complication is that from `~/notes` just running `gci -r`  doesn't recurse into the symlinks
- [ ] Look if this is a bug in pwsh or if there's some workaround

### Wiki urls
Fix any `[[Obsidian wiki links]]` into `[Obsidian wiki links](../../Obsidian wiki links.md)`

### Bare URLs
URLs that are links: `[https://example.com](https://example.com)` should just be turned to plaintext link: `https://example.com`
...if it links to any other URL, don't fix but should be lint error. (Ignore the fragment instead of erroring though.)

