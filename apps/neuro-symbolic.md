#ai-slop
[Neuro-symbolic AI](https://en.wikipedia.org/wiki/Neuro-symbolic_AI) pairs a neural network's pattern-matching with a symbolic engine's verifiable correctness — neither alone is sufficient for tasks that require both fluency and rigor.

## LLM as translator, symbolic engine as solver

The split: the LLM translates a natural-language problem into expressions in a formal/proof/DSL, and the symbolic engine actually solves or verifies them. This keeps correctness guarantees (the engine can't hallucinate a proof) while offloading the messy natural-language parsing to the model.

The hard design challenge is **preventing the LLM from short-circuiting** — in arithmetic domains especially, a capable model will just attempt to solve the problem itself rather than emit the symbolic form. Strategies:

- **Structured output (JSON or a grammar-constrained format)**: constrains the model to emit well-formed symbolic expressions rather than answers. The model's job becomes "frame the problem correctly," not "compute the result."
- **Strict role separation in the prompt**: explicitly state the model must only translate, never solve. The proof engine is the authority.
- **Smaller/distilled model**: a model that barely understands the domain is less likely to attempt a direct solve — but a model too small won't follow the translation instructions reliably either. Being explicit about role beats making the model "dumb."

See [[ai.thinking]] for how thinking/scratchpad modes affect model behavior.

## DeepMind AlphaProof (2024 IMO)

[AlphaProof](https://deepmind.google/discover/blog/ai-solves-imo-problems-at-silver-medal-level/) solved four of six 2024 International Mathematical Olympiad problems at silver-medal level. The architecture: a language model generates candidate proof steps in [Lean 4](https://lean4.epfl.ch/), and a symbolic verifier confirms or rejects each step. Neither component could succeed alone — the LLM provides creative exploration, Lean enforces formal correctness.

This is the clearest public existence proof that neuro-symbolic architectures work on hard mathematical reasoning at state-of-the-art level.
