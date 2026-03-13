## Problem
I normally manage PRs across several repos by keeping each PR open in its own Chrome tab, manually grouped together. I track progress by looking for status indicators (like favicons showing checks failing or passing, or no check for merged), and I often rearrange or revisit these tabs when action is needed. (Or for repos that don't have [[github.pr.automerge]] enabled, in case the PR manually needs to be merged.) This workflow takes some annoying time. 

It does help that I have my [ghallrm](../ghallrm.ps1) script which automates all the local branch cleanup.

## Solution summary
Goal:
- View all repos, not just the current one
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

## Solution using the browser seem unhelpful
*(I'm trusting some #ai-slop from https://chatgpt.com/share/689ec4b7-eccc-8011-a22d-7dad0f192265 here.)*

- **Tampermonkey script:** Could detect PR pages and visually organize them within GitHub’s UI, but it can’t control browser tab order—so it can’t fully automate your current tab workflow?
- **Chrome automation** using `chrome-cli` doesn't provide direct control over tab positions.
- **Chrome wrapper** idea is not useful here, because I have CLI script that opens the `gh` pr in the first place. 
	- (Idea was for managing VPN tabs: create `my-chrome.sh` that examines the URL and does something differing on VPN tabs, wrap into a macOS app with [Platypus](https://sveinbjorn.org/platypus)

## Solution: oh-my-posh prompt segment

- [x] #app-idea-done [`gh-pr-status.py`](../gh-pr-status.py) polls PRs and writes a single emoji to `~/.local/share/gh-pr-status/status.txt`

### Status emoji

| emoji | meaning |
| ----- | ------- |
| 👌 | any PR is approved with all checks passing — needs manual merge |
| ❌ | any PR has a failing/errored check |
| _(empty)_ | nothing needs attention |

Priority: 👌 checked first, then ❌. An empty status file means the prompt segment shows nothing.

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

Adopted PRs are stored in `~/.local/share/gh-pr-status/adopted.txt`.

[^1]: In `$HOME/.config/gh-dash/config.yml` set `smartFilteringAtLaunch: false`
