#app-idea 
Instead of separate tool, track each issue as a markdown file in a `.bugs/` folder tracked in github?
- When closing an issue, you don't say `Fixes #123` in commit message, you just edit the bug file 
- When branching off an old git tag, you can see which bugs are still open *in this branch*
- When merging a hotfix to the release branch, this will close the bug in that branch
- Get PRs from outside contributors to fix bug descriptions
- Can build TUI or local web server over local files

## Existing tools
*my idea is implemented by ditz?*
- [ditz](https://github.com/jashmenn/ditz) *Simple CLI tracker, stores issues as YAML files in project directory*
- [trackdown](http://mgoellnitz.github.io/trackdown) *Uses a different branch for storage*
- [git-bug](https://github.com/git-bug/git-bug) *Uses `.git` storage source*
- [git-dit](https://github.com/neithernut/git-dit) *Uses git notes to store issues, keeps working tree clean*
- [Fossil](https://www.fossil-scm.org/home/doc/trunk/www/bugtheory.wiki) *not git -- Fossil SCM has built-in distributed issue tracking but not in working space, and has good arguments against it*

