# Testing

## Installing Prerequisites

### PowerShell Tests
- [PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell)
- [Pester](https://pester.dev/docs/introduction/installation) 5.x

### Python Tests
- [uv](https://docs.astral.sh/uv/getting-started/installation) - manages Python and dependencies
- Node.js (for npx, used by some tests)

## Cloud Testing

Github Actions runs [Ubuntu Linux workflows](../.github/workflows/test.yml). This should be better for GitHub Copilot Coding Agent to be able to debug.

- [ ] Set up AppVeyor (faster VM launching for Windows and macOS) too
- [ ] Add badge to README.md

## Running Tests

### PowerShell Tests
```powershell
Invoke-Pester

# Specific file
Invoke-Pester ./tests/rgg.Tests.ps1 -Output Detailed
```

Note: PowerShell tests assume scripts from the repository are in `PATH`

### Python Tests
```bash
uv run pytest

# Specific file
uv run pytest tests/test_vscode_python_interpreter.py -v
```
