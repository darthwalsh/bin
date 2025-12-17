# Get PR title and description

Goal: Output a tiny, review-friendly PR title/description in Carl’s style.

Output should be in AI chat window.
Follow git commit message format, with GFM formatting.
EXAMPLE:
```
JIRA-902 Automate for_legal 3P CSV -> XLSX

Used xlsxwriter like in https://git.example.com/coworker/kibana_search -- nice!
Also generate OSS Record.

## Testing

Added unit tests for new functionality.
Compare artifact with [prev version](https://share.example.com/:x:/r/sites/Tool.xlsx).

AFTER_MERGE:
- [ ] will merge JIRA-951 / JIRA-953 / JIRA-954 into remaining manual steps
``

(First line) Title
- `<JIRA-ID> <imperative, succinct summary>`; Jira ID comes from the branch name prefix.
- Start title with Jira ID from branch, keep the verb imperative, avoid fluff.

(Following lines) Body: Short prose blocks
- State each high-level change; skip “how” details that belong in code.
- `Tricky/Review notes:` only if the diff has a subtle or risky aspect reviewers must notice; keep it short
- `## Testing` what am I using to prove this works? (e.g. key manual check, "added unit tests"); omit filler.
    - For a refactor, just “Green build” is enough.
- Bullets beat paragraphs; drop empty sections instead of writing “n/a”.
- AFTER_MERGE / follow-up notes go in a markdown task list when critical: `- [ ] <task to do>`

Guardrails
- Keep it short; prefer deletion over restating the diff.
- Put nuanced implementation guidance in code comments, not the PR text.
- If something is tricky about the diff itself, capture it in `Tricky/Review notes`.
- Link only when it adds context (e.g., failing build, Slack/Jira reference).


