#ai-slop
# Continuous voting: voters pick a float, not a discrete option

Most voting systems (ranked-choice, approval, range) ask voters to rate or rank a fixed set of pre-defined options. **Continuous voting** is different: each voter submits any value on a continuous numeric scale, and the result is the median (or mean) of all inputs.

Example: instead of a ballot measure that passes a 2% property tax increase or fails and stays at 1%, every voter submits their ideal rate. The final rate is the median of all submissions.

Related term ChatGPT suggested: "liquid democracy" — though that's more about delegating votes than continuous value selection. No established term in voting theory matches this exactly.

## Why current binary votes create a "true dilemma"

The [false dilemma fallacy](https://en.wikipedia.org/wiki/False_dilemma) presents only two options when more exist. Binary voting makes this structural — not a rhetorical trick, but an actual constraint built into the process.

Tax rate deliberation is a spectrum (10%? 12%? 15%?), but it ultimately resolves to a yes/no vote on one specific number. Whoever frames the two options controls the outcome — this is called **agenda setting** in political science.

> "As long as I can pick the candidates, it doesn't matter what the voters vote on."

First-past-the-post amplifies this: voters can only express "who wins," not "how strongly" or "what value."

## Two orthogonal axes for policy decisions

Conflating these is a common source of confusion:

| Axis | Description | Examples |
|------|-------------|---------|
| **Numeric spectrum** | What value should the policy be set to? | Tax rate 10–20%, retry count 1–5 |
| **Intensity of support** | How strongly do participants feel about a proposal? | Strong agree → strong veto |

Most "consensus" and "range voting" discussions are about axis 2 (intensity). Continuous voting is specifically about axis 1.

**Range voting** — voters rate discrete options 0–10 — is still axis 2. The options are still pre-defined; you're only expressing intensity.

## The "vote 300%" problem

If voters can submit any number, strategic voters might submit extreme values to pull the median. Median aggregation is robust to outliers: a handful of 300% votes won't move the median much if most participants submit reasonable values. Mean aggregation is not robust in this way.

## Governance frameworks span from law to code

The continuous/binary distinction applies at every layer of a governance framework:

- **Organizational governance** — corporate policies, ethical guidelines
- **Operational governance** — day-to-day procedures (data handling, security)
- **Technical governance** — coding standards, API contracts (e.g., "clients must implement exponential backoff on HTTP 429")

At each layer, policies can be:
- **Binary** (you must / you must not) — easy to enforce, easy to audit
- **Spectrum** (recommended range, configurable threshold) — more flexible, harder to enforce uniformly

## Ex-ante vs. ex-post regulation

Related framing from policy/law:

- **Ex-ante** (before the event) — precautionary principle, proactive rules set before harm occurs. E.g., GDPR before widespread data abuse.
- **Ex-post** (after the event) — reactive rules triggered by an incident. E.g., "do not put plastic bag over your head" warnings.

Good policy is usually a mix: ex-ante for foreseeable harms, ex-post for surprises. The hard problem is calibrating when a risk is "foreseeable enough" to warrant proactive regulation — e.g., AI companies don't list psychological harm as a known risk in EULAs, partly because there's no formal clinical consensus.

## Related

- [[Internet adages and named laws]] — false dilemma, Goodhart's law
- [[uncertainty]] — significant figures, probability ranges as continuous outputs
