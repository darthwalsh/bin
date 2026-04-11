#!/usr/bin/env bash
# One-time setup: create virtual environments for each project-based tool.
# Re-run if you add new tools or want to refresh environments.
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECTS="$DIR/projects"
MAIN_PY="$PROJECTS/main.py"

export PATH="$HOME/.local/bin:$PATH"

echo "=== Checking prerequisites ==="
for tool in uv hyperfine; do
    command -v "$tool" &>/dev/null || { echo "ERROR: $tool not found"; exit 1; }
done

for tool in pipenv poetry pdm hatch pipx; do
    if command -v "$tool" &>/dev/null; then
        echo "  $tool: $(command -v "$tool")"
    else
        echo "  $tool: NOT FOUND (will skip)"
    fi
done

copy_main() {
    cp "$MAIN_PY" "$1/main.py"
}

echo ""
echo "=== Setting up project environments ==="

# --- venv-baseline: pre-built venv, fastest possible "with deps" ---
echo "[venv-baseline] Creating venv + installing requests..."
copy_main "$PROJECTS/venv-baseline"
if [[ ! -d "$PROJECTS/venv-baseline/.venv" ]]; then
    uv venv "$PROJECTS/venv-baseline/.venv" --quiet
    uv pip install --quiet --python "$PROJECTS/venv-baseline/.venv/bin/python" requests
fi

# --- uv-project ---
echo "[uv-project] Running uv sync..."
copy_main "$PROJECTS/uv-project"
(cd "$PROJECTS/uv-project" && uv sync --quiet)

# --- pipenv-project ---
if command -v pipenv &>/dev/null; then
    echo "[pipenv-project] Running pipenv install..."
    copy_main "$PROJECTS/pipenv-project"
    (cd "$PROJECTS/pipenv-project" && pipenv install --quiet 2>&1 | tail -3)
else
    echo "[pipenv-project] SKIP (pipenv not found)"
fi

# --- poetry-project ---
if command -v poetry &>/dev/null; then
    echo "[poetry-project] Running poetry install..."
    copy_main "$PROJECTS/poetry-project"
    (cd "$PROJECTS/poetry-project" && poetry install --no-root --quiet 2>&1 | tail -3)
else
    echo "[poetry-project] SKIP (poetry not found)"
fi

# --- pdm-project ---
if command -v pdm &>/dev/null; then
    echo "[pdm-project] Running pdm install..."
    copy_main "$PROJECTS/pdm-project"
    (cd "$PROJECTS/pdm-project" && pdm install --no-self --quiet 2>&1 | tail -3)
else
    echo "[pdm-project] SKIP (pdm not found)"
fi

# --- hatch-project ---
if command -v hatch &>/dev/null; then
    echo "[hatch-project] Running hatch env create..."
    copy_main "$PROJECTS/hatch-project"
    (cd "$PROJECTS/hatch-project" && hatch env create default 2>&1 | tail -3) || true
else
    echo "[hatch-project] SKIP (hatch not found)"
fi

echo ""
echo "=== Ensuring latest Python via uv and pyenv ==="

# Derive latest stable CPython version from uv's release list (descending order,
# so first stable match = newest). Excludes alpha/beta/rc and freethreaded builds.
LATEST_PY="$(uv python list --all-versions 2>/dev/null \
    | grep -v freethreaded | grep -v x86 \
    | grep -E '^cpython-3\.[0-9]+\.[0-9]+-' \
    | grep -v -E 'a[0-9]+|b[0-9]+|rc[0-9]+' \
    | awk '{print $1}' | head -1 | cut -d- -f2)"

if [[ -z "$LATEST_PY" ]]; then
    echo "WARN: could not determine latest Python version from uv; skipping uv python install"
else
    echo "Installing Python $LATEST_PY via uv..."
    # uv python find might find a system install so just always install. 
    # With --default writes ~/.local/bin/python (a preview option)
    uv python install "$LATEST_PY" --default --preview
fi

if command -v pyenv &>/dev/null; then
    if [[ -z "$LATEST_PY" ]]; then
        echo "pyenv: skipping (no version derived from uv)"
    else
        echo "Installing Python $LATEST_PY via pyenv (--skip-existing)..."
        pyenv install --skip-existing "$LATEST_PY" 2>&1 | tail -3 || echo "WARN: pyenv install $LATEST_PY failed"
        pyenv global "$LATEST_PY" 2>/dev/null || true
    fi
else
    echo "pyenv: NOT FOUND (skipping)"
fi

echo ""
echo "=== Priming ephemeral caches ==="
echo "Priming uv run --script (inline deps)..."
uv run "$DIR/trivial_deps.py" >/dev/null 2>&1 || echo "WARN: uv run --script failed"

echo "Priming uvx cowsay..."
uvx cowsay --text hello >/dev/null 2>&1 || echo "WARN: uvx cowsay failed"

if command -v pipx &>/dev/null; then
    echo "Priming pipx run cowsay..."
    pipx run cowsay --text hello >/dev/null 2>&1 || echo "WARN: pipx run cowsay failed"
fi

echo ""
echo "=== Setup complete ==="
