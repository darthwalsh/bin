#ai-slop
# Executable Markdown

The core problem: code examples in docs go stale. Two related but distinct goals:

- **Local DX**: run a code block, auto-update the embedded output in the file
- **CI enforcement**: fail the build if output has drifted from what's embedded

Most tools solve one or the other. The "update embedded output" workflow is the harder one — few tools do it cleanly for multi-language files.

## The output-embedding model

Two models for where output lives:

**Injection model** — output is written back into the `.md` file as a sibling block. The file is the source of truth. CI re-runs the code and diffs against the embedded output.

**Session model** (Runme) — output is stored in a separate session file, never in the `.md`. The `.md` stays clean; CI uses `assert` / non-zero exit codes to fail.

## Tool comparison

| Tool | Languages | Updates embedded output | CI fail on output change | Notes |
|---|---|---|---|---|
| **[Runme](https://docs.runme.dev)** | Any (per-block interpreter) | No — separate session file | Via `assert` / exit code | VS Code notebook UX; `runme run --all README.md` in CI |
| **[markdown-exec](https://pawamoy.github.io/markdown-exec/)** | Python, shell (MkDocs plugin) | Yes — injects into rendered HTML | Via `diff` of rendered output | MkDocs-only; not standalone file editing |
| **[Quarto](https://quarto.org)** | Python, R, Julia, Observable JS | Yes — into rendered output | Freeze + re-render; [freeze conflicts with `--execute` in CI](https://github.com/quarto-dev/quarto-cli/issues/9792) | `.qmd` format, not plain `.md` |
| **[nbdev](https://nbdev.fast.ai)** | Python | Yes (Jupyter-based) | `nbdev_test` | Jupyter-centric; overkill for non-Python |
| **[execute-dot-md](https://github.com/FraserLee/execute-dot-md)** | 15 languages incl. JS, C | Yes — inserts result block below | Run + diff | 2 stars; hobby project, no CI story |
| **[doccmd](https://adamtheturtle.github.io/doccmd/)** | Any (runs external tool per block) | Yes (formatter write-back mode) | Run linter/formatter; fail on non-zero | Actively maintained (2026-03-02); designed for linting/formatting, not execution |
| **[mdoc](https://scalameta.org/mdoc/)** | Scala only | Yes — inline `// res:` comments | Compile-time typecheck | Scala-specific |

**Gotcha**: Quarto's `freeze: true` is [silently ignored](https://github.com/quarto-dev/quarto-cli/issues/9792) when `--execute` is passed on the CLI. CI workflow is "execute locally, commit `_freeze/`, render from frozen output in CI" — not re-execution in CI.

## Closest fit: multi-language + auto-update output

For the goal of Node.js + C in the same file with auto-updated output blocks, no single mature tool covers this cleanly. The realistic options:

### execute-dot-md (experimental)

Runs code blocks and inserts output as a new block below. Supports JS and C. Low star count — treat as a prototype.

```bash
# install
npm install -g execute-dot-md

# run: rewrites README.md with output blocks inserted
execute-dot-md README.md
```

Markdown format — code block followed by auto-inserted output:

````markdown
```javascript
console.log("Hello B")
```

<!-- output -->
```
Hello B
```
````

### DIY: shell script + golden file pattern

The most robust approach for arbitrary languages is a small script that:
1. Extracts each fenced code block by language
2. Runs it
3. Diffs actual output against the next sibling block (or a `.golden` file)
4. In "update" mode, overwrites the sibling block

This is the same pattern as [[testing-golden]] — the markdown file is just the golden file.

```bash
# CI: fail on mismatch
./run-md-blocks.sh --check README.md

# Local: update embedded output
./run-md-blocks.sh --update README.md
```

### Runme + assertions (no output embedding)

If you're OK with the session model (output not in the `.md`), Runme's CI story is clean:

```bash
# CI: run all blocks; any non-zero exit fails the build
runme run --all README.md
```

Per-block interpreter config lets you mix Node.js and C in the same file:

````markdown
```javascript {"name":"hello-js", "interpreter":"node"}
console.log("Hello B")
```

```bash {"name":"hello-c"}
gcc -o /tmp/hello hello.c && /tmp/hello
```
````

For output verification, use assertions inside the block:

```javascript
const out = require("child_process").execSync("node script.js").toString().trim();
console.assert(out === "Hello B", `Expected "Hello B", got "${out}"`);
```

## CI pattern (golden file via diff)

Works with any tool that writes output back to the file:

```yaml
# .github/workflows/docs-test.yml
jobs:
  docs-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run and check output
        run: |
          execute-dot-md README.md
          git diff --exit-code README.md  # fails if output changed
```

`git diff --exit-code` is the universal CI check — if the tool updated the file, the diff is non-empty and the build fails.

## Related

- [[testing-golden]] — same approval workflow applies to embedded output blocks
- [[python.RelativePathShebang]] — `uv run` + PEP 723 inline deps works inside Runme blocks via `{"interpreter": "uv run"}`
