---
aliases:
  - AI Reasoning, AI Tiers
---
A thoughtful mid-tier model often beats a large model with no thinking budget on complex tasks.

Three dials govern response quality:
- which **model tier**: small/medium/large
- whether **thinking** is enabled
- **effort** controls thinking depth and tool call frequency

## Model Tier Hierarchy
Each provider has a small/medium/large family. The tiers reflect cost/speed/capability tradeoffs, not separate technologies.

| Tier   | Claude | OpenAI       | Gemini           | Best for                                   |
| ------ | ------ | ------------ | ---------------- | ------------------------------------------ |
| Small  | Haiku  | gpt-4o-mini  | Flash            | High-volume, simple tasks                  |
| Medium | Sonnet | gpt-4o       | Flash (thinking) | Default choice for most coding and writing |
| Large  | Opus   | o3 / GPT-5.4 | Pro / Deep Think | Hard problems medium can't solve           |

## Thinking Is a Scratchpad
Without thinking: the model reads your prompt and immediately generates tokens. It can't backtrack. Whatever direction it commits to in the first sentence, it's stuck with. Consider when Gemini AI Chat says "Hold on, let me restart."
Useful for: "rename this variable," "add a docstring," "explain what this line does."

With thinking: the model outputs an internal reasoning block first, explores dead ends, reconsiders, then produces a final answer. In Claude's API you literally get back a separate `thinking` block + a `text` block. You pay for those scratchpad tokens even though they're not the final answer.
Useful for: math, multi-step code logic, planning a refactor, editorial judgment across many documents.

### Claude
**Newer models (Sonnet 4.6, Opus 4.6):** adaptive thinking — Claude decides whether and how much to think based on task complexity. Pair with `effort`:

| `effort` | Thinking | Tool calls | Best for |
|----------|----------|------------|----------|
| `"max"` (Opus only) | Maximum | Maximum | Deepest reasoning tasks |
| `"high"` (default) | High | High | Complex coding, agentic tasks |
| `"medium"` | Moderate | Fewer | Agentic tasks balancing speed/cost |
| `"low"` | Minimal | Fewest | Simple tasks, subagents |

`effort` is a behavioral signal, not a strict token budget — Claude still thinks on hard problems at `"low"`, just less. It affects thinking depth and tool call frequency together; there's no separate tool-use dial.

**Older models (Sonnet 4.5 and earlier):** explicit `budget_tokens` — a token cap for the thinking scratchpad. Minimum 1,024; diminishing returns above ~32k tokens.

### OpenAI
OpenAI's reasoning capability lives in a **separate model family** (o1 → o3 → o4-mini) rather than as a parameter on GPT-4o. These models use `reasoning_effort`: `"low"`, `"medium"`, or `"high"` — same parameter covers tool/function call depth in agentic workflows. The reasoning scratchpad is completely hidden; no visibility into it for debugging.

The separation exists because reasoning models are fundamentally slower (30–120s for hard problems) — not suited for fast/real-time tasks where GPT-4o is the right call.

**GPT-5.4 (March 2026)** starts to unify this: it's described as the first mainline OpenAI model with an `effort` parameter and 1.05M token context. (**Unverified**: sourced from third-party summary, not confirmed against [platform.openai.com](https://platform.openai.com/docs/guides/latest-model).)

### Gemini
**Gemini 3 models (2026):** `thinkingLevel` — `"minimal"`, `"low"`, `"medium"`, `"high"`. Optionally add `include_thoughts: true` to get thought summaries in the response (analogous to Claude's visible `thinking` block).

**Gemini 2.5 models:** `thinkingBudget` — token count 0–24,576 (0 disables thinking; -1 = automatic).

Gemini doesn't expose a separate tool-use dial; thinking parameters govern the overall effort level. Cost impact is sharp: thinking-enabled Gemini 2.5 Flash costs ~6x more per output token than thinking-disabled.

### In the IDE (Cursor, Claude Code)
When Cursor shows "medium reasoning effort," it's translating these API parameters into something human-readable. The underlying API call is provider-specific. You can't set `budget_tokens` directly in Cursor — you pick a model + effort level from their UI and the IDE handles the rest.

## Choosing for Your Task

| Task                                                    | Model                    | Thinking?      | Why                                                                            |
| ------------------------------------------------------- | ------------------------ | -------------- | ------------------------------------------------------------------------------ |
| Trace API call flow through a large codebase            | Sonnet / gpt-4o          | Optional       | Context window is the constraint; thinking helps with complex async chains     |
| Fix failing test, get linter + type checker passing     | Sonnet + Claude Code CLI | Yes (adaptive) | Multi-step agentic loop; each fix needs to reason about downstream breakage    |
| Restructure Zettelkasten notes, find wrong abstractions | Sonnet or Opus           | Yes            | Editorial judgment task; needs to reason about what makes a "good" atomic note |
| Apply Python code formating rules                       | None!                    | n/a            | AI Agent instructions say e.g. run `ruff format` - not a job for AI!           |

## Context Window Nuance
Thinking blocks from previous turns are stripped and not re-sent in subsequent turns, so multi-turn conversations with thinking don't balloon context as fast as you'd expect.

