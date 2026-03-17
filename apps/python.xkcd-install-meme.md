# Python Environment Superfund Site

> *"My Python environment has become so degraded that my laptop has been declared a superfund site."*
> -- [xkcd #1987](https://xkcd.com/1987/) ([explained](https://www.explainxkcd.com/wiki/index.php/1987:_Python_Environment))

Audited: 2026-03-16

## Current `python3` PATH resolution (first wins)

| Priority | Source             | Path                                                     | Version                 |
| -------- | ------------------ | -------------------------------------------------------- | ----------------------- |
| 1        | pyenv shim         | `~/.pyenv/shims/python3`                                 | 3.11.6 (global default) |
| 2        | uv (standalone)    | `~/.local/bin/python3`                                   | 3.13.3                  |
| 3        | mise               | `~/.local/share/mise/installs/python/3.14.3/bin/python3` | 3.14.3                  |
| 4        | brew `python@3.14` | `/opt/homebrew/bin/python3`                              | 3.14.3                  |
| 5        | macOS system       | `/usr/bin/python3`                                       | 3.9.6                   |

So `python3` resolves to **pyenv's 3.11.6** unless a local `.python-version` overrides it.

## Tool managers installed

| Tool         | Purpose                                                    | Path                                   | Size   | Overlaps with |
| ------------ | ---------------------------------------------------------- | -------------------------------------- | ------ | ------------- |
| pyenv        | Python version switching via shims                         | `~/.pyenv/versions/`                   | 2.1 GB | mise, uv      |
| uv           | pip/pipx replacement, also installs Pythons                | `~/.local/share/uv/python/`            | 323 MB | pyenv, mise   |
| mise         | polyglot runtime manager, installs python + uv (1 version) | `~/.local/share/mise/installs/python/` | 55 MB  | pyenv         |
| brew         | deps for awscli, azure-cli, etc. (3.11, 3.13, 3.14)        | `/opt/homebrew/Cellar/python@*/`       | --     | pyenv, mise   |
| macOS system | 3.9.6                                                      | `/usr/bin/python3`                     | --     | --            |
| pipenv       | dependency manager                                         | --                                     | --     | uv            |
| hatch        | project manager                                            | --                                     | --     | uv            |

## PyPI tool runners & script runners

| Tool | Source | Version | Path | Capabilities |
| ---- | ------ | ------- | ---- | ------------ |
| `uvx` (= `uv tool run`) | brew uv | 0.9.27 | `/opt/homebrew/bin/uvx` | run PyPI tools without install, `uv tool install` for persistent |
| `uv run --script` | brew uv | 0.9.27 | (same binary) | run `/// script` inline dependencies (PEP 723) |
| `uvx` / `uv run` | mise uv | 0.10.9 | `~/.local/share/mise/installs/uv/*/` | same, but newer -- **shadowed by brew uv in PATH** |
| `pipx` | mise | 1.8.0 | `~/.local/share/mise/installs/pipx/` | run/install PyPI tools -- **not on PATH** |

Installed tools via `uv tool install`: `ruff` (at `~/.local/share/uv/tools/`)

**Note:** Two uv installs -- brew (0.9.27) wins in PATH over mise (0.10.9). After cleanup, `brew uninstall uv` and let mise's uv take over.

## Recommended 2026 stack: mise + uv

**mise** manages Python versions (and node, go, etc). **uv** manages packages, venvs, and running tools (`uvx`). That's it -- two tools, clear responsibilities.

## De-bloat steps (in order)

 1. [ ] **Uninstall pyenv + pyenv-virtualenv via brew**
    - [ ] Remove `eval "$(pyenv init -)"` and similar from shell profile
    - `brew uninstall pyenv-virtualenv pyenv`
    - Delete `~/.pyenv/versions/` (frees **2.1 GB**)
    - Delete `~/.pyenv/version`, `~/.pyenv/shims/`
    - mise already handles `.python-version` files, so per-project switching still works
 2. [ ] **Remove standalone uv Python installs**
    - [ ] Remove the `~/.local/bin/python3` symlinks that uv created (`ls -la ~/.local/bin/python*` to check)
    - `uv python uninstall --all` (frees **323 MB**)
    - uv installed via mise will still _use_ pythons (from mise) -- it just won't manage its own copies
 3. [ ] **Don't install Python through brew directly**
    - `brew uninstall python@3.14` will likely fail because other formulae depend on it (awscli, azure-cli, etc.) -- that's fine, let brew keep its own copies as deps. Just don't rely on `/opt/homebrew/bin/python3` as your working Python
 4. [ ] **Remove pipenv from brew**
    - `brew uninstall pipenv` -- uv replaces it entirely (`uv pip`, `uv venv`, `uv lock`)
 5. [ ] **Remove brew uv (shadowing mise's newer uv)**
    - `brew uninstall uv` -- brew has 0.9.27, mise has 0.10.9; let mise own it
    - Remove `pipx` from `.mise.toml` -- `uvx` fully replaces it
 6. [ ] **Clean up stale uv cached environments**
    - `uv cache clean` to reclaim temp build caches
 7. [ ] **Update mise config** to be the single source of truth
    - Your [.mise.toml](vscode-webview://03pmfhf2lnqoajc2je4ng9pqmgkqck4msa7ae7kr402f2orgt76q/dotfiles/.mise.toml) already has `python = "latest"` and `uv = "latest"` -- this is correct
    - Add specific versions per-project via `.mise.toml` or `.python-version` in each repo
 8. [ ] **Remove Brewfile entries**
    - Remove: `pyenv`, `pyenv-virtualenv`, `pipenv`
    - Keep: `mise`, `hatch` (if you use it for project builds)
## After cleanup: how it works

| Need                | Tool                         | Example                                   |
| ------------------- | ---------------------------- | ----------------------------------------- |
| Install Python 3.12 | `mise use python@3.12`       | per-project or global                     |
| Default python3     | mise shim                    | respects `.python-version` / `.mise.toml` |
| Create venv         | `uv venv`                    |                                           |
| Install packages    | `uv pip install` or `uv add` |                                           |
| Run a CLI tool      | `uvx ruff check .`           | no global pip install needed              |
| Lock dependencies   | `uv lock`                    | replaces pipenv/poetry                    |
