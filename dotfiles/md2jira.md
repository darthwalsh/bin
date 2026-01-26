---
description: Convert Markdown to Jira wiki markup
---

Convert the selected markdown to Jira wiki markup:

## Headers
- `- **Bold Header:**` → `h3. *Bold Header:*`

## Bullets
- Top-level bullets: `*` (with space after)
- Sub-bullets: `**` (with space after)
- Use ` * ` as a parent placeholder when sub-bullets follow a header

## Text Formatting
- Markdown bold `**text**` → Jira bold `*text*`
- Markdown italic `*text*` → Jira italic `_text_`
- Markdown code `` `code` `` → Jira code `{{code}}`

## Structure Pattern
For nested content under a header:

```
h3. *Header Title:*

Introductory paragraph text.
 * 
 ** *Sub-item bold:* Description text.
 ** *Another sub-item:* More description.
```

Note: The lone ` * ` acts as an invisible parent for the `**` sub-bullets in Jira's rendering.

Convert {{selection}} to Jira wiki markup following these patterns.
