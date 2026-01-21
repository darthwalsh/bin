#ai-slop

# PLAN — Offline `techstack.yml` renderer

Build a CLI that converts `techstack.yml` → `techstack.md` locally, without relying on StackShare's hosted service.

## Background

StackShare's "Stack File" feature renders `techstack.yml` files into pretty Markdown docs. The hosted renderer is no longer publicly maintained, so we need to reverse-engineer it from real-world examples.

---

## Prerequisites

- Python 3.11+ with `pip`
- Familiarity with YAML and Jinja2 templates
- Git (for cloning example repos)

---

## Goal

Build a CLI tool that:

- Reads `techstack.yml` as the source of truth
- Outputs `techstack.md` (Markdown) locally
- Validates against a corpus of real examples

---

## Success criteria

- [ ] `tests/fixtures/` has 12+ real `techstack.yml` + `techstack.md` pairs
- [ ] `spec/techstack.schema.md` documents 90%+ of observed fields
- [ ] `techstack render path/to/techstack.yml` produces matching output
- [ ] CI runs snapshot tests on every push

---

## Repo layout

```text
/spec
  techstack.schema.md      # Field documentation
  field-matrix.csv         # Which repos use which fields
/tests
  /fixtures
    01-techstack.yml       # Input
    01-techstack.md        # Expected output
    index.yaml             # Source URLs and commit SHAs
/tools
  reverse_render.py        # Main CLI script
/templates
  techstack.md.jinja2      # Output template
/.github/workflows
  render-test.yml          # CI validation
README.md
pyproject.toml
```

---

## Phase 1 — Collect examples

**Goal:** Find 12 real repos with `techstack.yml` files to use as test fixtures.

**Steps:**

1. Search GitHub for `filename:techstack.yml` (or check repos you already know use it)
2. For each repo, copy both files into `tests/fixtures/<repo-name>/`:
    - `techstack.yml` (input)
    - `techstack.md` (expected output, if it exists)
3. Record the source in `tests/fixtures/index.csv`:

```csv
repo,path,sha,notes
https://github.com/org/repo,.techstack,abc123,frontend monorepo
```

**Done when:** You have 12 fixture pairs and `index.csv` is complete.

**Tip:** Start with just 2-3 examples to unblock Phase 3, then add more later.

---

## Phase 2 — Document the schema

**Goal:** Understand what fields `techstack.yml` supports by studying the examples.

**Steps:**

1. Scan all fixtures and list every top-level key you find:
    - `languages`, `frameworks`, `ci_cd`, `cloud`, `publish`, `automation`, `libraries`, etc.
2. For each key, note:
    - Is it a string, object, or array?
    - What subfields does it have? (e.g., `deprecated.date`, `health.success_rate`)
3. Write `spec/techstack.schema.md` with examples for each field
4. Create `spec/field-matrix.csv` showing which repos use which fields

**Done when:** Your schema doc covers 90%+ of fields in your fixtures.

**Tip:** Some repos use `ci:` and others use `ci_cd:`. Pick one canonical name and document the alias.

---

## Phase 3 — Build the renderer

**Goal:** Write a Python script that converts YAML → Markdown.

**Why Python + Jinja2?** Simple to read, Jinja2 is a natural fit for templating Markdown, and most devs already have Python installed.

**Architecture:**

```text
techstack.yml → [normalize] → [render] → techstack.md
```

1. **Normalize** (`tools/normalize_yaml.py`):
    - Load YAML with PyYAML
    - Rename aliases (`ci` → `ci_cd`)
    - Fill in defaults for missing optional fields
2. **Render** (`tools/render_md.py`):
    - Pass normalized data to `templates/techstack.md.jinja2`
    - Output sections in consistent order

**CLI usage:**

```bash
python tools/reverse_render.py tests/fixtures/example-01/techstack.yml > out.md
diff out.md tests/fixtures/example-01/techstack.md
```

**Modes:**

- `--strict` — Exit with error on unknown fields
- `--permissive` — Warn but continue, append unknowns at the end

**Done when:** Your renderer passes diff tests against 10+ fixtures.

---

## Example fixture

`tests/fixtures/dotNetBytes/techstack.yml`:

```yaml
stack:
  name: dotNetBytes
  status: maintenance
  description: "Byte utilities for .NET"
  languages:
    - name: C#
    - name: JavaScript
  frameworks:
    - name: .NET 6
      deprecated:
        date: 2028-01-01
    - name: MSTest
      version: v2
  ci_cd:
    - name: AppVeyor
      link: https://ci.appveyor.com/project/darthwalsh/dotnetbytes
      images:
        - "Windows 10 + VS2022"
      health:
        success_rate: "9/10"
  cloud:
    - provider: Google Cloud Functions
      runtime: dotnet6
      deprecated:
        date: 2025-01-01
  publish:
    - NuGet
    - npm
    - GitHub Pages
  automation:
    dependency_updates: true
```

---

## Template sketch

`templates/techstack.md.jinja2`:

```jinja
# {{ stack.name }}

**Status:** {{ stack.status }}

{{ stack.description }}

## Languages
{% for lang in stack.languages %}
- {{ lang.name }}
{% endfor %}

## Frameworks
{% for fw in stack.frameworks %}
- {{ fw.name }}{% if fw.version %} ({{ fw.version }}){% endif %}{% if fw.deprecated %} — **deprecated** {{ fw.deprecated.date }}{% endif %}
{% endfor %}

## CI/CD
{% for ci in stack.ci_cd %}
- **{{ ci.name }}**{% if ci.link %} ([build]({{ ci.link }})){% endif %}{% if ci.health %} — {{ ci.health.success_rate }}{% endif %}
{% endfor %}

## Cloud
{% for c in stack.cloud %}
- {{ c.provider }} ({{ c.runtime }}){% if c.deprecated %} — deprecated {{ c.deprecated.date }}{% endif %}
{% endfor %}

{# Add remaining sections as needed #}
```

---

## CI workflow

`.github/workflows/render-test.yml`:

```yaml
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"
      - run: pip install -r requirements.txt
      - name: Snapshot tests
        run: |
          for d in tests/fixtures/*/ ; do
            python tools/reverse_render.py "$d/techstack.yml" > /tmp/out.md
            diff -u "$d/techstack.md" /tmp/out.md || exit 1
          done
```

---

## Phase 4 (stretch goals)

### Inference / suggestions

Add a `--suggest` flag that writes `techstack.suggested.yml` with inferred entries:

| If you list...       | Suggest adding...             |
| -------------------- | ----------------------------- |
| `pytest`             | `Python` under languages      |
| `MSTest`             | `.NET` under frameworks       |
| `docker-compose.yml` | `Docker Compose` under tools  |

**Research needed:** How should inference rules be defined? Options:
- Hardcoded mapping in `infer_rules.py`
- External YAML config file
- LLM-assisted via Cursor IDE rules (add a `.cursor/rules/` prompt that suggests entries when editing `techstack.yml`)

### Other stretch goals

- HTML output for static sites
- Export to Backstage `catalog-info.yaml` or OpsLevel `opslevel.yml`

---

## Getting started

Run these commands to bootstrap the project:

```bash
mkdir -p spec tests/fixtures tools templates .github/workflows
touch spec/techstack.schema.md
touch tests/fixtures/index.csv
touch tools/reverse_render.py
touch templates/techstack.md.jinja2
```

Then:

1. Copy the example fixture above into `tests/fixtures/dotNetBytes/`
2. Copy the template sketch into `templates/techstack.md.jinja2`
3. Write a minimal `reverse_render.py` that loads YAML and renders the template
4. Run it and compare output to what you expect
