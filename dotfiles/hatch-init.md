# Hatch Init

Initialize a new hatch project with default work project settings.

## License Removal for work projects
- Remove LICENSE.txt file if it exists
- Remove license field from pyproject.toml
- Remove license section from README.md
- Remove SPDX copyright/license headers from source files (__about__.py, __init__.py, tests/__init__.py)
- Remove any github.com links because we use internal github enterprise

## Python Version
- Set requires-python to ">=3.11" (remove support for Python 3.8, 3.9, 3.10)
- Remove older Python version classifiers from pyproject.toml
- Remove "Beta" classifiers

## Code Quality & Formatting
- Add ruff configuration to pyproject.toml with:
```toml
[tool.ruff]
line-length = 120

[tool.ruff.lint]
preview = true
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
  "N",      # pep8-naming
  "PERF",   # perflint (performance)
  "PLR1704", # redefined-argument-from-local
  "PLR2004", # magic-value-comparison
  "PTH",    # flake8-use-pathlib
  "RET",    # flake8-return
  "RUF",    # Ruff-specific rules
  "RUF010", # deprecated-call-target
  "RUF013", # implicit-string-concatenation
  "S",      # flake8-bandit (security)
  "SIM",    # flake8-simplify
  "T20",    # flake8-print (no print statements)
  "UP",     # pyupgrade automatically upgrade syntax for newer python versions
]
ignore = [
  "EM101", # Exception must not use a string literal
  "EM102", # Exception must not use an f-string literal, assign to variable first
  "FA102", # Using type hints without `from __future__ import annotations`# might need to fix this to support python 3.8
  "TRY003", # Avoid specifying long messages outside the exception class
]
```

- Add `hatch fmt` command to README.md development section
- Use `hatch test` instead of `hatch run pytest` in README.md

## Check it works
- Run `hatch fmt` and fix any errors
- Run `hatch test` and fix any errors
