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

## Solution I could build
- [ ] #app-idea Build one of these, and update `gitpr` to skip opening browser tab
1. Script that queries all my PRs with pr checks, approvals.
2. Run script periodically, possibly saving results in a JSON file.
3. Display the result in some unobtrusive way:
    - A oh-my-posh prompt extension
    - A browser tab, with a favicon that updates based on PR status.
    - A menu bar item
    - A slack notification from a muted channel

[^1]: In `$HOME/.config/gh-dash/config.yml` set `smartFilteringAtLaunch: false`
