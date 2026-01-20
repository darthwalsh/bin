---
aliases:
  - Python naming underscore or hyphen
---
**TL;DR:** Repo+Dist+CLI use hyphens (`team-tool`), python identifiers use underscores (`team_tool`).

## Should you use underscore or hyphen used in Python packaging or import naming?

| Context                                                      | Allowed               | Ideal      |
| ------------------------------------------------------------ | --------------------- | ---------- |
| **Repo** `github.com/org/team-tool`                          | `_-`                  | hyphen     |
| **Script file** `python my-script.py`                        | `_-`                  | *either*   |
| **Distribution** `name = "team-tool"`                        | `_-` *normalized[^1]* | hyphen     |
| **Package dir** `src/team_tool/`                             | `_`                   | underscore |
| **Import** `import team_tool`                                | `_`                   | underscore |
| **Module** `python -m team_tool`                             | `_`                   | underscore |
| **Venv CLI** `.venv/bin/team-tool` (via `[project.scripts]`) | `_-`                  | hyphen     |

So for `uvx`: Don't need `--from` flag if the dist name normalizes to the command: `uvx --from team_tool team-tool` is same as `uvx team-tool`

[^1]: PyPI treats `-`, `_`, `.` as equivalent when looking up packages. So `pip install team-tool` and `pip install team_tool` resolve to the same package.
