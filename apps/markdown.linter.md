*For scope: not sure about needing to have linter autofix. Maybe I want a formatter tool instead of linter that nags about nonproblems?*
*Moved these thoughts into [[markdown.autoformat]]!*
## Linting indents

- [ ] Fix any pages that use **both** spaces and tabs for indents.
- [ ] Check that indent-depth is consistent (probably don't use 2 spaces for lists?)

## Linting links

### markdown-link-check
- [ ] Try using `markdown-link-check` to lint links.
- [ ] Add github action to find newly broken network links
- https://github.com/tcort/markdown-link-check
- Does both local and network URLs, doesn't seem to be a way to turn off network
- [ ] Try using `ignorePatterns` for `https?://` regex?
- Asserts [anchor links](https://github.com/tcort/markdown-link-check/issues/91) for URL fragments on local links
- Recursively searching files is [tricky](https://github.com/tcort/markdown-link-check/issues/78) -- could run `markdown-link-check (git ls-files -- *.md)`
### DavidAnson/markdownlint rule for fragment
https://github.com/DavidAnson/markdownlint/blob/main/doc/md051.md
- [ ] does this find file that doesn't exist?

### Ensuring that all deleted images are deleted
- [ ] If all references to some image are delete, probably should delete the file? Maybe this rule wouldn't apply for folders with expected images; need some way to ignore foldes

### Ensuring content goes into the right vault
- [ ] i.e. work content in work vault, health info not in public github vault
- maybe some list of regexs that points to specific vault path

# Tools
- [platers/obsidian-linter](https://github.com/platers/obsidian-linter)
	- ~~Doesn't seem to have an auto-fix~~
	- Integration with [[Obsidian]] GUI
	- [Doesn't support](https://github.com/platers/obsidian-linter/issues/987) CLI version to run outside obsidian
- https://forum.obsidian.md/t/markdown-integrity-check/9264 recommends the following:
- [DavidAnson/markdownlint](https://github.com/DavidAnson/markdownlint)
	- [vscode extension](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint) has fixAll
	- rules for inconsistent intent, and [tabs instead of spaces](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md#md010---hard-tabs)
	- CLI is compatible with pre-commit: https://github.com/DavidAnson/markdownlint-cli2#pre-commit
	- [ ] Check if there is any Obsidian plugin (not essential if I have git pre-commit)
- [markdownlint/markdownlint](https://github.com/markdownlint/markdownlint)
- [remarkjs/remark-lint](https://github.com/remarkjs/remark-lint)
- [ ] Check others from https://github.com/BubuAnabelas/awesome-markdown?tab=readme-ov-file#linters