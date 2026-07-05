#ai-slop

Claude Code's plugin system distributes [[ai.skills|Agent Skills]] via **marketplaces** — git repos with a manifest and one or more plugin packages. See [[ai.plugins]] for how plugins relate to skills and [[mcp]].

Official docs: [Claude Code plugins](https://code.claude.com/docs/en/plugins).

## Marketplaces

A marketplace is a git repo with `.claude-plugin/marketplace.json` listing available plugins:

```
marketplace-repo/
├── .claude-plugin/
│   └── marketplace.json    # catalog of plugins + metadata
└── plugins/
    ├── my-plugin/
    └── another-plugin/
```

Add a marketplace once, then install individual plugins from it:

```
/plugin marketplace add git@example.com:team/my-marketplace.git
/plugin install my-plugin@my-marketplace
```

Installed files land under `~/.claude/plugins/marketplaces/<marketplace>/`.

## Plugin layout

Each plugin is a subdirectory referenced from `marketplace.json`:

```
plugins/my-plugin/
├── .claude-plugin/
│   └── plugin.json         # name, version, description
├── skills/
│   └── my-skill/
│       └── SKILL.md        # standard Agent Skill format
├── commands/
│   └── my-skill.md         # slash-command entrypoint → skill
├── .mcp.json               # optional: bundled MCP server config
└── README.md
```

### skills/

One or more [[ai.skills|Agent Skill]] directories. Same `SKILL.md` format used by Cursor and other hosts.

### commands/

Markdown files that define **slash commands** (`/my-skill`). Each command is a thin wrapper: frontmatter + "use the `my-skill` skill" + `$ARGUMENTS`. The command is Claude Code's discovery/invoke UX; the skill is the actual workflow.

### Optional bundled MCP servers

Some plugins ship `.mcp.json` to register MCP servers on install (e.g. a Confluence publish plugin bundling the Atlassian MCP). Skills-only plugins document MCP prerequisites in `SKILL.md` instead and rely on the user's existing MCP config.

## Porting skills to Cursor

Claude Code slash commands don't transfer — only the `skills/` directories do. Symlink from the marketplace checkout into `~/.cursor/skills/`; see [[ai.skills#Port a skill between hosts]].
