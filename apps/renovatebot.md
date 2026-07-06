- [ ] Merge in content from [[RenovateDefaultConfig]]

Renovate is a github app that watches for new versions of packages and opens PRs to update the dependencies.

## PRs autoclosed
When a newer eligible version appears, Renovate autocloses the old PR and opens a fresh one for the latest version. The PR title gets `- autoclosed` appended as the marker.

This is much more likely when using [`branchTopic`](https://docs.renovatebot.com/configuration-options/#branchtopic) with full version instead of the default major-only slug : `v0.15.18` PR can't just reuse the `v0.15.17` branch.

`minimumReleaseAge: "1 week"` + `internalChecksFilter: "strict"` suppresses branch/PR creation entirely until the package is old enough — no pending check, no branch. For weekly-releasing packages (e.g. `ruff-pre-commit`), each version has its own 1-week timer, so they pile up: by the time `v0.15.17` becomes eligible, `v0.15.18` is right behind it, causing rapid autoclose churn.
