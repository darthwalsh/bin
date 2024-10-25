*For scope: not sure about needing to have linter autofix. Maybe I want a formatter tool instead of linter that nags about nonproblems?*
*Moved these thoughts into [[markdown.autoformat]]!*
## Linting indents

- [ ] Fix any pages that use **both** spaces and tabs for indents.
- [ ] Check that indent-depth is consistent
	  - [ ] probably enforce multiple-of-4 for lists, given how 2-space-indent doesn't look good

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

### Mkdocs linkcheck
Not sure if this is useful outside Mkdocs environment, but worth learning features it has. From https://pypi.org/project/mkdocs-linkcheck/ notable features:
* Fast
* Check local (relative) and remote links
* Output useful summary reports to help you track down and fix broken links
* Recurse through an entire documentation tree
* Can check remote links async, and can use HEAD HTTP method
* Exclude links from being checked
Not sure this is well-maintained: https://github.com/byrnereese/linkchecker-mkdocs/pull/9

### linkchecker-markdown
Mkdocs linkcheck was a fork of https://github.com/scivision/linkchecker-markdown
- [ ] not sure about recursing, but has most of the same features
- [x] Try with pipx run?
```console
$ pipx run linkcheckmd -local --recurse .
ERROR:root:'recurse' currently works only for remote links.
0.00178 seconds to check links
```
- [ ] How do you run it on all .md files? 
```console
$ pipx run linkcheckmd -local './apps/*.md'
FileNotFoundError: /Users/walshca/code/bin/apps/*.md

$ pipx run linkcheckmd -local ./apps/*.md
linkcheckMarkdown: error: unrecognized arguments: apps/auth.md apps/brew.listpackages.md apps/brew.md ...
```

- [ ] read through alternatives at https://github.com/scivision/linkchecker-markdown?tab=readme-ov-file#alternatives
- popular markdown-link-check github action [uses](https://github.com/gaurav-nelson/github-action-markdown-link-check/blob/master/entrypoint.sh#L11)  markdown-link-check npm package
- another choice to validate HTML pages: https://github.com/wjdp/htmltest
- another newer choice is https://github.com/UmbrellaDocs/linkspector

### Ensuring that all deleted images are deleted
- [ ] If all references to some image are delete, probably should delete the file? Maybe this rule wouldn't apply for folders with expected images; need some way to ignore foldes

### Ensuring content goes into the right vault
- [ ] i.e. work content in work vault, health info not in public github vault
- maybe some list of regexs that points to specific vault path

### TODO formats
The two queries on this page would be good to add to the linter: https://publish.obsidian.md/tasks/How+To/Find+tasks+with+invalid+data
- [x] Any TODO that has `⏫` in the middle instead of in the end isn't picked by the Obsidian TODO plugin
- [x] https://publish.obsidian.md/tasks/Queries/Filters#Finding+Tasks+with+Invalid+Dates ⏫
- [x] For now, added to [[Tasks]] queries

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
