#!/usr/bin/env bash
# Benchmark Python runner startup overhead using hyperfine.
#
# Usage:
#   ./bench-python.sh                    # Run all categories
#   ./bench-python.sh --category 1       # Bare Python only
#   ./bench-python.sh --category 2       # With-deps runners only
#   ./bench-python.sh --min-runs 50      # More runs for tighter stats
#   ./bench-python.sh --run1             # 1 iteration each (correctness check, no warmup)
#
# Stability notes:
#   hyperfine has no interleave/shuffle mode — it runs command 1 for all N runs, then command 2, etc. 
#   See https://github.com/sharkdp/hyperfine/issues/21
#   Background bursts (Docker, Spotlight, etc.) can inflate the command running at that moment.
#   Mitigations used here:
#     --min-runs 30  : lets hyperfine extend noisy commands automatically
#     --warmup 5     : stabilizes filesystem/CPU caches before measuring
#   The Min column is more reliable than Mean for "what can this do uncontested." 
#   Treat Mean ± σ as a range, not a point estimate.
#
# Prerequisites: run setup-python-projects.sh first
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECTS="$DIR/projects"
RESULTS="$DIR/results"

export PATH="$HOME/.local/bin:$PATH"

WARMUP="${WARMUP:-5}"
MIN_RUNS=30
CATEGORY="all"
RUN1=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --min-runs)  MIN_RUNS="$2"; shift 2 ;;
        --category)  CATEGORY="$2"; shift 2 ;;
        --run1)      RUN1=true; shift ;;
        *)           echo "Unknown arg: $1"; exit 1 ;;
    esac
done

if [[ "$RUN1" == true ]]; then
    WARMUP=0
    MIN_RUNS=1
fi

mkdir -p "$RESULTS"

command -v hyperfine &>/dev/null || { echo "ERROR: hyperfine not found. brew install hyperfine"; exit 1; }

# ============================================================================
# Helpers
# ============================================================================

BENCH_ARGS=()
MISSING_BINS=()

# add NAME CMD — record a benchmark entry.
# Extracts the first token of CMD and checks it exists; skips + warns if not.
add() {
    local name="$1" cmd="$2"
    local bin
    bin="$(echo "$cmd" | awk '{print $1}')"
    # strip redirection tokens that aren't binaries (e.g. "cd /foo && ...")
    if [[ "$bin" == "cd" ]]; then
        bin="$(echo "$cmd" | sed 's/cd [^ ]* && //' | awk '{print $1}')"
    fi
    if [[ ! -x "$bin" ]] && ! command -v "$bin" &>/dev/null; then
        MISSING_BINS+=("$name: $bin")
        return
    fi
    BENCH_ARGS+=("--command-name" "$name" "$cmd")
}

# py_ver BINARY — print "X.Y" version string for a python binary, or "?" on failure.
py_ver() {
    "$1" -c 'import sys; print(*sys.version_info[:2], sep=".")' 2>/dev/null || echo "?"
}

flush() {
    local label="$1"
    local shell_name="$2"
    local count=$(( ${#BENCH_ARGS[@]} / 3 ))
    if (( count < 1 )); then
        echo "  No commands to benchmark for $label"
        BENCH_ARGS=()
        return
    fi
    local md_file="$RESULTS/${label}.md"
    echo ""
    if [[ "$RUN1" == true ]]; then
        echo "--- $label ($count commands, 1 run each — correctness check) ---"
    else
        echo "--- $label ($count commands, min $MIN_RUNS runs each) ---"
    fi
    echo ""
    # --min-runs (not --runs) lets hyperfine run more iterations for high-variance
    # commands rather than capping at a fixed count; --run1 uses --runs to hard-cap at 1
    local runs_flag="--min-runs"
    [[ "$RUN1" == true ]] && runs_flag="--runs"
    hyperfine \
        --warmup "$WARMUP" \
        "$runs_flag" "$MIN_RUNS" \
        --shell="$shell_name" \
        --export-markdown "$md_file" \
        --sort mean-time \
        "${BENCH_ARGS[@]}"
    echo ""
    echo "Markdown table written to $md_file"
    BENCH_ARGS=()
}

# Checks if a command exists; adds to MISSING_BINS if not.
has_cmd() {
    if ! command -v "$1" &>/dev/null; then
        MISSING_BINS+=("$1")
        return 1
    fi
    return 0
}

# ============================================================================
# Category 1: Bare Python interpreter startup
# ============================================================================

# add_with_version LABEL BINARY — add a benchmark entry for a Python binary with its version.
function add_with_version() {
    local label="$1" bin="$2"
    add "$label ($(py_ver "$bin"))" "$bin $DIR/trivial.py >/dev/null"
}

run_category_1() {
    echo ""
    echo "=========================================="
    echo " Category 1: Bare Python interpreter"
    echo "=========================================="
    echo " Workload: import sys; print(dir(sys))"
    echo ""

    local bin ver

    add_with_version "system" "/usr/bin/python3"
    add_with_version "brew" "/opt/homebrew/bin/python3"
    add_with_version "pyenv shim" "$HOME/.pyenv/shims/python3"
    add_with_version "uv-managed" "$HOME/.local/bin/python3"
    local mise_bin="$(mise exec -- which python3 2>/dev/null)"
    add_with_version "mise" "$mise_bin"
    add "mise -S" "$mise_bin -S $DIR/trivial.py >/dev/null"

    has_cmd uv && add "uv run (no deps)" "uv run --no-project $DIR/trivial.py >/dev/null"

    flush "1-bare-python" "none"
}

# TODO need to re-run cat2 numbers
# ============================================================================
# Category 2: With dependencies (requests)
# ============================================================================

run_category_2() {
    echo ""
    echo "=========================================="
    echo " Category 2: Python with dependencies"
    echo "=========================================="
    echo " Workload: import requests; print(dir(requests))"
    echo ""

    local VENV_PY="$PROJECTS/venv-baseline/.venv/bin/python"
    add "venv (pre-built)" "$VENV_PY $PROJECTS/venv-baseline/main.py >/dev/null"

    [[ -f "$PROJECTS/uv-project/uv.lock" ]] && \
        add "uv run (project)" "cd $PROJECTS/uv-project && uv run python main.py >/dev/null"

    if has_cmd uv; then
        add "uv run --script (inline)" "uv run $DIR/trivial_deps.py >/dev/null"
        # --offline on warm cache saves ~5-8ms at most (within noise); real value
        # is avoiding surprise network delays after long breaks on stale HTTP cache
        add "uv run --script --offline" "uv run --offline $DIR/trivial_deps.py >/dev/null"
    fi

    [[ -f "$PROJECTS/pipenv-project/Pipfile.lock" ]] && has_cmd pipenv && \
        add "pipenv run" "cd $PROJECTS/pipenv-project && pipenv run python main.py >/dev/null"

    has_cmd poetry && [[ -d "$PROJECTS/poetry-project" ]] && \
        add "poetry run" "cd $PROJECTS/poetry-project && poetry run python main.py >/dev/null"

    has_cmd pdm && [[ -f "$PROJECTS/pdm-project/pdm.lock" ]] && \
        add "pdm run" "cd $PROJECTS/pdm-project && pdm run python main.py >/dev/null"

    has_cmd hatch && [[ -f "$PROJECTS/hatch-project/pyproject.toml" ]] && \
        add "hatch run" "cd $PROJECTS/hatch-project && hatch run python main.py >/dev/null"

    # TODO(Cat3) Add cowsay as a standalone category, not 
    # has_cmd uvx && add "uvx (cowsay)" "uvx cowsay --text hello >/dev/null 2>&1"
    # has_cmd pipx && add "pipx run (cowsay)" "pipx run cowsay --text hello >/dev/null 2>&1"

    flush "2-with-deps" "default"
}

# ============================================================================
# Main
# ============================================================================

echo "Python Runner Benchmark"
echo "======================="
echo "hyperfine $(hyperfine --version)"
echo "Warmup: $WARMUP | Min runs: $MIN_RUNS"
echo "Results dir: $RESULTS"

[[ "$CATEGORY" == "1" || "$CATEGORY" == "all" ]] && run_category_1
[[ "$CATEGORY" == "2" || "$CATEGORY" == "all" ]] && run_category_2

echo ""
echo "=== Results in $RESULTS ==="
ls -1 "$RESULTS"/*.md

if (( ${#MISSING_BINS[@]} > 0 )); then
    echo ""
    echo -e "\033[31m=== WARNING: expected binaries not found (skipped) ===\033[0m"
    for entry in "${MISSING_BINS[@]}"; do
        echo -e "\033[31m  ✗ $entry\033[0m"
    done
fi
