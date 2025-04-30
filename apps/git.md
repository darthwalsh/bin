## Don't lose uncommitted work
Any changes you commit in git are always always possible to recover. But any changes you revert or hard-reset over are probably gone for good. Like `rm` with [[SystemTrash#Try rmtrash|rmtrash]], there's a tool that makes periodic backups. (This is like google's google3 which had "open your workspace N minutes ago" virtual paths to solve the same problem.)
- [ ] try [tkellogg/dura: You shouldn't ever lose your work if you're using Git](https://github.com/tkellogg/dura)

## Alternative frontends to consider
Several tools are built on top of `git`: you can try it without enforcing it on your team.

- [ ] [Jujutsu](https://jj-vcs.github.io/jj/latest/) no staging, history manipulation and auto-rebase 
	- [ ] see [blog explainer](https://neugierig.org/software/blog/2024/12/jujutsu.html) and [Tutorial](https://steveklabnik.github.io/jujutsu-tutorial/)
- [ ] [GitButler](https://gitbutler.com/): simultaneous branches on top of your existing workflow.
- [ ] [Gitless](https://gitless.com/): Just track/untrack files. branching saves a stash
