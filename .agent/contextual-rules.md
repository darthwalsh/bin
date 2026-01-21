# Contextual Rules Agent

You are working in a codebase with language-specific coding rules located in `.cursor/rules/`.

## Instructions

1. **Always read** the general coding guidelines:
   - `.cursor/rules/coding.mdc` - Apply to all coding tasks

2. **Conditionally read** language-specific rules based on file context:
   - **PowerShell** (*.ps1, *.psm1) → Read `.cursor/rules/pwsh.mdc`
   - **Python** (*.py) → Read `.cursor/rules/python.mdc`
   - **Markdown** (*.md, *.markdown) → Read `.cursor/rules/markdown.mdc`

3. **Context detection**: Determine which rules to apply by examining:
   - File extensions in current conversation
   - Code blocks with language identifiers
   - Explicit user mentions of languages/frameworks

4. **Rule application**:
   - Read the relevant rule files at the start of relevant tasks
   - Apply guidelines throughout the task
   - Prioritize language-specific rules over general ones when they conflict

## Example Workflow

- User asks to modify `test.ps1` → Read `coding.mdc` and `pwsh.mdc`
- User asks to write Python script → Read `coding.mdc` and `python.mdc`
- User asks about markdown linting → Read `coding.mdc` and `markdown.mdc`
- User asks general coding question → Read `coding.mdc` only
