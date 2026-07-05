#ai-slop

An **Agent Skill** is a portable workflow unit: a directory with a required `SKILL.md` (YAML frontmatter + markdown instructions) and optional supporting files. The [Agent Skills open standard](https://agentskills.io/specification) is adopted across [[claude-code]], [[Cursor]], Codex, [[github.copilot]], [[Gemini]] CLI, etc.

Skills sit above [[mcp]] in the stack: MCP servers expose **tools** the agent can call; skills tell the agent **when and how** to use them.
Distribution and host-specific packaging (slash commands, marketplace install, bundled MCP config) live in [[ai.plugins]] — not in the skill primitive itself.

## SKILL.md format

### Frontmatter

Required fields per the [spec](https://agentskills.io/specification):

| Field | Purpose |
| ----- | ------- |
| `name` | Lowercase identifier; must match the parent directory name |
| `description` | What the skill does and when to use it — this is what the agent reads at startup to decide relevance |

Optional: `license`, `compatibility` (env requirements), `metadata`, `allowed-tools` (experimental).

Host extensions (not in the open spec) include `disable-model-invocation: true` — skill runs only on explicit user request, not auto-discovery.

### Body

Step-by-step workflow instructions. No format restriction; keep under ~500 lines and split detail into `references/` or `scripts/` for [progressive disclosure](https://agentskills.io/specification#progressive-disclosure) (metadata → full SKILL.md → on-demand files).

### Optional directories

| Dir | Contents |
| --- | -------- |
| `scripts/` | Executable helpers the agent can run |
| `references/` | Deep docs loaded on demand |
| `assets/` | Templates, schemas, static resources |

## Port a skill between hosts

Claude Code installs skills inside plugin checkouts under `~/.claude/plugins/marketplaces/<marketplace>/plugins/<plugin>/skills/<name>/`. Cursor reads skills from `~/.cursor/skills/<name>/` (personal) or `.cursor/skills/<name>/` (project). The `SKILL.md` file is the same; only the install path differs.

Symlink a skill dir from a Claude marketplace checkout into Cursor:

```bash
ln -sf ~/.claude/plugins/marketplaces/<marketplace>/plugins/<plugin>/skills/<skill-name> \
       ~/.cursor/skills/<skill-name>
```

Invoke in Cursor by name in chat (`Run slack-catchup`) — there is no slash-command layer. See [[cursor#Agent skills]].
