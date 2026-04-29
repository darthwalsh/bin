Server: https://github.com/jfim/obsidian-tasks-mcp

See [[mcp]] for how to call MCP servers from scripts.
See [[due.ps1]] for full calling example.

| Tool             | Behavior                                            |
| ---------------- | --------------------------------------------------- |
| `list_all_tasks` | Returns all tasks in vault                          |
| `query_tasks`    | Filters tasks using Obsidian Tasks query syntax     |

- Query syntax mirrors [Obsidian Tasks plugin](https://publish.obsidian.md/tasks/Queries/About+Queries) filters (one filter per line, AND logic)
- `not done` includes cancelled tasks — filter `status == "incomplete"` in code
- OR conditions [not supported](https://github.com/jfim/obsidian-tasks-mcp/pull/7) in query syntax; do post-filter in script
- Symlinked vault paths may not resolve correctly: symlinked subdirectories inside the vault root are not recursed into by glob.

## Symlink Subdirectory Bug - AI finding

`findAllMarkdownFiles` uses `glob(pattern)` with no options. `glob` v10 defaults to `follow: false`, so symlinked *subdirectories* inside the vault (e.g. `~/notes/MyNotes/inbox/`) are not recursed into — only the top-level symlink target's immediate `.md` files are found.

No issue filed as of 2026-04-24. The fix in the library should be: `glob(pattern, { follow: true })`.

**Workaround**: pass the real resolved path to the MCP instead of the symlinked vault path, so glob only sees real directories. E.g. `realpath ~/notes/MyNotes` → `/Users/walshca/Library/CloudStorage/OneDrive-Personal/PixelShare/MyNotes`.

## Path Parameter Issue

The `list_all_tasks` tool's `path` parameter has an issue when using nested subdirectories. While `{"path":"MyNotes"}` works correctly, `{"path":"MyNotes/inbox"}` fails with the misleading error "Parent directory does not exist: /Users/walshca/notes/MyNotes" even though the directory exists.

**Workaround**: query the parent directory (`MyNotes`) and filter results programmatically. :(

- [ ] Reproduce the issue with a standalone gist
- [ ] Report an issue https://github.com/jfim/obsidian-tasks-mcp
