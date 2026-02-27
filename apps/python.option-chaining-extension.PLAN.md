#ai-slop 
I was curious about extending a programming language, and wanted to see how far chatgpt could get coming up with a language feature, and good tooling.
- [ ] extend with `.pyw` lang support in i.e. github language viewer??? Or maybe rename to `.x-optional.py` to fallback to PY support
- [ ] Try out the ralph loop with this? does garbage-in mean garbage-out here?
#app-idea 
# PLAN.md - Py extension plan: Optional chaining (`?.`) for Python

## Goal
- Add a **nullable/safe property access** operator that behaves like:
    - `obj?.attr` → `None` if `obj is None`, else `obj.attr`
    - Supports chaining: `a?.b?.c` (short-circuits to `None` as soon as any receiver is `None`)
- Keep semantics **None-aware only** (does *not* swallow `AttributeError` for missing attributes).

## Prior art to review
- PEP 505 “None-aware operators” (deferred): proposes `?.`, `?[]`, `??`, `??=` style operators.
- Recent python.org discussion threads about safe navigation / reviving PEP 505.
- Existing “polyfill” style projects that implement PEP 505-ish syntax via a custom grammar/transpiler.

## v1 scope
- Syntax:
    - `?.` for attribute access only.
    - (Optional but easy to add later) `?[]` for subscripting, e.g. `x?[k]`.
    - (Out of scope v1) `??` / `??=`.
- File-level opt-in via extension:
    - Use `.pyw` (placeholder name) for “Python with optional chaining”.
- Deliverables:
    - `pyw` CLI compiler (source-to-source).
    - Import hook to run `.pyw` directly.
    - Build hook to package compiled `.py` in wheels.

## Semantics
- `receiver?.attr`
    - Evaluate `receiver` exactly once.
    - If `receiver is None`: result is `None`.
    - Else: perform normal attribute access `receiver.attr`.
- Chaining: `a?.b?.c`
    - Equivalent to: `tmp=a; None if tmp is None else (tmp2=tmp.b; None if tmp2 is None else tmp2.c)`
- Precedence/associativity
    - Treat `?.` like normal `.` attribute access in precedence.
    - Parse as left-associative chaining.

## Transformation strategy
### Why token-level first
- Python’s built-in `ast` parser cannot parse `?.` (invalid syntax).
- Therefore, v1 needs a **pre-parse** transform: token stream → valid Python source.

### Tokenize-based rewrite (recommended v1)
- Use `tokenize` to read a `.pyw` file.
- Recognize the pattern:
    - `<expr> ?. <NAME>` where `<expr>` can be any expression that can appear before `.`.
- Rewrite into a helper call that preserves single-evaluation:
    - `__pyw_getattr(<expr>, "attr")`
- Provide runtime helper:
    - `def __pyw_getattr(obj, name): return None if obj is None else getattr(obj, name)`
- For chaining, the rewrite naturally nests:
    - `a?.b?.c` → `__pyw_getattr(__pyw_getattr(a, "b"), "c")`
- Notes:
    - This keeps evaluation count correct and is easy to implement.
    - It changes attribute access mechanics slightly (uses `getattr` rather than `obj.attr`) but behavior matches for normal attributes and descriptors.

### Optional: AST post-pass (optimization / nicer output)
- After token rewrite, parse with `ast` and optionally:
    - Inline `__pyw_getattr(x, "a")` into `(None if (t:=x) is None else t.a)` when safe.
    - Collapse nested calls.
- This is optional; token-only is sufficient.

### Concrete-syntax tree option (v1.5+)
- If preserving formatting/comments perfectly is important, consider LibCST for the *post* transform stage.
    - Still requires token-stage to make the file parseable first.

## CLI tool design (`pyw`)
### Commands
- `pyw compile <in.pyw> [-o out.py]`
- `pyw compile-tree <src_dir> -o <out_dir> [--exclude tests/**]`
- `pyw fmt` (optional later) to normalize or enforce style around `?.`.

### Caching
- Write compiled output to:
    - A parallel tree (build output dir), and/or
    - `__pycache__/module.<tag>.pyw.pyc` for import-time execution.
- Include a cache key based on:
    - Source hash
    - Tool version
    - Python version

### Source maps (needed for IDE/LSP v2)
- During rewrite, track mapping:
    - Original span(s) → generated span(s)
- Persist alongside compiled output:
    - `module.py.map.json`

## Runtime import hook
### Goals
- Allow `import mypkg.mod` where `mod.pyw` exists.
- Ensure behavior works in:
    - Normal execution
    - Pytest
    - Frozen apps (later)

### Implementation sketch
- Provide `pyw.importer.install()` which:
    - Inserts a `MetaPathFinder` + `Loader` in `sys.meta_path`.
- Finder behavior:
    - When importing `X`:
        - Look for `X.pyw` next to `X.py`.
        - Prefer `.pyw` if present (or require explicit opt-in flag).
- Loader behavior:
    - Read `.pyw` source
    - Run token rewrite → valid Python source
    - `compile()` and `exec()` into module namespace
    - Populate `__file__`, `__spec__`, `__cached__` appropriately

### Pytest integration
- Provide a pytest plugin:
    - `pytest -p pyw.pytest_plugin`
    - Or auto-enable when `pyw` is installed (config-driven)

## Build-time integration

### Preferred approach: Hatch/Hatchling build hook
- Implement a Hatch build-hook plugin that:
    - Runs before wheel build
    - Compiles `.pyw` → `.py` into a staging directory
    - Ensures the wheel contains compiled `.py`
    - Optionally includes `.map.json` for IDE/debugging
- Keep `.pyw` in sdist for contributors.

### Flit / other backends
- If the backend doesn’t support hooks directly, provide:
    - A thin PEP 517 backend wrapper (advanced), or
    - Document using Hatchling as the backend for projects that need `.pyw`.

### uv
- Treat uv as the frontend; it will invoke whatever backend is configured.
- Target: “works if you use a backend with hooks (Hatchling), otherwise run `pyw compile-tree` pre-build.”

## Packaging conventions
- Repo layout
    - Keep `.pyw` as the source of truth.
    - Generated `.py` only in build artifacts (not committed) OR committed if you want zero-tooling contributors.
- Wheel
    - Ship `.py` (and optionally maps)
    - Do not require `pyw` at runtime unless the import hook is desired

## Editor support

### v1 (good enough)
- Syntax highlight:
    - VS Code TextMate injection grammar for `?.`
    - (Optional) tree-sitter grammar fork for richer highlighting
- Formatting/linting:
    - Recommend running the compiler before tools that require valid Python
    - Or provide `pyw lint` that compiles to a temp tree and runs tools there

### v2 (real language services)
- Goal: go-to-definition / find-references / diagnostics on `.pyw`.
- Approach: **LSP proxy server**
    - Accept `.pyw` documents
    - Transform to `.py` + maintain source maps
    - Forward requests to an existing Python analyzer (pyright-like)
    - Translate positions/ranges back using source maps
- Deliverables:
    - `pyw-lsp` (Node or Python)
    - VS Code extension that registers `.pyw` and points to `pyw-lsp`

## Testing strategy
- Golden tests
    - `.pyw` input → expected `.py` output
- Runtime tests
    - Import hook correctness
    - Chaining short-circuit
    - Single evaluation (side-effectful receivers)
- Compatibility matrix
    - Python versions supported (target 3.10+ initially)

## Non-goals / pitfalls to avoid
- Don’t treat missing attributes as `None` (avoid swallowing `AttributeError`).
- Avoid double-evaluating receivers.
- Be cautious about rewriting inside strings/comments.
- Keep generated names (`__pyw_getattr`) collision-resistant.

## Example
- Input (`.pyw`)
    - `name = user?.profile?.display_name`
- Output (`.py`)
    - `name = __pyw_getattr(__pyw_getattr(user, "profile"), "display_name")`

## Implementation milestones
- M0: minimal compiler + helper function + golden tests
- M1: import hook + pytest plugin
- M2: hatch build hook + example project builds into wheel
- M3: source maps + debug story
- M4 (v2): LSP proxy + VS Code extension

