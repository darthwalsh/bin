# GitHub PR Self-Approve Loophole

A reviewer assigned to a PR could push a new commit to the branch, then approve and merge — with zero second eyes on the pushed code. The "require N approvals" rule only counted approvals, not whether the approver had also written code since the last review.

## Fix: Require Approval of the Most Recent Reviewable Push

[GitHub's 2022 branch protection setting](https://github.blog/changelog/2022-10-20-new-branch-protections-last-pusher-and-locked-branch/) "Require approval of the most recent reviewable push" closes this: the last person to push must get approval from someone *else* before merging, regardless of existing approvals.

Enable it under **Settings > Branches > Branch protection rules > Require a pull request before merging**.
