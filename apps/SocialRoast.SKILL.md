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
- `comments_csv`: path to the comments-only sanitized CSV from the owner's Reddit data-request export (see Workflow step 1). The path lives in the invoker's private config; the export itself never enters this repo.
- All handles and account URLs live in the invoker's private config, not in this repo.

## State

Coverage cursors live outside this repo, on the agent's persistent volume: `$XDG_STATE_HOME/social-roast/state.json` (default `~/.local/state/social-roast/state.json`). The file holds two ISO-8601 UTC timestamps and nothing else:

- `covered_from`: oldest comment reviewed so far. Quota backfill (step 4) goes older than this, then lowers it.
- `covered_through`: newest comment reviewed so far. A new run reviews comments newer than this, then raises it.

Update both after every run. Timestamps only — no identities in the state file either.

## Workflow

1. **Fetch** — primary path (chosen 2026-11-05): the owner-assisted DevTools blob. The agent never fetches Reddit directly; the owner's logged-in browser does, which sidesteps the anti-scraping blocks that kill unattended fetches.
   - The corpus is local: the comments-only sanitized CSV from the owner's data-request export (`comments_csv` input). It holds every comment's body, date, subreddit, permalink, post link, and parent comment id — but no scores and no other users' text.
   - Pick the slice from the state cursors: comments newer than `covered_through`, or backfill older than `covered_from`, stepping back until the slice plausibly fills the quota. From the slice's rows, collect the distinct (subreddit, post id) pairs. If a slice spans very many threads, triage from the CSV first (threads the owner commented in repeatedly, hot-take text) and/or split the blob.
   - Generate one JavaScript blob with that thread list **embedded as a literal array** — never derived from the page the owner happens to be on (a blob that fetched "the current page" once exported the front page instead). The blob fetches each thread's `<thread path>.json?raw_json=1&limit=500` with `credentials: "include"`, waits a jittered ~0.9–2.5s between fetches, and downloads one combined JSON keyed by post id.
   - The owner pastes the blob into DevTools Console on any reddit.com page while logged in, runs it, and uploads the JSON. The agent joins JSON ↔ CSV by comment id, gaining score, parent chain, nested replies, and removed/deleted state for every comment in the slice.
   - Cross-check deletions both ways: the export can retain the text of comments later deleted or removed; the live JSON shows their current state (score hidden once deleted). A CSV id missing from its thread's JSON is itself evidence.
   - Fallback for one-off context checks: an interactive live-browser task on the permalink (read-only, no login) works, but expect network blocks and humanity challenges.
   Skip comments with no replies — unless |score| > 5: high-signal outliers (heavily upvoted or downvoted) are mildly interesting on their own (rule added 2026-10-29).
2. **Reconstruct context** for each remaining comment: the post (title + a few-sentence summary) and the immediate parent comment(s) being replied to (a few sentences each — never dump whole threads). If the user `> quoted` a sentence, treat it as the anchor for what they're responding to.
3. **Assess** each comment's claims:
   - *Lowlight*: states something false or misleading as fact. Distinguish wrong vs. imprecise vs. matter of opinion. Quote briefly.
   - *Highlight*: non-obvious, non-cliché, and correct — mechanistic detail, good calibration, teaching-quality explanation.
4. **Quota**: aim for 2–4 highlights and 2–4 lowlights. If the window is thin, step the window backward through history until the quota fills or history runs out. (Backfill moves the `covered_from` cursor in the state file — see State above.)
5. **Historical charity**: judge old comments by what was true *at the time* (e.g. "correct in 2024"). Apply current standards forward only — recurring tics (e.g. "Google says" phrasing for AI-Overview relays) get nagged going forward, never for old comments.

## Output contract

Chat digest: lowlights first (each with the correction), then highlights (each with what made it good). Direct and specific; no generic praise. Note where sibling context changed the reading (e.g. "the first reply was wrong").

## Operating rules

- Read-only on the platform. Never post, vote, or otherwise interact.
- No identities, handles, or account URLs in this repo — they live with the invoker.
- Parked 2026-10-07; the TODO section below tracks revival steps.

## TODO — next steps on revival

### Pick a fetch path — RESOLVED 2026-11-05
- **Chosen: owner-assisted DevTools blob** (Workflow step 1). The owner runs a
  generated blob in their own logged-in browser; the agent works from the
  returned JSON plus the data-request export CSV. No tokens, no OAuth app, no
  unattended fetching.
- Scheduling shape this enables: a scheduled run computes the next slice from
  the state cursors, generates the blob, and delivers it to the owner, then
  pauses. The roast completes once the owner runs the blob and uploads the
  JSON. Fully unattended fetching remains impossible (see constraints), so
  the Sunday cron stays disabled until the owner opts into this semi-scheduled
  shape.
- Rejected alternatives: OAuth with the token in the agent vault, or OAuth on
  the owner's hardware with a Syncthing drop folder — both workable, but the
  blob needs no app registration ahead of the API shutdown deadlines and no
  credential custody.

### Then
- If the owner opts in: schedule the prep-and-prompt run (e.g. Sunday 06:00)
  that generates and delivers the next blob.
- Implement v2 ideas: other platforms (GitHub PR/issue comments, X, Hacker
  News, YouTube, TikTok, Obsidian forum), two-column HTML report (thread left,
  inline comments right), richer parent context (small OP images, sibling
  context).
- Keep handles out of the repo — invocation config only.

### Known constraints (2026-10-07, updated 2026-11-05)
- Background workers cannot drive the live browser (`browser.spawn_task` is
  main-agent only); `browser.open` is policy-blocked for reddit.com.
- Reddit deprecated unauthenticated `.json` globally on 2026-05-30; RSS slated
  to end 2026-11-13; public Data API fully retired in phases through 2027-03.
  "Curl from a residential IP" does not work — the block is policy, not IP
  reputation.
- The export CSV has no scores and no other users' text; scores, reply trees,
  and removal state exist only in thread JSON (hence the blob). A profile
  `.json` listing from the owner's browser can supply scores for triage, but
  Reddit caps user listings at ~1,000 items, so it only covers recent history.
- The blob path depends on `.json` endpoints answering a logged-in browser
  session. If Reddit retires those too, fall back to the data-request export
  alone (discovery only, no scores) or revisit OAuth before the 2027-03
  public-API closure.
