## Tool to easily set github required checks
https://github.com/marketplace/actions/alls-green#why
>Do you have more than one job in your GitHub Actions CI/CD workflows setup? Do you use branch protection? Are you annoyed that you have to manually update the required checks in the repository settings hoping that you don't forget something on each improvement of the test matrix structure?

## Debug with interactive SSH into Github Agent for
- [ ] [Debug with ssh your Github Actions](https://github.com/marketplace/actions/debug-with-ssh)
## Generating README content automatically
See description and implementation of [this PR](https://github.com/DomT4/homebrew-autoupdate/pull/114).

1. Github action runs to checkout repo, run python script
2. python script looks for section starting `<!-- HELP-COMMAND-OUTPUT:START -->`
3. Rewrites README contents, and sets `$GITHUB_OUTPUT`
4. Runs git commit && push

> [!QUESTION]
> One thing that makes me nervous though, is could this trigger a recursive loop if the README editor wasn't idempotent (say it added an extra newline each execution?)

## Cheat sheet (Jan 2026)

Workflows live in `.github/workflows/<name>.yml`.

- `run:` = shell script
- `uses:` = action package

```yaml
name: ci
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: echo "hello"
```

## Triggers

```yaml
on:
  push:
    branches: [main]
  pull_request:
  workflow_dispatch:  # manual trigger
  schedule:
    - cron: '0 0 * * 0'  # weekly
```

## Runners + containers

GitHub-hosted: **Ubuntu, Windows, macOS**. Docker/containers require Linux (Ubuntu). Doesn't allow other distros, except:
```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    container: fedora:41  # job steps run inside Fedora
    steps:
      - uses: actions/checkout@v4
      - run: cat /etc/os-release
```

## Toolchains

Use `setup-*` actions when you need PATH priority, caching, or version matrix (preinstalled `python3.12` works for simple scripts):
```yaml
- uses: actions/setup-node@v4
  with: { node-version: "22" }

# Assumes .python-version file or requires-python in pyproject.toml
- uses: astral-sh/setup-uv@v7
- run: uv sync --frozen && uv run pytest -q

- uses: actions/setup-python@v5
  with: { python-version: "3.12" }
- run: pip install -U hatch && hatch test
```

## Env + secrets

```yaml
env:
  NODE_ENV: production

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - run: echo "key=${{ secrets.API_KEY }}"
```

## Permissions

Restrict `GITHUB_TOKEN` scope:
```yaml
permissions:
  contents: read
  pull-requests: write
```

## Step outputs + job outputs

Step output by writing to `$GITHUB_OUTPUT`:
```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      version: ${{ steps.vars.outputs.version }}
    steps:
      - id: vars
        run: echo "version=1.2.3" >> "$GITHUB_OUTPUT"

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - run: echo "deploying ${{ needs.build.outputs.version }}"
```

> [!NOTE] Don't use deprecated `::set-output::`

## Artifacts + cache

**Artifacts** — pass files between jobs / persist after run:
```yaml
- uses: actions/upload-artifact@v4
  with: { name: dist, path: dist/ }
```

**Cache** — reuse deps across runs (10GB/repo, LRU eviction after 7 days unused, free):
```yaml
- uses: actions/cache@v4
  with:
    path: ~/.cache/pip
    key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements*.txt') }}
```

## Matrix

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest, macos-latest]
    py: ["3.11", "3.12"]
runs-on: ${{ matrix.os }}
steps:
  - uses: actions/setup-python@v5
    with: { python-version: ${{ matrix.py }} }
```

## Action types

Three implementation types: **JavaScript**, **Docker**, **Composite**.

JS action (`.github/actions/hello-js/action.yml`):
```yaml
name: hello-js
runs:
  using: node24  # node20 deprecated Mar 2026
  main: index.js
```

Docker action (`.github/actions/hello-docker/action.yml`):
```yaml
name: hello-docker
runs:
  using: docker
  image: Dockerfile
```

Composite action (`.github/actions/hello-composite/action.yml`):
```yaml
name: hello-composite
runs:
  using: composite
  steps:
    - shell: bash
      run: echo "hello"
```

Calling local actions:
```yaml
steps:
  - uses: actions/checkout@v4
  - uses: ./.github/actions/hello-js
  - uses: ./.github/actions/hello-docker
  - uses: ./.github/actions/hello-composite
```

Note: for third-party actions, consider pinning by commit SHA.

`actions/github-script` — inline JS for GitHub API:
```yaml
- uses: actions/github-script@v7
  with:
    script: |
      core.info(`sha=${context.sha}`)
```

## Conditionals

```yaml
- run: echo "only on main"
  if: github.ref == 'refs/heads/main'

- run: echo "previous step failed"
  if: failure()
```

Prefer putting logic in scripts for local debugging. Unavoidable `if:` cases:
- `if: failure()` / `if: always()` — run cleanup or notifications on failure
- `if: github.event_name == '...'` — different behavior per trigger
- `if: needs.job.result == 'success'` — conditional job execution

## Concurrency

Prevent duplicate runs:
```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```
