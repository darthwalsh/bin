#ai-slop
# Python Runner Startup Benchmarks

Measures the warm-invocation overhead of Python version managers and script runners using [hyperfine](https://github.com/sharkdp/hyperfine). Goal: concrete "rules of thumb" for how much each runner layer adds.

## Quick start

```bash
# One-time setup (creates venvs, installs deps, primes caches)
./setup-python-projects.sh

# Run all benchmarks
./bench-python.sh

# Just one category
./bench-python.sh --category 1   # bare Python interpreters
./bench-python.sh --category 2   # with-deps runners

# More runs for tighter confidence intervals
./bench-python.sh --min-runs 50

# Correctness check (1 iteration each, no warmup — verifies commands work)
./bench-python.sh --run1
```

Results are written to `results/*.md` and printed at the end.

## What's being measured

### Category 1 — Bare Python interpreter

Workload: `import sys; print(dir(sys))`

Tests each Python binary on PATH directly — no runner wrapper. Compares system, brew, pyenv shim, uv-managed, and mise-managed Pythons. Version labels are queried at runtime so they stay accurate as Python versions change.

### Category 2 — With dependencies (requests)

Workload: `import requests; print(dir(requests))` for project runners

Tests the runner tax on a warm cache: uv run (project + script + offline), uvx, pipenv, poetry, pdm, hatch, pipx.

### Category 3 -- Ephemeral Tools
- [ ] `cowsay --text hello` for ephemeral tool runners (uvx, pipx).

## Stability / reading the results

hyperfine has no interleave/shuffle mode — it runs all N runs of command 1, then all N of command 2, etc. ([open issue #21](https://github.com/sharkdp/hyperfine/issues/21)). A background burst (Docker, Spotlight) inflates whichever command was running at that moment.

Mitigations in this script:
- `--min-runs 30` — lets hyperfine extend runs for high-variance commands automatically
- `--warmup 5` — stabilizes caches before timing begins

**The Min column is more reliable than Mean** for "what can this do uncontested." Treat Mean ± σ as a range. The *ranking* is stable across runs even when absolute ms values drift ±5–10ms.

## Diagnosing slow startup with `-X importtime` and `-S`

When a specific tool or script is slow, use Python's built-in profilers before assuming it's the runner:

### `-X importtime` — trace which imports are slow

```bash
python -X importtime -c 'import requests' 2>&1 | sort -k2 -n | tail -20
```

Can use [python-importtime-graph](https://github.com/kmichel/python-importtime-graph) for a browser treemap:

```bash
python -X importtime -c 'import requests' 2>&1 | python-importtime-graph > out.html
open out.html
```

[Simon Willison used this](https://simonwillison.net/2025/Jun/20/python-importtime-graph/) to diagnose a tool taking >1s to start — turned out a single transitive import was the culprit.

## `-S` is not significant

`-S` (CPython internals flag) disables the `site` module, which sets up `sys.path` and scans for installed `site-packages`. [Victor Stinner's analysis](https://pythondev.readthedocs.io/startup_time.html) shows it accounted for roughly half of Python's startup time.

Benchmarked: mise's `python -S` runs ~1ms faster than the bare mise binary (~21ms), within noise at this scale. Where `-S` helps more is on older/slower Pythons or when `site-packages` is large (many installed packages slow the scan).

```bash
time python -c 'print("hello")'    # normal
time python -S -c 'print("hello")' # skip site module
```

To use it: add `-S` to the shebang line: `#!/usr/bin/env -S python3 -S`

## Prior art

No existing benchmark covers the **same scope:** various standalone python, and projects. The closest sources:

- **[pdm-project/pdm #1527](https://github.com/pdm-project/pdm/issues/1527)** and **[python-poetry/poetry #3502](https://github.com/python-poetry/poetry/issues/3502)** — issue threads with raw `time`/hyperfine numbers showing pdm: 390–1028ms, poetry: 526–752ms, bare Python: 21ms. Not controlled for warmup, but order of magnitude matches.
- **[DEV.to — Python's Hidden Bottleneck (Werner Smit, 2025)](https://dev.to/werner_smit_355bfa500f8c3/pythons-startup-tax-when-script-startup-time-becomes-the-bottleneck-2np6)** — bare Python startup on Linux (not runner overhead). Uses hyperfine with warmup. Key: `import requests` adds ~100ms over bare Python.
- **[Victor Stinner — Python Startup Time](https://pythondev.readthedocs.io/startup_time.html)** — CPython core dev analysis. Covers `-S`, `-X importtime`, and historical benchmarks. Foundational.
- **[CPython issue #118761](https://github.com/python/cpython/issues/118761)** — active effort to reduce stdlib import times. Context for why Python 3.14 may benchmark faster than 3.11.
- **[bdrung/startup-time](https://github.com/bdrung/startup-time)** — referenced in `ShellScripting.md`. 1000 hello-world runs across many languages; solid discipline but only bare interpreter, no runner/version manager comparison.

## Diagnosing uv cache misses after long breaks

When `uv run --script` is slow after coming back from a holiday or long gap, run with `-v` to see what's actually happening:

```bash
uv run -v your_script.py 2>&1 | grep -E 'Creating|Resolving|Downloading|Fetching|Updating'
```

Key lines to look for:
- `Creating virtual environment` — new ephemeral env being built (cache miss or version bump)
- `Resolving` + `Downloading` — unpinned dep resolved to a newer version
- `Fetching` — index metadata revalidated from network

**Most likely causes after a long break:**
1. **Unpinned dep got a new release** — `requests` (no version pin) resolved to a newer version; uv builds a fresh environment. Partial fix: add a major-version cap (`requests<3`) to reduce churn without blocking security updates.
2. **uv version bump changed cache bucket format** — caches are versioned; upgrading uv invalidates old cached environments. Verify: `du -sh "$(uv cache dir)"` before and after a slow run.
3. **macOS Storage Management purged `~/.cache/uv`** — the default cache location can be targeted by "Optimize Storage." Check: `uv cache dir`.

## Follow-ups
- [ ] Split out a category 3 for cowsay for ephemeral tool
- [ ] Research options to improve startup time of other runners (pdm, hatch, pipenv, poetry), like `--offline` in uv
- [ ] Try same tests inside docker
- [ ] Try similar tests inside windows
- [ ] [interpreter-startup-times](https://github.com/MaxGyver83/interpreter-startup-times) has gnuplot examples that would be useful to visualize these numbers

### Projects using different python executables

- [ ] [[setup-python-projects.sh]] should start each tool using uv python, not a mix of pyenv and brew

| Project            | Source                                                                      |
| ------------------ | --------------------------------------------------------------------------- |
| **venv-baseline**  | `~/.local/share/uv/python/cpython-3.13.3-macos-aarch64-none/bin/python3.13` |
| **uv-project**     | `~/.local/share/uv/python/cpython-3.13.3-macos-aarch64-none/bin/python3.13` |
| **pipenv-project** | `~/.pyenv/versions/3.14.3/bin/python3.14`                                   |
| **poetry-project** | `~/.local/share/uv/python/cpython-3.13.3-macos-aarch64-none/bin/python3.13` |
| **pdm-project**    | `~/.pyenv/versions/3.11.6/bin/python3.11`                                   |
| **hatch-project**  | `/opt/homebrew/Cellar/python@3.14/3.14.3_1/.../python3.14`                  |
### JS runner benchmark (`bench-js.sh`)

- [ ] Add a `bench-js.sh` comparing `node`, `bun`, `deno` bare startup + `npx`/`bunx`/`pnpm dlx` wrapper tax on the same trivial workload
- [ ] Compare `uvx` vs `bunx` vs `npx` for the same ephemeral tool (`cowsay` exists on both PyPI and npm — same workload across ecosystems)
- [ ] also try [deno compile](https://deno.com/blog/v2.7#deno-install---compile) as a "pre-compiled native binary" baseline

### Network condition matrix

Run each runner under three network states (prime cache first, then measure):

| Condition | What it tests |
|---|---|
| Regular network | warm-cache baseline |
| VPN | DNS/proxy latency; whether internal mirrors are used |
| No network | does the runner phone home on warm cache? timeout penalty |

For VPN runs, swap in `.npmrc` pointing to internal npm mirror and `UV_INDEX` for internal PyPI mirror — remove both off VPN.

### Spying on runner network calls

To see which hostnames a runner contacts during a run (without full MITM):

```bash
# Capture DNS + TLS SNI for one command
sudo tcpdump -i any -n -s 0 -w /tmp/runner.pcap "tcp port 443 or port 53" &
uvx cowsay --text hello
sudo kill %1
tshark -r /tmp/runner.pcap -Y "dns.qry.name" -T fields -e frame.time -e dns.qry.name
tshark -r /tmp/runner.pcap -Y "tls.handshake.extensions_server_name" -T fields -e frame.time -e tls.handshake.extensions_server_name
```

For response sizes and exact URLs, use **Proxyman** (GUI, easy CA trust) or **mitmproxy** — both work via `HTTPS_PROXY` which most CLIs honor.

