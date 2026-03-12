#ai-slop #app-idea 
# BackEnv — Visual Fermi Estimator
> Back-of-the-envelope unit calculations via conversation. You ramble; it tracks the units.

## The Problem
Many calculations could be inferred from an unsorted list of numbers-with-units, just using dimensional analysis, multiplying/dividing. Given a goal unit, the UX can show you the current unit result of the current list. Suppose the difference show `Length / Time^2` and you can add "Earth Gravity" to complete the inputs.

Standard calculators don't understand units. LLMs understand units but don't *show* you the structure. Wolfram Alpha are powerful but demands precise syntax.

The sweet spot—**conversational spoken input + live dimensional analysis on screen**—doesn't exist yet.

## Core Use Cases
- "How many grains of sugar per second am I burning while jogging?"
- "How heavy is a cloud?"
- "How many breaths does it take to fill this room?"

The user knows roughly what they want to compute, but doesn't know the full set of physical quantities they'll need—they discover them through conversation.

## UX Vision
1. **Speak or type a rambling problem statement.** No need to know the units in advance.
2. **Cards appear on screen** — one per identified physical quantity (speed, burn rate, energy density, grain mass…).
3. **Lines connect the cards** showing how multiplication/division flows. Units on the connecting arrows cancel visually (strikethrough or fade).
4. **Result card** shows the final unit and magnitude. Tweak any input card → downstream updates instantly.
5. At any point, ask a follow-up: "What if I weighed 150 lbs?" and the affected cards update.

The core insight: **you should see the unit cancellation happening**, not just get a number.

## Related Tools

The market is split into two camps that don't talk to each other:

| Camp | Example | What's missing |
| --- | --- | --- |
| Unit engines | Insect.sh, Frink | No conversational input, no visual flow |
| LLM calculators | Gemini, ChatGPT | Can make math errors; no persistent visual state |
| Visual node tools | Guesstimate | No unit database or dimensional analysis |
| Notepad calculators | Soulver, CalcNote | Text-only; no voice; no visual unit flow |

The gap is the **glue layer**: something that extracts variables from natural language and feeds them into a unit engine with a visual frontend.

## Scope: MVP
- Voice/text input → extract named quantities + values + [[unit-conversion]]
- Dimensional analysis engine (confirm unit cancellation is valid)
- Live node graph: quantity cards + connection arrows + result card
- Built-in constants for the most common Fermi problems (caloric density, body weight norms, speed of common activities, weights of everyday objects)
- One "tweak and recalculate" interaction

## Out of Scope (v1)
- Full physics unit database (can defer to Frink/GNU Units data files later)
- Uncertainty ranges (see [[uncertainty]] and Guesstimate for inspiration)
- Saving/sharing calculations

## Related
- [[Quantifying Risk with Micromort or Microlives.todo]] — same "physical quantity as daily life metric" pattern

## Prior Art / Tools to Evaluate
- [ ] [Insect.sh](https://insect.sh) — best dimensional analysis, text-only
- [ ] [Frink](https://frinklang.org/) — deepest unit DB, Android app available
- [ ] [Guesstimate](https://getguesstimate.com) — best visual node UX, no unit engine
- [ ] [Qalculate](https://qalculate.github.io/) — cross-platform, strong unit support
- [ ] [Pint](https://pint.readthedocs.io/en/stable/) — Python unit library; possible engine candidate

### Voice Programming context
I remember some Voice to Text computer programming language demonstration (on youtube? can't find it now)
