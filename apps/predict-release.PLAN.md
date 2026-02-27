---
tags:
  - app-idea
---
# Plan to predict next github release

## Original App idea: "web app that predicts when next github release will be."
- e.g. if you parse https://github.com/PowerShell/PowerShell/releases you could chart the date of the last stable minor releases 7.4.0, 7.3.0, 7.2.0, and look for the correlation with the preview releases of those.
- Then predict out from 7.5.0-previewN releases for when 7.5.0 will ship
- OR: maybe you can scrape something on github metadata that includes roadmap
	- Projects or Projects (classic) -- for PowerShell they're not using that, but other projects probably do

## Problem

Developers and users want to know: *"When will the next release of X drop?"* No tool answers this. Existing tools (OpenHub, Keypup, GrimoireLab) report past activity — none forecast forward. GitHub's own UI only shows the last release date.

The key insight: GitHub has an embarrassingly large dataset of release histories across millions of repos. A model trained on that corpus can learn release cadence patterns that no single-repo heuristic can capture.

## Target output (MVP UX)

The output is a **human-readable confidence statement**, not a raw probability:

> "Might release within 2 weeks. Almost certainly within 7 weeks."

Internally this maps to two quantiles of the predicted remaining-wait distribution:
- ~50th percentile → "might" / "likely"
- ~90–95th percentile → "almost certainly"

This is more useful than a single mean date because release timing is noisy. Users need to know both the optimistic and conservative horizon.

---

## MVP scope

**In scope:**
- Repos that use GitHub Releases (tagged releases with a date)
- Predict time until *next stable release* (ignore pre-releases / RCs for the output, but use them as input signals)
- Single-repo query: user pastes a GitHub URL → gets a prediction
- Output: two-horizon confidence statement + a simple confidence band chart (timeline)
- Web UI (read-only, no auth required for public repos)

**Out of scope for MVP:**
- Apps without GitHub releases (plaintext changelogs, etc.) — v2
- Private repos
- Predicting patch vs minor vs major distinction
- Community fork prediction — v2
- Notification/watch mode — v2

---

## PoC needed before full build

Two PoCs to prove usefulness before training at scale:

### PoC 1 — Signal validation (does the data predict anything?)

**Goal:** Confirm that historical release dates alone are predictive enough to be useful.

**Method:**
1. Pull release history for ~100 well-known repos via GitHub API (`/repos/{owner}/{repo}/releases`)
2. Split 50-50 data for training vs testing
3. Fit a simple per-repo model (possibly LogNormal or Weibull on interarrival times) using only release dates
4. Evaluate: does the predicted 50th-percentile window contain the actual next release date more than ~50% of the time? Does the 90th-percentile window contain it ~90% of the time?

**Pass criteria:** Calibration is reasonable (not perfectly, but better than "just use the mean gap"). If this is low quality, add PoC 2

### PoC 2 — PR/commit signals improve accuracy

**Goal:** Test whether adding PR merge rate or commit frequency tightens the prediction window.

**Method:**
1. Same 100 repos
2. Add features: with some of: PR creation, delay to comment, PR merge count. Ditto issues.Commit count, days since last pre-release tag
3. Train a simple gradient-boosted model (XGBoost or LightGBM) to predict days-to-next-release
4. Compare RMSE / calibration vs PoC 1 baseline

**Pass criteria:** Meaningful reduction in prediction interval width (e.g., 90th-percentile window narrows by >20%) for repos with active PR/commit history.

---

## Training inputs (for the mega-training)

Collect per-repo, per-release-cycle:

| Signal | Source | Notes |
|---|---|---|
| Release dates (all historical) | `/repos/{owner}/{repo}/releases` | Primary signal; compute interarrival times |
| Pre-release / RC tags | same | Leading indicator for stable release |
| PR merge rate (30/60/90d rolling) | `/repos/{owner}/{repo}/pulls?state=closed` | Velocity signal |
| Commit frequency (30/60/90d rolling) | `/repos/{owner}/{repo}/commits` | Activity signal |
| Open PR count | `/repos/{owner}/{repo}/pulls?state=open` | Backlog pressure |
| Open issue count | `/repos/{owner}/{repo}/issues?state=open` | Demand signal |
| Repo age / total release count | derived | Maturity; young repos are erratic |
| Release cadence label | derived | Classify: weekly / monthly / quarterly / irregular |
| Days since last stable release | derived | Right-censored input at query time |

**What to avoid collecting (for MVP):** contributor identity, commit message content, CI pass rates (too expensive to fetch at scale).

---

## Model architecture (post-PoC)

- **Per-cadence-class models**: cluster repos by release cadence (weekly, monthly, quarterly, irregular) and train separate survival models per class — avoids one model trying to fit both "releases every 7 days" and "releases every 18 months"
- **Survival regression** (e.g., DeepHit, CoxPH with tabular features, or a simple parametric AFT model) to output a full conditional survival curve, not just a point estimate
- **Output layer**: from the survival curve, extract the 50th and 90th conditional quantiles → map to the two-horizon UX statement

---

## v2 ideas

- **Plaintext changelogs**: repos that maintain a `CHANGELOG.md` or `CHANGES` file but don't use GitHub Releases — parse the file for dated entries
- **Community fork prediction**: given a stalled upstream, does an active fork have a higher probability of releasing first? (compare fork's PR velocity vs upstream's)
- **Ecosystem signals**: e.g., a major dependency just released — does that correlate with downstream release acceleration?
- **Watch mode**: subscribe to a repo, get notified when prediction window opens ("release likely in the next 5 days")
- **Dependency graph**: "when will project X release, given it depends on Y which hasn't released yet?"
