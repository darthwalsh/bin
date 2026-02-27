#ai-slop 
# My Default Assumptions for Tool Evaluation

These are extracted patterns from my past behavior when evaluating software and solving problems. These should be used as starting defaults for AI planning, but they're explicitly editable when the context changes.

## User & Operational Model

**Single developer-operator**
- I am the only user, developer, and operator
- No role separation or permissions matrix needed
- No "hand-off" UX or onboarding flows
- Debuggability matters more than polish
- Cognitive overhead is more expensive than guardrails

**Solo context implications:**
- Skip multi-user features unless explicitly needed
- Skip shared state management
- Skip admin dashboards or user management
- Optimize for understanding over automation

## State & Persistence Philosophy

**Ephemeral > Durable**
- Avoid introducing persistence unless core to the problem
- Prefer recomputable artifacts over stored state
- Prefer derivation over persistence
- State has operational tax: justify every database

**When state is needed:**
- Keep it minimal and obvious
- Externally managed when possible (files, URLs, APIs over schemas)
- Prefer append-only or read-only models
- Prefer stateless or near-stateless components

## Tool Selection Philosophy

**Thinking tools, not products**
- Optimize for clarity and leverage for expert users, not scale to novices
- Value transparency over convenience
- Value explicit configuration over magic conventions

**Evaluation priorities:**
- CLI > GUI (when appropriate for task)
- Text > dashboards
- Explicit > implicit
- Transparent > convenient

**What matters in dependencies:**
- Repository health and maintainer behavior
- License philosophy and implications
- Conceptual cleanliness and reasonability
- Not: team features, enterprise roadmaps, vendor support

**What to avoid:**
- Opaque SaaS when self-hosted works
- Magic behavior without explanation
- Excessive abstraction layers
- Marketing-driven design choices

## Requirements & Planning Approach

**Requirements are hypotheses, not contracts**
- Keep requirements editable throughout
- Work from explicit, labeled assumptions
- Expect revision without shame
- Preserve decision rationale for later editing

**Avoid:**
- Early commitments that harden prematurely
- "Best practice" dogma without context
- Assuming first framing is final
- Hiding tradeoffs behind false precision

## Evaluation Criteria Structure

**Three-layer separation: Universal → Contextual → Personal**

**Layer 1: Universal risk signals (objective)**
- Report factual signals everyone should care about
- Time since last commit/release
- Issue response patterns
- PR merge vs abandonment rates
- Bus factor / contributor concentration
- License clarity

**Layer 2: Context-sensitive tradeoffs (depends on project type)**
- Adjust expectations by project category
- Library vs service vs tool vs framework
- "Done" vs actively evolving
- Popular-therefore-many-issues vs neglected
- Call out mismatches between claimed type and behavior

**Layer 3: Personal taste & project fit (explicitly subjective)**
- Apply personal preferences last, transparently
- Preferred licenses and governance styles
- Corporate-backed vs community preference
- Dependency footprint tolerance
- Release philosophy alignment

**Critical: Keep these layers separate**
- Never conflate objective signals with subjective preferences
- Never collapse into single score without showing work
- Let preferences be re-weighted independently

## AI Agent Behavior Preferences

**What good agents do:**
- Restate the problem before solving it
- Label assumptions clearly and early
- Flag dangerous assumptions instead of burying them
- Separate facts from interpretation
- Keep taste separate from structural risk
- Know that "best" is meaningless without context

**What agents should avoid:**
- Single "health scores" without context
- Hiding tradeoffs behind math
- Confusing popularity with reliability
- Pretending long-lived low-activity is "dead"
- Asking for complete requirements upfront
- Treating all projects as comparable

**Agent stance-switching (modes):**
- **Exploration mode** when confused about what problem we're solving
  - Expands problem space
  - Questions hidden assumptions
  - Surfaces alternatives
  - Resists premature commitment
- **Commitment mode** when confused about how to solve it
  - Narrows scope
  - Freezes assumptions (temporarily)
  - Optimizes for tractability
  - Turns ambiguity into decisions

**When to switch modes:**
- Based on uncertainty gradient, not time
- "Are we confused about the question or the answer?"
- Switch should be explicit and explained

## Problem Framing Process

**Step zero: problem framing before evaluation**
- Start with one-sentence problem description OR concrete tool
- If given a tool: infer the problem it claims to solve
- Treat tool's constraints as hypotheses, not facts
- Avoid anchoring bias

**First deliverable: scoped tool brief**
- One-paragraph problem restatement (tighter than original)
- Core responsibilities (must-haves)
- Explicit non-goals
- "This matters later" axes (scale, trust boundary, extensibility)
- Not a full PRD or shopping list

**Why scope matters:**
- Maintenance signals weighted differently by category
- Release cadence expectations shift by type
- Contributor counts mean different things
- License impact varies by embedding vs deployment

## Design Values

**Behavioral signals > vanity metrics**
- Evidence of human attention over time
- Not: lines of code, test coverage badges, README length
- Yes: commit recency, PR review behavior, issue responsiveness

**Careful engineering culture**
- Restates problems before solving
- Highlights top-3 concerning metrics, not averages
- Humans reason comparatively, not numerically
- Narrative judgment over ranking algorithms

**Working theory approach**
- Proceed with labeled hypotheses
- Don't block on complete requirements
- Surface "assumptions I'm making" rather than endless questions
- Let validation come from usage, not upfront specification
