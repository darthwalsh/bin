# Kid-Appropriate Movie Ranking Tool — PLAN

## Problem

Parents frequently encounter movies they thought would be fine but turned out to contain a scene that was too frightening, too sad, or too mature for their specific child. Generic ratings (G, PG) don't capture this, especially for a "G" movie our parents grew up with! The goal is a tool that lets parents calibrate against movies they already know — ones their kid loved, and ones that were too much — and infer a safe list from that.

**Core insight:** Intensity scores let you treat movie selection as a threshold problem. A parent isn't rating "movies in general" — they're locating their child's sensitivity floor in 2–3 dimensions (scary, sad, violent), and finding movies that stay under it.

**Assumptions (editable):**
- Initial movie catalog is focused on two cohorts: (1) movies kids are currently excited to see, (2) movies millennials grew up with where the "that one scene" is forgotten
- Scores exist and are accurate enough to be directionally useful
- Parents can identify 2–4 calibration movies by name without help
- A single "max" aggregation across intensity sub-scores is a reasonable default ranking signal (spike needed)
- The product's core value is the calibration workflow, not the catalog size

---

## Competitive Analysis

**Does anything already solve this?**

Short answer: no. Existing tools either give you reference data (read-only) or let you mute/skip scenes in real time. None do parent-calibrated threshold inference from known movies.

### Common Sense Media

- **What it does:** Expert-written reviews with dimension scores (0–5 scale) for Violence & Scariness, Language, Sex/Nudity, Drinking/Drugs, Positive Role Models, Diverse Representations, etc. Per-title "youngest appropriate age" label. Mobile app available.
- **Fine-grained age ratings:** Has age brackets (2+, 5+, 7+, etc.) but these are editorial judgments, not calibration from *your child's* known reactions.
- **API:** Exists (`api.commonsense.org/api/v3`) but gated behind a partnership agreement. Not self-serve for hobbyists.
- **Gap — the calibration problem:** Common Sense Media (CSM) doesn't know that *your* 5-year-old was fine with *Moana* but fell apart at *Finding Nemo*. Their "age 5+" is a population average, not specific to a child's sensitivity profile. You can't say "my kid handled X — what else is at that level?"
- **Gap — dimension sensitivity:** CSM gives you Violence & Scariness as one combined bucket. A parent who's worried about jump scares but not sad endings can't filter on that distinction. Profanity-sensitive families can't easily tune "language" up without raising everything else.
- **Gap — the millennial nostalgia problem:** CSM reviews are accurate but you have to search per-title. There's no "show me everything from your childhood that has a scene parents tend to forget about" view.
- **Verdict:** Best available data source for scores. Not a replacement for the calibration workflow.

### Screenwise

- **What it does:** 5-minute survey about your family's values → curated recommendations. Free, anonymous.
- **Gap:** Survey is static/one-time; not anchored to movies you already know. No "I know Luca was fine, what else like it?" Can't explain why a movie was or wasn't recommended.
- **Verdict:** Closer in spirit but still population-level recommendations, not child-specific calibration.
- [ ] Try [this](https://screenwiseapp.com/learn)

### Kids-In-Mind

- **What it does:** Blunt 1–10 scores for Sex/Nudity (S), Violence/Gore (V), and Profanity (L). Clinical, no narrative. Free, no login.
- **Gap:** Read-only reference only — no filtering UI, no recommendations, no calibration. Three fixed dimensions; no sad/emotional weight, no jump-scares distinction.
- **Verdict:** Useful data source. Not a product.

### VidAngel ($9.99/month)

- **What it does:** Real-time scene-level skipping/muting across Netflix, Prime, Peacock, Apple TV+. Highly granular filters (kissing subcategories, specific language types, etc.).
- **Gap:** Reactive tool (mutes bad things) rather than predictive (recommends safe things). Requires active subscription per stream. No "what should I watch next?" feature.
- **Gap — catalog:** Works on streaming content, not a browse/discover interface. Doesn't solve "what movie should we put on tonight?"
- **Verdict:** Compelling v3 spike — their scene-level intensity data may map to score signals. Not a replacement for the recommendation workflow.

### JustWatch

- **What it does:** Streaming aggregator — where to watch any movie, across services. Parental controls exist only as MPAA rating filter.
- **Verdict:** No sensitivity features at all.

### The gap nobody fills

The specific combination that doesn't exist:
1. Parent inputs 2–4 movies they already know (calibration anchors)
2. App infers child's sensitivity thresholds per dimension from those anchors
3. App ranks/filters a curated catalog against those thresholds
4. Curated "millennial nostalgia" cohort — movies adults assume are fine but aren't

**→ Worth building.** But confirm CSM's API access terms before assuming it's a usable data source (see Spike 0).

---

## MVP

**Goal:** Validate product fit. Can parents calibrate their child's thresholds using movies they already know, and get a useful recommendation from that?

**Success metric:** A parent sits down, enters 2 "too scary" and 2 "fine" movies, and the recommendations feel correct to them without explanation.

### MVP Features

- Static HTML + Tailwind (CDN, no build step required)
- Movies JSON file: ~50 curated movies (current-excitement + millennial-nostalgia cohorts), with basic intensity scores 
	- i.e. `scary`, `sad`, `violence`
- Calibration UI: parent marks movies as "Fine for us" or "Too much"
- Threshold engine: derive per-dimension thresholds from calibration inputs; filter the movie list
- Display: responsive poster grid (2-col mobile, 5-col desktop), movie title, year
- LocalStorage: remember calibration across sessions
- Posters from TMDB (pre-fetched URLs baked into movies.json at data-prep time, not runtime API calls)
- Plain white theme is fine

### MVP Spikes (before building)

See Spikes section below.

### MVP Non-goals (moved to v2/v3)

- Search by title
- "Why was this hidden/ranked too scary?" explanations
- "This or That" quiz workflow
- Toast notifications on calibration actions
- Sub-reason refinement ("Was it the shark or the separation?")
- Score breakdown UI (showing raw numbers to parents)
- Any server-side component
- User accounts or sharing
- Filtering by category/genre
- More than ~50 movies at launch
- Adding movies not in the initial curated list

---

## v2 great things to add

- Expand to ~200 movies (full Disney/Pixar + popular non-Disney family films)
- "This or That" calibration game: show two movies, ask which was more appropriate, tighten threshold
- Sub-reason refinement: "Was it the shark or the separation?" → adjust per-dimension weight
- Toast/inline feedback: "I've hidden 12 movies more intense than this one"
- Score breakdown: parent can optionally view raw dimension scores
- Trigger tags: `["sharks", "death of a parent", "loud noises"]` shown on hover or card flip
- Export/share: URL-encoded threshold state (no server needed, just query params)

---

## v3 trickier ideas

- Title search: find any movie (e.g., Terminator 1 vs Terminator 2) and see dimension scores side-by-side
- Per-movie scene breakdown: "Scene 3 of 8: The shark attack — Scary: 9, Duration: ~2min"
- VidAngel investigation spike: does their scene-level skip data map to intensity deltas? (e.g., "skip this 5 seconds and the fright score drops from 8 to 5")
- Problematic content dimensions: harmful tropes, representation issues, outdated biases (beyond scary/violent)
- Community score layer: parent-submitted scores to supplement or override AI-generated baseline

---

## Spikes

Spikes follow PoC conventions: single question, straight-line code, placed in `poc/`, conclusion documented.

### Spike 0: Competitive / data source due diligence

**Question:** Before building anything, confirm: (a) does any competitor actually solve the calibration problem in a way that would make this redundant? (b) what data sources are legally and practically usable? (c) what data sources are technically/practically useful?

**Sub-questions to answer:**

| Question | Where to look | Risk if wrong |
|---|---|---|
| Does CSM's API require a paid partnership, or is there a free tier? | `commonsensemedia.org/developers` | If paywalled, can't use it as live data source |
| Does CSM's API return per-dimension numeric scores (not just age label)? | API docs / v3 endpoint schema | If it only returns age label, it's useless for threshold logic |
| Does Kids-In-Mind have a ToS prohibition on scraping? | `kids-in-mind.com` ToS | If prohibited, can't automate score collection |
| Does Screenwise do calibration from known movies, or just surveys? | `screenwiseapp.com/learn` survey flow | If yes, reduces differentiation |
| Does VidAngel expose scene-level data anywhere (export, API, public page)? | VidAngel help docs + web source | This is the v3 data question, good to answer early |

**Conclusion to document:**
- Which data sources are usable, and under what constraints
- Whether any competitor makes this product redundant
- Recommended data strategy for MVP scores (manual CSM lookup / LLM-gen / TMDB keyword parse)

---

### Spike 1: Where do intensity scores come from?

**Question:** What is the lowest-effort, highest-accuracy way to get 50 movies' worth of intensity scores (`scary`, `sad`, `violence`, 1–10)?

**Options to investigate:**

| Source                      | Method                                                               | Accuracy risk                                        | Effort                        |
| --------------------------- | -------------------------------------------------------------------- | ---------------------------------------------------- | ----------------------------- |
| Common Sense Media (manual) | ~60 films, 1–5 star Violence/Scariness → ×2 for 1–10 scale           | High accuracy                                        | ~1–2 hours manual lookup      |
| LLM generation              | Prompt for JSON with scores "based on Common Sense Media guidelines" | AI hallucination risk on edge cases (e.g., Coraline) | Minutes, but needs spot-check |
| TMDB content descriptors    | Keyword parse: "Intense" → 8, "Mild" → 3, "Peril" → +2               | Inconsistent string formats                          | Script needed                 |
| Kids-In-Mind scrape         | Already has 1–10 Violence/Gore                                       | ToS risk, no public API                              | Fragile                       |
- [ ] By trying all of these options for a sample of movies, we can see if the low-effort methods will have enough quality

**PoC file:** `poc/intensity_scores_poc.md`  
**Conclusion to document:** Which source produces scores that match parent intuition when spot-checked against 5–6 well-known movies? Which dimensions should we actually use?

---

### Spike 2: Rank-ordering with multiple intensity dimensions

**Question:** Is `max(scary, sad, violence)` a good enough aggregation to produce a rank order that matches parent judgment?
How to include individual child's scores? is it `scary = base_scary - child_baseline_scary`

**Risk:** A movie that is very sad but not at all scary might be ranked higher than a movie that has one intense fright scene. Max() collapses these differently than a weighted average would. Wrong aggregation → recommendations that feel broken.

**PoC approach (no app needed):**
- Take 10–15 movies with known scores across 3 dimensions
- Print a rank order using `max()`, then `avg()`, then `weighted avg` 
	- For weight, asking the parent for multipliers based on their kid relative to peers and the parent's own priorities: "Charlie is 3 y.o,., but for fright is scare of movies like other 2 y.o. we see? Can handle sad scenes like peers. In our family, we want to see swearing reduced compared to typical media"
- Sit down with 1–2 other parents who know these movies well
- Ask: "Does this ranking feel right? What would you swap?"
- Document which aggregation best matched intuition

**Questions to resolve:**
- Does `max()` over-penalize movies with one scary moment but otherwise gentle?  
- Should sadness be weighted less than fear for younger kids?
- Is there a child-age modifier? (sad matters more at 4, scary matters more at 7?)

**Conclusion to document:** Which aggregation method survives the parent sanity-test? Note any cases that all methods got wrong.

---

### Spike 3: TMDB poster fetch

**Question:** Given a list of 50 movie titles, can I reliably get `tmdb_id` and `poster_path` from TMDB's free API with a one-time script?

**Output:** A `movies.json` snippet for 5 movies with `tmdb_id`, `poster_url`, and placeholder scores.  
**Conclusion to document:** Does TMDB's search return correct results for Disney titles? Any disambiguation failures (e.g., Cinderella 1950 vs 2015)?

---

## Tech Stack

- **HTML + Tailwind CSS (CDN)**: no build step, no Node toolchain required for MVP
- **Vanilla JS**: threshold filter logic; localStorage persistence
- **movies.json**: local data file, baked at data-prep time. No runtime API calls.
- **TMDB API**: one-time use at data-prep time only (not at runtime)
- **Hosting**: GitHub Pages

**Dark mode anti-FOUC pattern:**

```html
<script>
  if (localStorage.theme === 'dark' ||
      (!('theme' in localStorage) && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
    document.documentElement.classList.add('dark');
  }
</script>
```

Place this in `<head>` before any CSS link tags. Tailwind dark mode must be set to `'class'` mode.

---

## Movie Catalog Curation Notes

Two cohorts for initial list of ~50:

**Cohort 1 — Currently exciting to kids**
- Movies kids are actively asking to see now (theater releases, recent Disney+)
- Source: current box office + Disney+ new releases

**Cohort 2 — Millennial nostalgia with "that one scene"**
- Movies adults remember fondly but forget had a traumatizing moment
- Examples: The Lion King (stampede), Finding Nemo (opening), Pinocchio (Pleasure Island), Bambi, Snow White, Fantasia
- The whole point is surfacing these so a parent doesn't discover the scene alongside their 4-year-old

**v3 expansion:** Any movie by title. Terminator 1 and Terminator 2 would show different stats because their scene-level intensity differs significantly.

---

## Related Resources

- **Common Sense Media** — best existing data source for intensity; no public API but manually usable for ~50 films
- **Kids-In-Mind** — 1–10 scores for Violence/Gore/Profanity; more clinical
- **TMDB API** — free, for poster artwork and content descriptors
- **VidAngel** (v3 spike) — scene-level skip data; investigate whether their data could drive scene-level intensity deltas

---

## Open Questions / Risks

- **Score accuracy**: AI-generated scores may be wrong on edge cases. Spot-check against CSM before publishing.
- **Aggregation**: `max()` is the simplest but may produce counterintuitive results. Needs parent sanity-test (Spike 2).
- **Catalog size at launch**: 50 movies may feel thin. If calibration movies aren't in the list, the whole workflow fails.
- **ToS**: TMDB allows non-commercial use; CSM has no public API — don't scrape.
