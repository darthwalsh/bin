# Tool Search & Evaluation Cursor Skill

## Goal

Create a Cursor skill that helps drill into tool selection by:
1. Understanding the scope and constraints of the problem
2. Having the AI evaluate different ways to solve it
3. Applying my personal defaults and preferences appropriately
4. Separating universal signals from context-sensitive tradeoffs from personal taste

## Why This Needs a Skill

Tool evaluation is currently ad-hoc. Each time I ask an AI "what tool should I use for X", it:
- Re-learns my preferences
- Skips problem scoping
- Jumps straight to recommendations
- Mixes objective and subjective criteria
- Doesn't know when to explore vs commit

A skill codifies:
- The **process** for scoping before recommending
- My **default assumptions** (from `my-assumptions.md`)
- The **three-layer evaluation framework** (universal → contextual → personal)
- When to **switch cognitive stances** (exploration vs commitment)

## Entry Points (Two Modes)

### Mode 1: Problem description
User provides one-sentence problem statement:
> "I need a tool to manage background jobs"

Agent's job:
- Expand sentence into scoped problem model
- Answer: What category? What's in scope? What's out of scope? What assumptions are dangerous?
- Deliver: scoped tool brief (not full PRD)

### Mode 2: Concrete tool + alternatives
User provides a specific tool they found:
> "I found Celery, looking for alternatives"

Agent's job:
- Infer the problem Celery claims to solve
- Extract Celery's philosophy and constraints as hypotheses (not facts)
- Avoid anchoring bias
- Deliver: same scoped tool brief

**Both modes normalize to same internal shape before evaluation**

## Phase 1: Problem Scoping (Exploration Mode)

### Agent stance: Exploration
- Expand problem space
- Surface alternatives and adjacent framings
- Question hidden assumptions
- Resist premature commitment

### Deliverable: Scoped Tool Brief
Structure:
```markdown
## Problem Restatement
[One paragraph, tighter than original]

## Category
[Queue? Scheduler? Build tool? Auth? CLI? Analytics?]

## Core Responsibilities (must-haves)
- [Thing 1]
- [Thing 2]

## Explicit Non-Goals
- [Out of scope thing 1]
- [Out of scope thing 2]

## Matters Later (axes to track)
- Scale expectations
- Trust boundaries
- Extensibility needs
- [etc]

## Working Assumptions (labeled as provisional)
- [Assumption 1]
- [Assumption 2]
```

### Apply Default Assumptions
Load from `my-assumptions.md` and apply:
- Single developer-operator (unless user overrides)
- Avoid persistence unless core
- CLI > GUI (when appropriate)
- Stateless preferred
- etc.

**Show applied defaults explicitly:**
> "Based on your typical workflow, I'm assuming: [list defaults]. Override any that don't apply here."

## Phase 2: Candidate Discovery

### Search Strategy
1. **Use repo-stats.ps1 pattern** for GitHub repositories
2. **Three-layer evaluation** from the start

### Layer 1: Universal Health Signals (Objective)
For each candidate, gather:
- Time since last release/commit
- Issue response latency (median)
- PRs: merged vs abandoned ratio
- Contributor concentration (bus factor)
- License clarity
- Activity pattern (done vs abandoned vs evolving)

**Report factually, no judgment yet:**
> "Last commit: 2 months ago. 15 open PRs, 12 merged in last 6 months. 3 core contributors."

### Layer 2: Context-Sensitive Tradeoffs
Adjust expectations by:
- Project category (from scoped brief)
- Type of tool (library vs service vs CLI)
- Maturity signals ("done" libraries vs active frameworks)

**Agent job:**
- Classify each candidate
- Call out mismatches: "This looks like a library but behaves like a prototype"
- Note tradeoffs: "Slow commits might be fine for a done library, concerning for an API client"

**Still no final scores**

### Layer 3: Personal Taste & Project Fit
Apply my preferences from `my-assumptions.md`:
- License preferences
- Corporate vs community preference
- Dependency footprint tolerance
- Governance style
- Release philosophy alignment

**Apply transparently:**
> "Filtering by your license preference (permissive > copyleft)..."
> "You typically prefer community-driven over corporate-backed..."

**Keep this layer editable**

## Phase 3: Evaluation Output (Commitment Mode)

### Agent stance: Commitment
- Stop re-litigating scope
- Lock in working assumptions
- Evaluate against frozen criteria
- Treat deviations as risks

### Deliverable: Comparative Analysis

```markdown
## Top 3 Candidates

### Candidate A
**Universal signals:**
- ✅ Active: last commit 5 days ago
- ✅ Responsive: median issue response < 2 days
- ⚠️  Bus factor: 1 primary maintainer

**Context fit:**
- Category: Queue library
- Maturity: Active development
- ⚠️  Release cadence: ad-hoc (not semantic versioning)

**Personal fit:**
- ✅ License: MIT (permissive)
- ✅ Community-driven
- ❌ Heavy dependency footprint (15+ deps)

**Top 3 concerns:**
1. Bus factor risk
2. Dependency bloat
3. Release philosophy mismatch

[Repeat for B and C]
```

### Output Format Principles
- Highlight **outliers and risks**, not averages
- Show "top 3 concerning metrics" per candidate
- Humans reason comparatively, not numerically
- Never emit single "health score" without context
- Narrative judgment, not ranking algorithm

## Stance Switching Rules

### When to stay in Exploration
- Disagreement about what problem we're solving
- Category unclear
- Scope keeps expanding
- User questions assumptions

### When to switch to Commitment
- Scope is stable
- Core requirements agreed
- Now evaluating specific options
- Disagreement is about "how well" not "what"

**Switching signal:**
> "I'm switching to commitment mode now that we've scoped the problem. Let me evaluate candidates against these criteria..."

## Integration Points

### Load My Defaults
At skill start:
```
Read: /Users/walshca/code/bin/apps/my-assumptions.md
Parse and apply default assumptions
Show user which defaults are active
```

### Use repo-stats.ps1
For GitHub candidates:
```powershell
repo-stats owner/repo
# Parses: stars, forks, issues, watchers, default branch, archived, contributors
```

Extend with GitHub API for:
- Commit recency
- PR stats
- Issue response times
- Contributor distribution

### Reference Related Patterns
- `PluginPhilosophy.md` — evaluation criteria framework
- `FossUserVoice.md` — maintainer communication patterns
- `security as a feature.md` — dependency risk philosophy

## Skill Interaction Flow

```
User: "I need a tool for X"
  ↓
Agent [Exploration]: Problem scoping
  → Load my-assumptions.md
  → Apply defaults (show which)
  → Expand problem space
  → Ask clarifying questions (if needed)
  → Deliver: Scoped Tool Brief
  ↓
User: [approves scope or adjusts]
  ↓
Agent [Exploration→Commitment]: Candidate discovery
  → "Switching to commitment mode"
  → Search for candidates
  → Gather Layer 1 (universal) signals
  → Classify for Layer 2 (context)
  → Apply Layer 3 (personal)
  ↓
Agent: Comparative analysis
  → Top 3 candidates
  → Top 3 concerns per candidate
  → Tradeoffs explained
  → No single scores
  ↓
User: Decision or request deep-dive
```

## Non-Goals

### Don't
- Create a scoring algorithm
- Hide tradeoffs behind math
- Confuse popularity with reliability
- Treat all projects as comparable
- Ask user to enumerate complete requirements upfront
- Pretend to be objective while applying taste
- Double-evaluate receivers (wrong domain, but principle applies)

### Do
- Make stance explicit
- Label assumptions
- Separate fact from preference
- Show top concerns, not averages
- Let user re-weight preferences
- Behave like careful engineer, not recommender system

## Testing Strategy

### Golden examples to validate
1. "I need a Python task queue" → Should scope around durable/ephemeral, dev/ops, latency/throughput
2. "Alternative to Celery" → Should extract Celery assumptions and challenge them
3. "Obsidian plugin for X" → Should apply plugin evaluation criteria
4. "CLI tool for Y" → Should prefer stateless, single-user defaults

### Validation criteria
- Does it scope before recommending?
- Does it load and show my defaults?
- Does it separate three layers?
- Does it switch stances appropriately?
- Does it avoid single scores?
- Does it show top-3 concerns?

## Implementation Notes

### Skill file structure
```
tool-search/
├── SKILL.md              # Main skill entry point
├── my-assumptions.md     # Loaded at runtime
└── examples/
    ├── task-queue.md     # Example session
    └── plugin-eval.md    # Example session
```

### SKILL.md should contain
- When to use this skill
- Entry point detection (problem vs tool)
- Phase structure (scope → discover → evaluate)
- Stance switching rules
- Output format templates
- Integration with my-assumptions.md

### Future enhancements
- Auto-update repo-stats for candidates
- Cache evaluation results
- Track decision rationale over time
- Learn from my actual choices (supervised feedback)

## Success Metrics

### Good outcomes
- Fewer "oh I forgot to mention" moments
- Less re-explaining my preferences
- Better scoped problems before evaluation
- Clearer separation of risk vs taste
- Faster iteration on "what if we change X assumption"

### Signs of failure
- Still jumping to recommendations
- Mixing objective and subjective
- Asking for complete requirements
- Emitting scores without context
- Re-learning my workflow each time
