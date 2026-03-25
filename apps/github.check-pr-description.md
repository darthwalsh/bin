---
tags:
  - app-idea
---
> Fail a PR if the description body contains an unchecked `- [ ]` checkbox — so all PR template items must be checked before merging.

PR descriptions can change independently of git pushes, so this can't run in the normal push-triggered pipeline (and we don't want the full Docker build/test just to validate the PR description).

## GitHub Actions (if not locked into Jenkins)

- [ ] Try something like this first
[`mheap/require-checklist-action`](https://github.com/mheap/require-checklist-action) does exactly this — fails the check if any `- [ ]` remains in the PR body. Trigger on `pull_request: types: [opened, edited, synchronize]`. The `edited` event fires on title, body, or base branch changes (no way to narrow to body-only, but that's fine for this use case).

```yaml
on:
  pull_request:
    types: [opened, edited, synchronize]
jobs:
  checklist:
    runs-on: ubuntu-latest
    steps:
      - uses: mheap/require-checklist-action@v2
        with:
          requireChecklist: true  # fail if no checkboxes found at all
```

Supports optional items (skip via regex), strikethrough as "N/A", and radio groups (`<!-- TaskRadio groupname -->`).

Other options: 
- [`peternied/check-pull-request-description-checklist`](https://github.com/marketplace/actions/check-pull-request-description-checklist) (validates specific named items are checked/struck-out)
- [`AhmedBaset/checklist`](https://github.com/ahmedbaset/checklist) (outputs `checked`/`unchecked` lists for conditional logic).

## Jenkins approach
At work we use [[Jenkins CI/CD]], so GitHub Actions seems to be second class. Basic plan

- [ ] **Webhook → lightweight job**: listen to the [`pull_request` webhook](https://docs.github.com/en/webhooks/webhook-events-and-payloads#pull_request) `edited` [event](https://github.com/octokit/webhooks/blob/ecf7d47476982f9834e10b0d3e505d2225fee13d/payload-schemas/api.github.com/pull_request/edited.schema.json), 
    - [ ] webhook server runs a tiny Python/groovy script that uses webhook body `.pull_request.body` and checks if `- [ ]` is present. 
    - [ ] Needs a GitHub App or PAT with `repo:status` scope
    - [ ] POST back a [GitHub Commit Status](https://docs.github.com/en/rest/commits/statuses) or [Check Run](https://docs.github.com/en/rest/checks/runs) via REST. 
    - Webhook payload includes `changes.body.from` so you can skip re-checking if only the title changed?
- [-] **"Discover Pull Requests from Origin" trait** in the multibranch pipeline config gives `$CHANGE_ID` ([docs](https://www.jenkins.io/doc/book/pipeline/multibranch/#additional-environment-variables)) — but this still only triggers on git push, not on PR description edits. ❌ 2026-03-19
- [-] [JENKINS-50871](https://issues.jenkins.io/browse/JENKINS-50871) "Filter by GitHub PR Description" — WONTFIX for this use case: still open/unresolved as of Dec 2025, and it's a *filter* (skip building the branch), not a check that fails the PR. ❌ 2026-03-19

## Risks / things that won't work

- **Synchronous webhook response**: GitHub webhooks are fire-and-forget: GitHub ignores the HTTP response body/status for webhook delivery — you can't block a merge by returning 4xx from a webhook endpoint. Must use the Checks API or Commit Statuses API to post a result back.
- **`edited` event is noisy**: fires on title changes and base branch changes too, not just body edits. Fine to re-run the check; just don't assume `edited` = body changed.
- **Branch protection required**: the check only blocks merging if the repo has a [required status check](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches#require-status-checks-before-merging) configured. Without that, the failing check is advisory only.
- **PR description is mutable after merge**: someone could uncheck items after merging. This check only gates the merge moment.

## v2
Slack notification when a PR is merged with unchecked items, or a weekly rollup summary of merged PRs that had open checklist items.
