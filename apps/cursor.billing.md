## Current Usage Structure as of 2026-05-20

See https://cursor.com/docs/models-and-pricing which has current table of pricing.
- [ ] make a google sheet with conditional formatting

## Historical: Request Units as of 2026-05-14

> [!HISTORY]
> Notes for how Cursor billing works for me. Each time you hit `[ENTER]` to send a new reply uses Requests. If you are at the monthly limit, then you start on-demand billing based on token costs. As long as I stay under the monthly request quota (e.g. 500/month), I don't care if a single request consumes huge token counts.
>
> A long, multi-turn question-session in Cursor counts as **1 request** in [the usage dashboard](https://cursor.com/dashboard/usage), even when the agent and I exchange dozens of question/answer rounds inside that turn.
>
> Per [Cursor's pricing policy](https://cursor.com/terms/pricing), on-demand usage is technically based on **Total Tokens** (input + output + cache read/write). For my work's Cursor setup, the dashboard still exposes a request-like included-usage meter, so I am incentivized to optimize for fewer user turns.
>
> ## Long Q&A Sessions Still Count as 1 Request
> I tested this with a Python→Node migration spec session: ~14 questions in one AI response, my answers inline, then ~5 follow-ups, all within the same chat. Dashboard recorded **1 request**.
> The currently observed behavior means [[spec-driven-design]] workflows *where the agent batches all clarifying questions* are essentially "free" past the first request. The cost is wall-clock time, not requests.
>
> ## Request Multipliers Per Model
> Observed from CSV usage events. Each event = one user turn + agent response.
>
> Cursor’s [current pricing policy](https://cursor.com/terms/pricing) says model/API fees are calculated from **Total Tokens** across input, output, and cache read/write tasks, not simply “one chat bubble equals one flat request.” ...so I guess my usage limits might not be tied directly to my work's costs?
> ### Request Units as of 2025-05
> This is empirical from my CSV export:
>
> | Model                            | Requests / turn |
> | -------------------------------- | --------------- |
> | `auto`                           | 0-1             |
> | `claude-4.6-sonnet-medium`       | 1               |
> | `claude-4.6-opus-high-thinking`  | 2               |
> | `claude-4.6-opus-high`           | 1               |
> | `claude-opus-4-7-thinking-xhigh` | **1**           |
> | `composer-2-fast`                | **2**           |
> | `composer-2`                     | 1               |
> | `gpt-5.4-medium`                 | 0-1             |
> | `gpt-5.5-medium`                 | 2               |
>
> Notable: `claude-opus-4-7-thinking-xhigh` (highest reasoning tier on Opus 4.7) costs only 1 request, while older `claude-4.6-opus-high-thinking` costs 2. Picking the newer Opus is strictly cheaper for max-reasoning work.
>
> `composer-2-fast` being 2x the cost of `composer-2` is counter-intuitive if you assumed it was doing less work (the "fast" variant costs more, not less).

## Spec-driven loop with `code --wait`
This is an interesting solution, but **useless** for now.
The `code --wait` CLI flag holds the shell open until the file is closed. An agent skill could leverage this for human-in-the-loop questioning inside a single agent turn:

```text
Cursor agent starts task
  → writes questions to .cursor/spec-questions.md
  → runs: code --wait .cursor/spec-questions.md
    → I edit answers, save, close
    → code command returns
  → agent reads answers, continues loop
```

This **saves interaction turns** (one request even with many Q&A rounds), but does **not** save tokens — the agent still re-processes context each loop. Per Cursor's pricing, that token usage is real even when "Requests" stays at 1.

But whether you use Q&A or `code --wait`: ask all blocking spec questions in **one batch**, not a series of small ones, to minimize both turns and re-processed context.

## After hitting the monthly request limit
Auto model selection keeps working without additional usage-based pricing. So 500 requests/month is a soft ceiling — past it, work continues on Auto-routed models at no extra cost (just possibly lower-tier model selection).

## Unverified

- Whether the `0` rows are only free after exhausting 500 requests.
- Whether `composer-2-fast = 2 requests` is a billing bug, a documentation gap, or intentional (paying 2x for lower latency)
- Whether AI-comparable "request multipliers" advertised elsewhere (e.g. ChatGPT-derived numbers like Gemini-3-Flash 0.5x, Opus 5x) match Cursor's actual billing — they did not match my dashboard last time I checked
