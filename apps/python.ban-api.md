#ai-slop
# Banning Python API usage

* [ ] ## Ruff `TID251` (`banned-api`) — ban specific members

[`TID251`](https://docs.astral.sh/ruff/rules/banned-api/) bans access to specific module members (reads **and** writes). Useful when you want to forbid a known symbol entirely.

```toml
[tool.ruff.lint]
extend-select = ["TID251"]

[tool.ruff.lint.flake8-tidy-imports.banned-api]
"PyQt5.QtWidgets.QMessageBox.information".msg = "Use a custom dialog instead."
"another_module.config".msg = "Don't touch directly; use another_module.set_config()."
```

Catches `from PyQt5.QtWidgets import QMessageBox; QMessageBox.information(...)` → `TID252`.

**Gotcha**: `TID251` only matches when the symbol is accessed via the exact dotted path used in config. `import PyQt5; PyQt5.QtWidgets.QMessageBox.information(...)` is **not** caught — the rule matches the imported name, not the full attribute chain.

## Semgrep — ban `module.attr = value` generically in CI

When you want to catch any `imported_module.attr = value` (e.g., a coworker mutating a module-level global buried in a 1000-line PR), Ruff has no generic rule for this. Use Semgrep:

`.semgrep/no-imported-module-attr-assign.yml`:

```yaml
rules:
  - id: python.no-imported-module-attr-assign
    languages: [python]
    severity: ERROR
    message: >
      Don't assign to attributes on imported modules (mutable global / hidden coupling).
      Prefer dependency injection, an explicit setter API, or pytest monkeypatch.
    patterns:
      - pattern: $MOD.$ATTR = $VAL
      - pattern-either:
          - pattern-inside: |
              import $MOD
          - pattern-inside: |
              import $PKG as $MOD
          - pattern-inside: |
              import $PKG.$SUB as $MOD
```

```bash
semgrep --config .semgrep/no-imported-module-attr-assign.yml --error --metrics=off
```

**Gotchas**:
- Won't catch `from x import thing; thing.attr = ...` (by design — `thing` could be a class/instance)
    - [ ] probably need to catch that, if x/thing.py imports as a module
- Won't catch `setattr(mod, "x", y)` — add a separate pattern if needed
- Use Semgrep inline suppression (`# nosemgrep`) for sanctioned escape hatches

## Pyright `reportPrivateUsage` — enforce `_private` naming across modules

If the mutable state is renamed to `_config`, [Pyright's `reportPrivateUsage`](https://github.com/microsoft/pylance-release/blob/main/docs/diagnostics/reportPrivateUsage.md) flags any cross-module access to `_`-prefixed names — both reads and writes.

```python
import settings
settings._config["x"] = 1  # reportPrivateUsage error
```

Configure in `pyrightconfig.json` or `pyproject.toml`:

```toml
[tool.pyright]
reportPrivateUsage = "error"
```

**Gotcha**: Python has no real encapsulation — this is static enforcement only. `settings._config = ...` still works at runtime.

## Avoiding mutable globals — design patterns

The linting rules above catch the symptom. The structural fix is to eliminate the mutable global.

**Pass config in, don't share it globally** — construct once at the edge (CLI/env), thread through:

```python
@dataclass(frozen=True)
class Config:
    feature_x: bool

cfg = Config(feature_x=os.getenv("FEATURE_X") == "1")
run(cfg)
```

**Wrap state behind an API** — keep the variable private, expose explicit operations:

```python
_config: Config = Config(...)

def get_config() -> Config: return _config
def set_config(cfg: Config) -> None:
    global _config
    _config = cfg
```

**Make globals immutable at the type level**:
- `@dataclass(frozen=True)` — prevents attribute mutation
- [`MappingProxyType`](https://docs.python.org/3/library/types.html#types.MappingProxyType) — read-only dict view
- `typing.Final` — signals "don't rebind" to type checkers (mypy/pyright), doesn't prevent internal mutation

**Request/task-scoped "globals"** → [`contextvars.ContextVar`](https://docs.python.org/3/library/contextvars.html) — avoids cross-thread/async bleed:

```python
from contextvars import ContextVar
current_cfg: ContextVar[Config] = ContextVar("current_cfg")
```

**Temporary overrides** → context manager instead of set/unset:

```python
@contextmanager
def override_config(temp: Config):
    token = current_cfg.set(temp)
    try: yield
    finally: current_cfg.reset(token)
```
