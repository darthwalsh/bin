*For scope: not sure about needing to have autofix. Maybe I want a formatter tool instead of linter that nags about nonproblems?
- [ ] Try running https://github.com/executablebooks/mdformat
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

URLs that are links: `[https://example.com](https://example.com)` should just be turned to plaintext link: `https://example.com`
...if it links to any other URL, don't fix but should be lint error. (Ignore the fragment instead of erroring though.)

Fix any `[[Obsidian wiki links]]` into `[Obsidian wiki links](../../Obsidian wiki links.md)`

### DavidAnson/markdownlint rule for fragment
https://github.com/DavidAnson/markdownlint/blob/main/doc/md051.md
- [ ] does this file file that doesn't exist?

# Tools
- [platers/obsidian-linter](https://github.com/platers/obsidian-linter)
	- Doesn't seem to have an auto-fix
	- Integration with [[Obsidian]] GUI
	- [Doesn't support](https://github.com/platers/obsidian-linter/issues/987) CLI version to run outside obsidian
- https://forum.obsidian.md/t/markdown-integrity-check/9264 recommends the following:
- [DavidAnson/markdownlint](https://github.com/DavidAnson/markdownlint)
	- [vscode extension](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint) has fixAll
	- rules for inconsistent intent, and [tabs instead of spaces](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md#md010---hard-tabs)
	- CLI is compatible with pre-commit: https://github.com/DavidAnson/markdownlint-cli2#pre-commit
- [markdownlint/markdownlint](https://github.com/markdownlint/markdownlint)
- [remarkjs/remark-lint](https://github.com/remarkjs/remark-lint)
- [ ] Check others from https://github.com/BubuAnabelas/awesome-markdown?tab=readme-ov-file#linters