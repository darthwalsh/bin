#ai-slop

If build, test, and package aren't separated into explicit, isolated phases — with tests that exercise the exact shipped artifact in a minimal runtime — then tests, source layout, or dev tools can mask correctness and even leak into what you ship.

## The 4 Anti-Patterns

### 1. Non-Hermetic Build Inputs

The build is allowed to "see" things it shouldn't: test trees, CI-only assets, local tools, developer home dirs, network, etc.

- A malicious or accidental change in the *test* area (or dev environment) can change what gets shipped.
- The [xz/liblzma backdoor](https://en.wikipedia.org/wiki/XZ_Utils_backdoor) (2024) exploited this: build scripts became a covert channel where test-adjacent files influenced what was compiled.
- Python: `pytest` importing from the repo working tree instead of the installed package tests **source layout behavior**, not the installed artifact.

The build's dependency closure must be explicit and declared.

### 2. Dirty Workspace Polluting the Release Artifact

Tests run "inside" the staging/output directory, generate logs/data/cache, and the packager blindly scoops it up.

- Build app → run unit tests → zip app folder → **logs and test data end up in the release zip**.

Package from a clean staging directory that tests cannot write to. Treat packaging like producing an immutable image: `build/` → `stage/` → package from `stage/`.

### 3. Testing the Wrong Artifact

Tests are wired against convenient inputs (source files on disk), not what users consume (installed wheel, built DLL/so, container image, etc.). The test suite can pass while the shipped artifact is broken — missing package data, wrong import paths, wrong link flags, missing runtime deps.

| Language | Wrong way | Right way |
|:---------|:----------|:----------|
| Python | `pytest` imports from repo tree | install wheel into clean venv, `PYTHONPATH=`, run from outside repo root |
| C++ | gtest compiles `.cpp` directly into test exe | link tests against the same production-built `libcore` |
| C# | (less common — MSTest naturally links the DLL, not source) | link test project to the same DLL as the app |

For C++: if your app isn't a public library, the options are (a) extract a real internal `libcore` that both app and tests link, (b) test through the public surface (CLI, output files, exit codes), or (c) use compile-time test hooks — but still building from the same build graph.

### 4. Hidden Runtime Toolchain Dependencies

The program (or a build step accidentally invoked at runtime) shells out to `gcc`, `git`, `pytest`, `node`, etc. Dev machines have them; customer machines don't.

- C++ app invokes `gcc` via subshell at runtime → silently relies on toolchain availability.
- Python code accidentally depends on `pytest` because the test venv always has it; source code imports it without noticing.

Validate runtime dependency closure in a **minimal environment** that intentionally lacks dev tooling.

## Three-Tier Pipeline Shape

- **Tier A** — Fast in-tree unit tests (dev deps allowed). Proves small-unit correctness. Does *not* prove packaging or runtime closure. Fail the build if tests dirty the workspace (`git status --porcelain`).
- **Tier B** — Artifact tests. Build artifact once; install/deploy it; run tests against it with no source-tree fallback. Proves the shipped artifact is functional for customers.
- **Tier C** — Minimal runtime smoke. Tier B environment *minus* all dev/test deps. Catches hidden toolchain dependencies that only exist on developer machines.

See [[package.build-examples]] for how Linux/macOS/Windows/Python packaging ecosystems encode these same guarantees.
