#ai-slop
---
description: Markdown Writing Guidelines applies to all markdown files
globs: ["**/*.md"]
---

# Writing Style Guidelines

Avoid excessive use of emojis, arrows/symbols, or “smart quotes”. They are distracting, but include if it adds value.
Don't write meta-messages in markdown if they would better belong in the Agent chat.
When changing content, don't reference the old text. (We can see the diff in git.)
Pronouns: use "I/me" for the blog author; reserve "you" for the readers.

## Structure
- Lead with problem/context, then solutions
- Include "When do you need X?" sections
- After each subsection, consider if any "Gotchas" or edge cases really need to be mentioned
- Avoid subheadings where the only content is bullets; use a short lead-in sentence + bullets instead.
- Prefix large amounts (20+ lines) of AI-generated content with #ai-slop on its own line. Only one #ai-slop per section. The first line of the file covers the entire file.

## Code Examples
- Show multiple approaches with trade-offs as subheadings
- If its hard to see in the code, use `❌ or ✅ or ⚠️ OOPS! <explanation of what's wrong>` in source-code comment
- Show anti-patterns after, then explain WHY they fail
- Be specific about what breaks: "Could leak to next invocation" not "this is bad"

## Cross-references
- Use `[[WikiLink]]` syntax
- Compare across domains (languages, systems, etc.)
- Reference actual library code with links when possible

## Avoid “confident guesses”
- Prefer primary sources (official docs/blogs)
- When using a web resource for some fact, link the fact as a [markdown link](URL) inline with content. Link the first statement of the fact.
- If you can’t find a primary source quickly, label it as **unspecified** and don’t assert the underlying tech as fact. Treat wikipedia as a primary source.
- When you mention a limitation, be explicit about what breaks.

## Markdown Checklist Conventions

When working with markdown checklists:

### Task Status Markers
- `[ ]` - Not started / Pending / In progress
- `[x]` - Completed / Done
- `[-]` - Won't fix / Not applicable / Intentionally skipped

### Won't Fix Pattern
When marking a task as "won't fix", use this format:

```markdown
- [-] Check headers visible in logging
    - **WONTFIX**: Java service doesn't automatically capture HTTP request headers in logging without additional configuration/instrumentation
```

Always provide a clear and concise reason when using `[-]`

