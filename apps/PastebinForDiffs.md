I often think about wanting to create an online project that shows the diff of text. (e.g. this could have been an artifact of [DiffingPDFs](DiffingPDFs.md)).

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
