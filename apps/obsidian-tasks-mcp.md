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
- Symlinked vault paths may not resolve correctly: some nested subdirectories are not searched?

## Path Parameter Issue

The `list_all_tasks` tool's `path` parameter has an issue when using nested subdirectories. While `{"path":"MyNotes"}` works correctly, `{"path":"MyNotes/inbox"}` fails with the misleading error "Parent directory does not exist: /Users/walshca/notes/MyNotes" even though the directory exists.

**Workaround**: query the parent directory (`MyNotes`) and filter results programmatically. :(

- [ ] Reproduce the issue with a standalone gist
- [ ] Report an issue https://github.com/jfim/obsidian-tasks-mcp
