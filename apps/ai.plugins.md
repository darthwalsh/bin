#ai-slop

A **plugin** is host-specific **packaging** for one or more [[ai.skills|Agent Skills]] — not a primitive itself. The skill (`SKILL.md` + optional dirs) is the atomic, cross-host unit; the plugin adds distribution, discovery, and host conveniences on top.

## What plugins add beyond a bare skill

| Layer | Bare skill | Plugin |
| ----- | ---------- | ------ |
| Install | Copy/symlink a `SKILL.md` dir | Marketplace add + `/plugin install` (Claude Code) |
| Discovery | Agent reads `description` frontmatter | Slash commands (`/skill-name`) |
| Versioning | Manual | Plugin manifest pins version |
| Bundling | One skill per dir | Multiple skills + commands in one package |
| MCP setup | Documented in skill Prerequisites | Optional `.mcp.json` ships MCP server config with the plugin |

Cursor has **no plugin layer** for agent skills — skills install directly as directories. See [[cursor#Agent skills]].

## MCP prerequisites

Skills that call external APIs document required MCP tools in a **Prerequisites** section of `SKILL.md` (e.g. "requires Atlassian MCP with `createJiraIssue`"). Plugins may go further and **bundle** MCP server configuration (`.mcp.json`) so install brings both the workflow and the server wiring — see [[claude.plugins#Optional bundled MCP servers]].

The capability primitives themselves are defined in [[mcp]].

## Host implementations

| Host | Plugin system | Doc |
| ---- | ------------- | --- |
| Claude Code | Marketplaces + `/plugin install` | [[claude.plugins]] |
| Cursor | Skills only (no marketplace) | [[cursor#Agent skills]] |
