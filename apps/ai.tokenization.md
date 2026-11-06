#ai-slop

## Chunking is by frequency, not length: the same text splits differently in different contexts
cl100k: `function` alone is a single token, but `   function` splits as `  ` + ` function`, and `##function##` as `##` + `function` + `##` — the neighbors decide the split.

## No token means "column 3" — spaces and newlines glue to content, so the grid is scrambled before the model sees it
In a fixed-width box, the first row `+------+` plus newline tokenizes as `+` │ `------` │ `+\n`, while the identical last row (no trailing newline) is `+` │ `------+`; a four-space indent becomes `   ` + ` |`.

## Keeping the grid means fixed-width chunks, or skipping text and rendering the art as pixels
Fixed-width chunking preserves columns but spends tokens on empty space; a vision encoder reads the rendered pixels and sees the actual 2D layout.
