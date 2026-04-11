#app-idea-done
## Problem
I used to [[toil]] managing PRs across several repos by keeping each PR open in its own Chrome tab, manually arranged together. I tracked progress by looking at the tab favicons (like showing checks failing or passing, or no mark for merged), and I often rearrange or revisit these tabs when action is needed. (Some repos have [[github.pr.automerge]] enabled, but others need the PR manually merged after approval.) 

It does help that I have my [ghallrm](../ghallrm.ps1) script which automates all the local branch cleanup, post-merge.

## Solution summary
Goal:
- View all repos, not just the CWD repo
- View every PR, not just the first one
- If PR is approved, might require manual attention to merge
- Is ambient background info, not requiring manual checks

| tool                                           | All Repos | Every PR | Shows Approval | Ambient |
| ---------------------------------------------- | --------- | -------- | -------------- | ------- |
| Current Manual tabs                            | ✅         | ✅        | ❌              | ✅       |
| `gh pr status`                                 | ❌         |          |                |         |
| `gh pr list`                                   | ❌         |          |                |         |
| `gh pr checks <id>`                            | ❌         |          |                |         |
| `gh status`                                    | ✅         | ❌        |                |         |
| [`gh-dash`](https://github.com/dlvhdr/gh-dash) | ✅ [^1]    | ✅        | ✅              | ❌       |
[^1]: In `$HOME/.config/gh-dash/config.yml` set `smartFilteringAtLaunch: false`

## Solution using the browser seem unhelpful
Some ideas from AI that weren't great:
- **Tampermonkey script:** Could detect PR pages and visually organize them within GitHub’s UI, but apparently can’t control browser tab order.
- **Chrome automation** using `chrome-cli` doesn't provide direct control over tab positions.
- **Chrome wrapper** idea is not useful here, because I have CLI script that opens the `gh` pr in the first place. 
	- (Related #app-idea was for managing VPN tabs: create `my-chrome.sh` that examines the URL and does something differing on VPN tabs, wrap into a macOS app for default browser with [Platypus](https://sveinbjorn.org/platypus)

## Solution: oh-my-posh prompt segment from cron job
- [x]  [`gh-pr-status.py`](../gh-pr-status.py) polls PRs and writes a single emoji to `~/.local/share/gh-pr-status/status.txt`

### Status emoji

| emoji | meaning |
| ----- | ------- |
| 👌 | any PR is approved with all checks passing — needs manual merge |
| 💬 | any PR has a review requested or changes requested (and not yet re-requested) |
| ❌ | any PR has a failing/errored check |
| 🔄 | any PR is behind its base branch — needs rebase/merge |
| _(empty)_ | nothing needs attention |

Adopted PRs that are merged (✅) or closed without merging (🚫) are automatically removed from the watch list.

Multiple statuses could match, but the highest one is shown: 👌 before 🔄.

### Setup

**1. Install the launchd job** (polls every 5 min):
```sh
cp ~/code/bin/mac/com.darthwalsh.gh-pr-status.plist ~/Library/LaunchAgents/
# Customize the GH_HOST env var if needed
launchctl load ~/Library/LaunchAgents/com.darthwalsh.gh-pr-status.plist
```

Logs go to `/tmp/gh-pr-status.log`.

**2. Add an oh-my-posh segment** to `.go-my-posh.yaml` that reads the status file directly via [`readFile`](https://ohmyposh.dev/docs/configuration/text#readfile):
```yaml
- template: '{{ readFile "/Users/walshca/.local/share/gh-pr-status/status.txt" }}'
  type: text
  style: plain
```

**3. Track adopted PRs** (e.g. a Renovate bot PR you've taken ownership of):
```sh
gh-pr-status.py add https://github.com/owner/repo/pull/123
gh-pr-status.py remove https://github.com/owner/repo/pull/123
gh-pr-status.py list
```
(Adopted PRs are stored in `~/.local/share/gh-pr-status/adopted.txt`.)


## Existing tools survey (2026)
#ai-slop

The unique combination this script provides — ambient shell-prompt emoji with an [OSC 8](https://gist.github.com/egmontkob/eb114294efbcd5adb1944c9f3cb5feda) hyperlink, cron-polled, with an "adopted PRs" watch list — has no direct equivalent. Closest alternatives:

| tool | Ambient | Shell prompt | Adopted PRs | Notes |
| ---- | ------- | ------------ | ----------- | ----- |
| [`coder/pr-buddy`](https://github.com/coder/pr-buddy) | ✅ | ❌ | ❌ | macOS status-bar tray app; native OS notifications; adaptive polling; v0.3.0 (Mar 2026) |
| [`balfons/prpeek`](https://github.com/balfons/gh-prpeek) | ❌ | ❌ | ❌ | Live TUI, requires a terminal tab open (4 stars, minimal docs) |
| [`codeGROOVE-dev/prs`](https://github.com/codeGROOVE-dev/prs) | ❌ | ❌ | ❌ | Go CLI `--watch` loop; interactive, not ambient |
| [`z-shell/zsh-github-issues`](https://github.com/z-shell/zsh-github-issues) | ✅ | ✅ | ❌ | Background daemon + zsh hook; issues-focused, Zsh-only |

**Scope limitations** that disqualify these tools:
- None write a file read by oh-my-posh — they all own their own display surface (tray, TUI, or terminal).
- None model the "adopted PRs" concept (watching a bot PR you've taken over).
- None produce the precise `APPROVED + CI passing = manual merge needed` signal.
- `pr-buddy` is the strongest ambient alternative but requires a running GUI app, no prompt hyperlink.

**Verdict:** no drop-in replacement exists. The cron-file-read pattern is genuinely novel.

## v1 Release PLAN.md
AI-generated plan before releasing this as a pypi package:

| #   | task                                                                                                                       | notes                                                                                                                                      |
| --- | -------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| 1   | **Tests** — unit-test `classify_pr` with fixture dicts                                                                     | No network needed; test each `PRStatus` branch<br>i've been collecting `gh` results in `Path.home() / ".local" / "share" / "gh-pr-status"` |
| 2   | **Tests** — mock `subprocess.run` for `_gh_run`; test `cmd_add` / `cmd_remove` / `cmd_poll` flow                           | Use `unittest.mock.patch`                                                                                                                  |
| 3   | **Packaging** — add `pyproject.toml` with `[project.scripts] gh-pr-status = "gh_pr_status:main"`                           | Rename file to `gh_pr_status.py` for importability                                                                                         |
| 4   | **PyPI publish** — add `hatch` or `flit` build backend; GitHub Actions release workflow                                    | `uv publish` supports PyPI directly                                                                                                        |
| 5   | **`--host` flag** — expose `GH_HOST` override as a CLI arg instead of env-only                                             | Makes GHES support self-documenting.<br>*OR, let GH_HOST flow through transparently*                                                       |
| 6   | **Rate-limit guard** — respect `X-RateLimit-Remaining` header; back off when low                                           | Currently silent on 403s                                                                                                                   |
| 7   | **Review-wait timer** (see `MAYBE` comment in source) — show how long since re-request via `ReviewRequestedEvent` timeline | Needs one extra GraphQL call per 💬 PR                                                                                                     |
| 8   | **`gh-pr-status update-branch`** — auto-call `gh pr update-branch` when `BEHIND + APPROVED`; rate-limit per repo           | See existing `MAYBE` comment                                                                                                               |
| 9   | Document dependencies: just `gh` signed in?                                                                                | switch to a github python lib?                                                                                                             |
| 10  | Perf and less queries: reduce `gh pr view` and use big GraphQL queries?                                                    |                                                                                                                                            |
