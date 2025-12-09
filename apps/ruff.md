Code linter and formatter from the makers of `uv`.
## Good config
```toml
[tool.ruff]
line-length = 120

[tool.ruff.lint]
extend-select = [
  # see codes in https://docs.astral.sh/ruff/rules/
  "ARG",    # flake8-unused-arguments
  "B",      # flake8-bugbear
  "BLE",    # flake8-blind-except (no bare except:)
  "C4",     # flake8-comprehensions
  "C90",    # mccabe complexity
  "ERA",    # eradicate (commented-out code)
  "F",      # pyflakes
  "I",      # isort
  "ISC001", # single-line-implicit-string-concatenation
  "N",      # pep8-naming
  "PERF",   # perflint (performance)
  "PLR1704", # redefined-argument-from-local
  "PLR2004", # magic-value-comparison
  "PTH",    # flake8-use-pathlib
  "RET",    # flake8-return
  "RUF",    # Ruff-specific rules
  "S",      # flake8-bandit (security)
  "SIM",    # flake8-simplify
  "T20",    # flake8-print (no print statements)
  "UP",     # pyupgrade automatically upgrade syntax for newer python versions
]
[tool.ruff.lint.isort]
known-first-party = [
  "common",
  "utils",
  "etc"
]
known-local-folder = ["tests"]
```
