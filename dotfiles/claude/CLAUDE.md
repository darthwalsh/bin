# Working preferences

## Prefer narrow allow-listed tools over general interpreters

Use a scoped, allow-listed command when it can do the job; escalate to a general interpreter (requiring permission prompt) only when a scoped tool genuinely can't.

- JSON: `jq`, not `python3 -c` / `node -e`
- Search: `rg` / `grep`, not a scripting loop
