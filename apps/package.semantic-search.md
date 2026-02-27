#ai-slop 
#app-idea

# Semantic / Behavioral Package Search

> What if you could search for a library by *what it does* — not by its name?

Instead of searching for "string utils" and hoping the package name matches, you write a conformance test:

```python
assert find("hello world", "world") == 5
assert find("hello", "xyz") == -1
```

The package manager runs those cases against candidate libraries and returns ones that pass. You don't care what the function is called internally — only that it behaves correctly given your inputs and outputs.

## The Lock File Angle

With loose behavioral specs, multiple library versions (or multiple libraries) might match. The resolver picks the latest. But when you freeze your lock file, what gets recorded isn't just a version pin — it's the **exact conformance suite that justified the selection**. Re-resolving later re-runs those tests to verify the behavior hasn't changed. The lock file *is* your behavioral contract.

## Why It Doesn't Exist (in mainstream form)

A few hard problems collide:

- **Tests don't uniquely identify behavior.** Two packages can satisfy the same suite while differing elsewhere. Full uniqueness requires a spec complete enough to approach "specify the whole function."
- **Soundness vs. practicality.** Guarantees require a restricted spec language + formal verification. "Probably correct" can be done with property-based tests but doesn't give uniqueness.
- **Supply-chain risk.** If dependency selection runs third-party code (even "just tests"), you've built a gadget for malicious packages to detect the harness and behave accordingly. Sandboxing helps, but raises complexity.
- **Cost and non-determinism.** Running builds and tests across many candidate packages/versions is expensive and often non-deterministic unless you constrain IO, time, randomness, network, and locale.

## What a Practical Version Could Look Like

A two-phase system layered *on top of* a normal package index:

1. **Candidate discovery (static):** type signatures, docs, exported symbols, semantic embeddings of docs/examples → shortlist (à la Hoogle-style search)
2. **Behavioral filtering (dynamic, sandboxed):** for each candidate, compile/install in a hermetic sandbox, run your conformance suite, discard failures
3. **Selection + lock:** pick "best" among passing candidates (latest, most popular, smallest deps), lock by exact version + content hash + hash of the conformance suite

The conformance language would need to be: **(a)** total/deterministic, **(b)** sandboxable, **(c)** able to express properties (QuickCheck-style) or refinements/contracts — because pure I/O examples don't scale past tiny specs.

## Prior Art & Where to Look

This research area is called **specification-based component retrieval**:

Read these!
- [ ] **Zaremski & Wing (1995)** — ["Specification Matching of Software Components"](https://www.cs.columbia.edu/~wing/publications/ZaremskiWing95a.pdf) — canonical reference; uses formal specs as search keys with theorem proving to validate matches
- [ ] **VCR tool** — VDM-based component retrieval (Fischer et al. 1995); theorem-prover-validated spec matching
- [ ] [Efficient Spec-Based Component Retrieval (Springer)](https://link.springer.com/article/10.1023/A%3A1008766530096) — later work reducing theorem-proving cost at query time

## Closest Things That Exist Today

| Tool | What it does |
|------|-------------|
| [Hoogle](https://hoogle.haskell.org/) | Search Haskell libraries by **type signature** — closest to API-shape search in production |
| [Idris `:search`](https://docs.idris-lang.org/en/latest/reference/type-directed-search.html) | Type-directed library search (dependent types, stronger than Haskell) |
| [pkg.go.dev](https://pkg.go.dev/search-help) | Searches Go packages *and exported symbols* — more API-aware than most registries |
| [edgetest](https://pypi.org/project/edgetest/) | Upgrades Python deps and runs your test suite to check compatibility — "behavior picks versions" but only within one package's version line |

**See also:** [[package.search]] for practical package discovery tools by ecosystem.
