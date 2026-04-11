ty is a great type checker for Python! Also works well as a LSP.

## Ty in Multi-Root Workspaces

`ty` (Astral's type checker VS Code extension) does **not support multi-root workspaces** as of 2026-04.

>[!NOTE] Use the `WORKSPACE_FILE` environment variable so [[vscode_python_interpreter.py]] knows not to run in an multi-root wp
> I manually set this in the each .code-workspace  file `.settings` for the terminal:
> ```json
> "terminal.integrated.env.osx": {
>   "WORKSPACE_FILE": "/Users/walshca/adsk/2ha.code-workspace"
> }
> ```

- Open issue: https://github.com/astral-sh/ty-vscode/issues/25
- Failure mode: import resolution silently uses the wrong (workspace-level) interpreter, so third-party imports from script-specific `uv` environments are unresolved.
- `ty` also disables the Python extension's language server to avoid conflicts, so you can't fall back to Pylance in the same window.

### Workaround Use Single-Folder Window
Open e.g. `~/code/bin` in a new window when doing Python work that needs `ty` to resolve imports correctly.
