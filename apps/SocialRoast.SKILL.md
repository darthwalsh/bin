---
name: "social-roast"
title: "Social self-review: highlights and lowlights"
description: "Weekly review of your public social comments: reconstructs parent-thread context, flags technical misinformation (lowlights), and surfaces sharp non-obvious takes (highlights). Identity-agnostic: handles are passed at invocation, never stored here."
---

# Social Roast

A weekly self-review of public social comments — what you got wrong and what was sharp — with enough parent-thread context to judge fairly.

## Inputs (passed at invocation; never store identities in this file)

- `username`: the handle to review on the target platform
- `platform`: currently `reddit` (see TODO below for planned platforms)
- `window_days`: lookback window (default 7); or `since` as an ISO date to override
- All handles and account URLs live in the invoker's private config, not in this repo.

## Workflow

1. **Fetch** the user's recent comments, newest first. Reddit fetch paths:
   - *Interactive / main-agent session:* read-only live-browser task (`browser.spawn_task`) on `https://www.reddit.com/user/<username>/comments/` — no login, no voting, no posting. This is the working path today.
   - *Scheduled / background worker:* not currently possible — workers cannot spawn browser tasks, `browser.open` is policy-blocked for reddit.com, and unauthenticated API access was deprecated by Reddit globally on 2026-05-30. See TODO below for the OAuth option.
   Skip comments with no replies.
2. **Reconstruct context** for each remaining comment: the post (title + a few-sentence summary) and the immediate parent comment(s) being replied to (a few sentences each — never dump whole threads). If the user `> quoted` a sentence, treat it as the anchor for what they're responding to.
3. **Assess** each comment's claims:
   - *Lowlight*: states something false or misleading as fact. Distinguish wrong vs. imprecise vs. matter of opinion. Quote briefly.
   - *Highlight*: non-obvious, non-cliché, and correct — mechanistic detail, good calibration, teaching-quality explanation.
4. **Quota**: aim for 2–4 highlights and 2–4 lowlights. If the window is thin, step the window backward through history until the quota fills or history runs out.
5. **Historical charity**: judge old comments by what was true *at the time* (e.g. "correct in 2024"). Apply current standards forward only — recurring tics (e.g. "Google says" phrasing for AI-Overview relays) get nagged going forward, never for old comments.

## Output contract

Chat digest: lowlights first (each with the correction), then highlights (each with what made it good). Direct and specific; no generic praise. Note where sibling context changed the reading (e.g. "the first reply was wrong").

## Operating rules

- Read-only on the platform. Never post, vote, or otherwise interact.
- No identities, handles, or account URLs in this repo — they live with the invoker.
- Parked 2026-10-07; the TODO section below tracks revival steps.

## TODO — next steps on revival

### Pick a fetch path
- **Interactive** (works today): owner asks for the roast; agent fetches via live
  browser in-session. Zero setup.
- **OAuth, token in agent vault**: owner creates a Reddit app at
  reddit.com/prefs/apps, approves OAuth once via an interactive browser
  session; refresh token stored in the vault; worker calls oauth.reddit.com
  (verified reachable from worker network at TLS level, 2026-10-07).
- **OAuth on owner's hardware**: script refreshes token + fetches, drops JSON in
  a Syncthing folder, worker analyzes. Tokens never leave owner's machines.
- Note: an ambiguous "Oct 31, 2026" milestone in Reddit's API-shutdown
  reporting — if registering an app, sooner is safer.

### Then
- Re-enable the Sunday 06:00 cron (disabled 2026-10-07) or convert to an
  interactive trigger, per the chosen fetch path.
- Implement v2 ideas: other platforms (GitHub PR/issue comments, X, Hacker
  News, YouTube, TikTok, Obsidian forum), two-column HTML report (thread left,
  inline comments right), richer parent context (small OP images, sibling
  context).
- Keep handles out of the repo — invocation config only.

### Known constraints (2026-10-07)
- Background workers cannot drive the live browser (`browser.spawn_task` is
  main-agent only); `browser.open` is policy-blocked for reddit.com.
- Reddit deprecated unauthenticated `.json` globally on 2026-05-30; RSS slated
  to end 2026-11-13; public Data API fully retired in phases through 2027-03.
  "Curl from a residential IP" does not work — the block is policy, not IP
  reputation.
