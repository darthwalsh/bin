# PoC (Proof-of-Concept) Coding

Goal: write the smallest, clearest thing that answers a single question:
“Does reality behave the way I think it does?”

## Rules (PoC-only)
- Optimize for **speed of insight**, not robustness.
- Keep it **legible, not abstract**: minimal logic/indirection; prefer straight-line code over scaffolding.
- Prefer **new, disposable code** over modifying production code.
- Put PoC code in `poc/` so it’s easy to delete after you have a conclusion.
- Strict scope discipline: anything not directly contributing to answering the question is noise — omit it.
  - Be strict about avoiding conditionals unless they are part of the code: all codepaths should be exercised.
  - **DO NOT** use error handling fallback that will obscure the actual intent of the project
  - Remove any error handling codepaths that might not be hit
- Outputs/docs should be lightweight:
  - State the **question**.
  - State the **conclusion** (what happened / what you observed).
  - If needed, state the **next experiment** (what to try next).

## Conventions
- Create a single file like `poc/<topic>_poc.<ext>` (or a tiny folder under `poc/<topic>/` if unavoidable).
- Avoid abstraction “just in case.” Only factor once it buys clarity for the *current* experiment.

