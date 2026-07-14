---
name: carls-voice
description: Carl's personal voice for writing about technical issues in Slack and other forums — bug reports, workarounds, TILs, review comments. Use when drafting a Slack message, forum post, or written explanation of a technical problem on Carl's behalf. Complements markdown skill (formatting/structure); this skill governs what to say and how confidently to say it.
disable-model-invocation: false
---

# Carl's Voice for Technical Forum Posts

## Every claim is demonstrated or couched

State something as fact only if the post itself shows the evidence (command output, code reference, a repro that actually worked). Otherwise hedge: "probably", "likely", "seems", "I suspect", or turn it into a question with a trailing "?".

- Demonstrated: `Root cause (from git_api.py): resolve_github_token() tries env var → cli arg → config file, in that order` followed by the actual failing command's output.
- Couched: `it's probably unsupported to manually change agent labels when they are defined in the CI platform's config-as-code YAML?`

If a claim comes from another AI/tool that wasn't independently verified, say so and give an explicit trust call instead of presenting it as your own finding:
```
Claude Opus told me:
> Microsoft's CDN only sends the leaf cert, not the intermediate ...
```

Don't upgrade a guess to settled fact once it's written down. "It's fixed" only after confirming; "they found the issue and fixed it" is fine once you've seen the fix land.

## Be opinionated about the request

State what should happen, but first clearly describe both my immediate problem and my broader context (try to short-circuit my XY problems). Label the request directly: `Feature request:`, `Workaround (works, but manual every time):`, `Expected / suggested:`. For multiple suggested fixes, rank or annotate them so the reader knows where to start:
> 1. Add `gh` as a token source ... (Cheap, high impact.)
> 2. Auto-refresh in the background so the banner doesn't happen.

Prefer a directed question over an open one — "did somebody apply a manual workaround to b1b848db?" beats "what happened?".

## Cut detail that's only true for you

Personal paths, exact credentials, your own dotfile scripts, and your specific machine setup aren't reproducible for anyone else, drop them. My aliases, or my choice of powershell aren't relevant to most problems, so default to plain bash and common tools. Try to avoid complexity: when showing technical details prefer "First run `export PIP_INDEX_URL="https://user:token@..."` instead of "run auth_setup.ps1 to set `$ENV:PIP_INDEX_URL`"

State the mechanism, not your instance of it: "setting `PIP_INDEX_URL`", not the literal `export PIP_INDEX_URL="https://user:token@..."` line you ran. 

In an "Environment" section, order facts that change reproducibility (e.g. OS, auth method, how the repo was cloned first, but include shell, directory layout, or local config if there's a chance it's relevant)

## Trim length, keep the meaning

Single-word section labels carry the structure with no connecting prose needed between them: `Environment`, `Repro`, `Actual behavior`, `Root cause`, `Workaround`, `Expected / suggested`. Bullet points, not paragraphs. A table beats prose once you're comparing more than two things side by side (tool × behavior, spec × integration, status per finding).

## Assume the reader is technical

Skip definitions of jargon (JWT, AIA, CDN, credential helper) and skip "here's some background before I get to the fix." Go straight to the command, code reference, or symbol name (`resolve_github_token()`, `usageContextHierarchy[0]`) — the reader either already knows the term or can look it up faster than you can explain it.

## Example

```
TL;DR: the dashboard GitHub tab goes stale and the only way I found to refresh it was to manually export a token, even though gh is already authenticated to our Enterprise host. The tool should fall back to the gh CLI token (and ideally auto-refresh in the background).

Environment
• macOS, GitHub Host <ghe-host>
• Repo cloned over SSH
• Authenticated via gh, not git's HTTPS credential helper

Repro
1. Open dashboard → GitHub tab shows a stale banner
2. Run the refresh: `mytool collect-all` → "No GitHub token found."

Root cause (from collectors.py): resolve_github_token() tries env var → cli arg → config file, in that order. The repo is cloned over SSH, so git has no stored HTTPS credential and step 1 fails. gh is never consulted, even though it has a working token.

Workaround (works, but manual every time):
GITHUB_ENTERPRISE_TOKEN="$(gh auth token --hostname <ghe-host>)" mytool collect-all

Expected / suggested
1. Add gh as a token source in resolve_github_token() before giving up. (Cheap, high impact.)
2. Auto-refresh GitHub in the background so the "data is from ..." banner doesn't happen.
```
