#social-roast #idea #parked

**Social Roast**: a weekly self-review of my public social comments. An agent
pulls recent comments, reconstructs parent-thread context, and delivers
**highlights** (sharp, non-obvious takes) and **lowlights** (technical
misinformation to correct). A pseudo-algorithm that challenges me in the right
way — grounded, specific, falsifiable — in private instead of in the thread.

## Why parked (2026-10-07)

Reddit salted the earth:
- 2026-05-30: unauthenticated `.json` endpoints deprecated **globally** (the
  403s weren't just datacenter-IP reputation)
- 2026-11-13 (planned): RSS feeds end — the last unauthenticated door
- 2027-03 (planned): public Data API fully retired in phases
- Ambiguous 2026-10-31 milestone on "new API requests" — if I ever register an
  app, sooner beats later

A background worker can't drive a live browser, so fully-unattended fetch now
needs Reddit OAuth (refresh token) — the only surviving path.

## Options when reviving

1. **Interactive**: just ask the agent for the roast; it fetches via live
   browser in-session. Works today, zero setup.
2. **OAuth, token in agent vault**: create a Reddit app, approve OAuth once;
   worker hits `oauth.reddit.com` directly (verified reachable from worker
   network at TLS level, 2026-10-07).
3. **OAuth on my hardware**: script on MacBook refreshes token + fetches, drops
   JSON in a Syncthing folder, worker analyzes. Tokens never leave my machines;
   most setup.

## Draft work (uncommitted, 2026-10-07)

- Skill playbook: `dotfiles/social-roast/SKILL.md` — identity-agnostic, handle
  passed at invocation, never stored in the repo
- `dotfiles/social-roast/TODO.md` — v2 ideas: other platforms (GitHub, X, HN,
  YouTube, TikTok, Obsidian forum), two-column HTML report, richer parent
  context with images
- Sunday 6am cron (`social-roast-weekly`) existed — **disabled** 2026-10-07;
  re-enable when a fetch path works

## Privacy

Handles stay out of the repo. The reddit identity lives only in private
invocation config — plausible deniability, since other internet users share the
name.
