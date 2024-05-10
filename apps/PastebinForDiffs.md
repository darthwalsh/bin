I often think about wanting to create an online project that shows the diff of text. (e.g. this could have been an artifact of [DiffingPDFs](DiffingPDFs.md)).

In https://github.com/darthwalsh/diff-ecma-335 I'll try implementing this.

## Expectations

My expected workflow would be something like:
1. In branch ORIG:
	1. initial commit of `document.TXT`
	2. add some normalization script, commit the diff
2. In branch NEW:
	1. add some script to generate `document.TXT`
3. Get a link to compare the two branches and understand the differences
4. In branch NEW:
	1. resolve differences by updating generation script
5. In branch ORIG:
	1. resolve difference by updating normalization script
6. Comparing the branches now shows the intended diff

## Using gists
https://gist.github.com/ is a cool site for posting paste-bins. (It would get awkward to create a new github repo for each single-file paste-bin.)

Given a gist is "just a git repo" it seems it could be a nice way to show the diff between one or more files.

[This is the Revisions history](https://gist.github.com/darthwalsh/47b8dd492fc8d0c47edb5ae5dd67cab3/revisions)  for one of my gists. The problem is that it is just showing individual commits for the repo, and doesn't let you compare branches. In fact, [gists do not support branches!](https://stackoverflow.com/a/31018280/771768).

Using gist, in order to view the diff in the website you could do some git-history-rewriting using rebases to squash commits in branch NEW? This feels like using the wrong tool for the job...

### Pasting the diff CLI output directly into a gist
GitHub markdown supports the ```` ```diff```` code block with diff. But it was a bit of a challenge to try to get `wdiff` or `dwdiff` to output lines prefixed with `+` and `-`. Instead, it works to use `git diff` with `--word-diff=porcelain` actually gave a great output, except for the newlines showed as extra lines with `~` :

```bash
git diff --no-index --word-diff=porcelain orig.txt stakx.txt | sed '/^~/d' > diff.txt
```
which can then be pasted into a new gist.

## Using GitHub repo
1. On `main` branch, create README with some explanation.
2. Run `git switch --orphan orig` then add scripts to create the first normalized file
3. Run `git switch --orphan stakx` then add scripts to create the second normalized file

The link:
https://github.com/darthwalsh/diff-ecma-335/compare/orig...stakx
*should* show the diff, but only seems to have about 10% of changed lines. This could be because the normalized text file has **25k lines changed**, and GitHub truncates showing the actual diff?

(Or, maybe orphaned commits is the root cause? It causes message: "There isn’t anything to compare." "**orig** and **stakx** are entirely different commit histories.")

### Pasting the actual diff
Just using `git diff` or github.com /compare link gives an unusable diff view, see below, as it doesn't account for words being on different lines in the paragraph.

In [DiffingPDFs](DiffingPDFs.md) the `wdiff` tool handles word-by-word diffing, so this isn't a problem. [`git diff`](https://git-scm.com/docs/git-diff) has options for diff algorithm, with customizable word-definition regex or just using whitespace with:
```bash
git diff orig stakx --word-diff=color
```

Unfortunately, github.com doesn't support this configuration. The [isaacs/github feedback repo has a comment thread about this](https://github.com/isaacs/github/issues/832) but it's now archived. GitHub Discussions [doesn't seem](https://github.com/orgs/community/discussions?discussions_q=%22word-diff%22) to have any current thread about this.

#### Instead, normalizing paragraph line-breaks
Adding this step to the normalization script, it's easy to remove newline before lowercase letters:
```shell
  | sed --null-data --regexp-extended "s/\n([a-z])/ \1/g" \
```

Applying that to both branches:
```bash
git diff orig-no-newline stakx-no-newline
```
shows diffs halved to **12k lines changed**, Unfortunately, several paragraph line breaks happen before capital letters, but it is a good start.

Unfortunately, the goal was to have a URL artifact showing the diff, and https://github.com/darthwalsh/diff-ecma-335/compare/orig-no-newline...stakx-no-newline doesn't even show the normalized file diff.

### Next steps
- [ ] Try repeating with non-orphaned branches
- [ ] Try replacing stakx-ecma-335.pdf with direct output from pandoc.
- [ ] Try rebasing commits to `orig` branch to fix typos; how does that affect all the other incremental commits though?
    - Is there a git hook tool to regenerate files during each rebase commit? (It feels like there's a more-general problem when trying to use git history to view generated output, which could be from e.g. [`serverless print`](https://www.serverless.com/framework/docs/providers/aws/cli-reference/print) or several internal processes at my work where we'd like to avoid adding the generated file to git. Maybe a different tool around git could be used to view the diff of generating two different commits?)
