#ai-slop

Using [[GTD]] + Markdown for task tracking with the [[obsidian.plugins#Tasks]] plugin.

## Task Structure Patterns

### Pattern A — Linear prerequisite flow

```md
- [x] PRE-REQ A
- [ ] MAIN TASK
```

Good for scanning speed when order is obvious. The relationship is implicit — Obsidian Tasks can't enforce it.

### Pattern B — Hierarchical (parent → children)

```md
- [ ] MAIN TASK
  - [x] PRE-REQ A
  - [ ] FOLLOW-UP 📅 2026-03-05
```

Most common in Obsidian Tasks. Parent = outcome, children = concrete next actions. Matches GTD's *outcome → next actions* model. Parent completion is a social convention — the plugin doesn't auto-complete the parent.

### Pattern C — Project heading + flat tasks

```md
## Project: MAIN TASK

- [x] PRE-REQ A
- [ ] FOLLOW-UP 📅 2026-03-05
```

Easier to refactor, cleaner query results, clearer separation between "project" and "task". Use when subtasks might move or grow.

**Rule of thumb**: nesting for short-lived tight dependencies; project heading for anything that feels like a real project.

## Task Comments and Resolution Reasons

In Jira, completing a task lets you add a comment, and resolving gives you a structured "Won't Fix" reason. In Markdown there's no equivalent — but the pattern that works best is **an indented non-task bullet under the task**:

```md
- [-] Investigate alternative API
  - Not needed: current API already supports batching
```

This keeps the resolution reason next to the task without polluting the task text itself. The Tasks plugin ignores indented plain bullets, so it doesn't appear in query results.

Other comment options:

| Approach | When to use |
|---|---|
| Inline: `- [x] Find URL → https://...` | Small artifact, won't revisit |
| Indented bullet (above) | Resolution reason, WONT-FIX rationale |
| Completion log: `- Done 2026-01-06 / Result: ...` | Audit trail, decisions you revisit |
| Link out: `- [-] Explore X` / `  - See [[Decision Log]]` | When the comment becomes reference knowledge |

## Context Links in Task Text

A subheading wikilink like `[[TaskFile#TheDetails]]` works in the note itself, but **breaks in Obsidian Tasks search results**: the query file resolves the link as `QueryNote#TheDetails` instead of `TaskFile#TheDetails`.

Options:
- Use a plain wikilink to the file: `[[TaskFile]]` — always resolves correctly, loses the heading anchor
- Put the context in an indented comment bullet instead of in the task text
- Accept the broken link in search results if you mostly navigate from the source file

## Mental Model

Two questions per task:
1. *Action or outcome?* → outcome becomes a parent task or project heading; action is a leaf
2. *Comment ephemeral or reusable?* → ephemeral goes in an indented bullet; reusable gets a linked note

See also [[obsidian.scripting#Remove checkbox]] to toggle a task back to a plain bullet via hotkey.
