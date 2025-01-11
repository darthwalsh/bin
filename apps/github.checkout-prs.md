From https://www.jvt.me/posts/2019/01/19/git-ref-github-pull-requests/

Run:

```bash
git config remote.origin.fetch '+refs/pull/*:refs/remotes/origin/pull/*'
```

Demo:
```
$ git fetch

$ git show-ref
50dddc24b38e0a888a04d28c5d1c55985c0f7f03 refs/heads/master
b4becfa3170689061cf2108e883c17a3dfe25f33 refs/remotes/origin/MajesticMoose
3ee78704e1b80425f57f4bfb3dcd24179212c761 refs/remotes/origin/MajesticMoose-old
2bccf367f64d9896935f65933afb122432b8310e refs/remotes/origin/TC-Backup
8285b3ab1b77c10a84fdd989466802f2baa92e39 refs/remotes/origin/TheColonel
26230b87c2fa5b1d95ba0be37d80c50db66ee454 refs/remotes/origin/TheColonel-old
cd69cef59834a50a6e76c04b58f0466e0d6dfc5d refs/remotes/origin/master
f35e7b35cf8af7530b6be008332e1a6af00935c3 refs/remotes/origin/master-old
814696bae8c831ca661dd5e1c55adf000ac20831 refs/remotes/origin/pull/44/head
a81439de6fdbe568b52df7ed7cd306d581c251a8 refs/remotes/origin/pull/44/merge
55f97d19168157a3e6ec5cfbb28b3ca2deadf827 refs/remotes/origin/pull/45/head
9076ca95e22e9d58ecd6d836b058cd2e64807507 refs/remotes/origin/pull/45/merge
df945f0020bfcabee804b60d1143062bd24226af refs/remotes/origin/rewrite
814696bae8c831ca661dd5e1c55adf000ac20831 refs/remotes/origin/ssh-config
55f97d19168157a3e6ec5cfbb28b3ca2deadf827 refs/remotes/origin/update-readme
91e4d69a7c2ac7c8ad5206615114a2f78f27ad94 refs/stash

$ git log -1 origin/pull/45/head
commit 55f97d19168157a3e6ec5cfbb28b3ca2deadf827 (origin/update-readme, origin/pull/45/head)
Author: Jamie Tanna <jamie@jamietanna.co.uk>
Date:   Sat Dec 24 19:34:47 2016 +0000

    WIP add placeholder file

$ git log -1 origin/pull/45/merge
commit 9076ca95e22e9d58ecd6d836b058cd2e64807507 (origin/pull/45/head)
Merge: e57f7e1 55f97d1
Author: Jamie Tanna <jamie@jamietanna.co.uk>
Date:   Sat Oct 21 22:01:36 2017 +0000

    Merge 55f97d19168157a3e6ec5cfbb28b3ca2deadf827 into e57f7e1c7782a9966fbda16ded7fb97954921fdf
```