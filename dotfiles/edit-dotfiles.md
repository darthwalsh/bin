---
name: dotfiles
description: Editing dotfiles and system config files for walshca's machine. Use when editing any config file that might live under ~/code/bin/dotfiles/
---

# Dotfiles

Many system config files are **symlinks** into `~/code/bin/dotfiles/`. Editing the canonical path and the symlink target are the same file — do NOT edit both.

## Symlink map

Full list is maintained in `~/code/bin/dotfiles/README.md`. Some examples:

| System path (symlink) | Source in repo |
| --- | --- |
| `~/.config/mise/config.toml` | `~/code/bin/dotfiles/.mise.toml` |
| `~/.claude/settings.json` | `~/code/bin/dotfiles/claude/settings.json` |
| `~/.claude/skills/*/SKILL.md` | `~/code/bin/dotfiles/*.mdc` (various) |


## Rule

Before editing any system config file, check if it's a symlink:

```bash
ls -la <path>
```

If it resolves to `~/code/bin/dotfiles/`, **edit only the `dotfiles/` source**. Never edit both.
