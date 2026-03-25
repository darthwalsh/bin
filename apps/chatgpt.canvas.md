#ai-slop

# ChatGPT Canvas

Canvas is ChatGPT's side-by-side document editor — useful for rewriting and rethinking content, but not designed for precise iterative editing the way an IDE is.

## Where Canvas falls short vs. Cursor IDE

### No diff view — only version snapshots

Cursor shows Git-style red/green diffs scoped to the exact subsection being changed. Each edit is reviewable before accepting, which matters when deleting large sections.

Canvas has version history (snapshots per major edit), but no line-level diff. You can click back through versions, but there's no visual indicator of what changed between them.

### No code folding — only zoom/pan

Cursor supports folding at heading/block level, so a 1,000-line document stays navigable by collapsing sections you're not working on.

Canvas has no collapsing. Navigation is spatial: zoom out to see structure, zoom in to edit. This breaks down for long documents.

### Full document regeneration on each edit

Cursor applies surgical diffs — a one-line change in a 1,000-line file touches only that line. Early VS Code + GitHub Copilot had the same full-regeneration problem; Copilot now applies incremental edits too.

Canvas still regenerates the whole document on each edit, even for small localized changes. This is slow for large documents and makes it hard to trust that untouched sections weren't silently modified.

## When Canvas is still useful

- Rewriting or restructuring a short document from scratch
- Generating a first draft to copy out of
- Iterating on prose style where full-regeneration cost is acceptable
