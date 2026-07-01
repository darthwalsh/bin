# Process AI notes into bin/apps/ content

When I reference file(s) from `MyNotes/inbox/ai/` (chats with GPT) using "@" in the chat, I'm asking for you to confirm the goal, then to create/append files `bin/apps/`.

**Note**: The file name may contain instructions or hints about the topic - use it as my initial intent for what to focus on.

## The workflow

1. **Summarize and extract**: 
    1. Read all files that were "@" referenced in the chat (typically from `ai/` inbox notes)
    2. Summarize each section of the chat: the core of what I was asking for, and a few sentences of the reply
    3. Extract key abstractions, technologies, protocols, and concepts from the referenced files
    4. In the "👤 You" heading, add to task list any phrases worded like:
         - I could
         - Remind me
         - Follow up
         - Put a pin in that
         - For later
         - I'll test
         - Later I'll
    5. If the top of the file starts with task items `- [ ] `, add to task list.

2. **Discover related content optionally using Smart Connections MCP** (tool reference: `bin/apps/smart-connections-mcp.md`):
    - If I tell you to use Smart Connections MCP, call the Smart Connections MCP tools* directly:
        - `get_connection_graph`: build a multi-level graph of related notes from each referenced file
        - `get_similar_notes`: find semantically similar temporary-notes in the `ai/` folder (recursively search for related topics)
            - Notes in `ai/` are semantically similar. If the note covers the same topic, go back to Step 1 and Summarize, Extract, and Discover again.
            - Notes in `MyNotes/` are not ready for publishing; either personal or too messy. We can move content to `bin/apps/` once it's high quality and missing personal details.
        - `search_notes`: find related content across all notes and `bin/` based on the extracted concepts:
            - **IMPORTANT**: Use SHORT queries (2-3 words max) with `threshold: 0.1`
            - Abstractions and mental models discussed
            - Technologies, protocols, and tools mentioned
            - Philosophical ideas or concepts
            - Related patterns or workflows
    - Else, or if these didn't find anything closely relevant, use regular plaintext search across all workspace folders (by filename and by file content)
    - Read all discovered related notes to understand the full context
    - Identify connections between the referenced files and related content found via semantic search
    - Suggest files in `bin/apps/` that have relevant content to merge into, and suggest new files with topic outlines to create.
        - Use a **diff-style preview** to show the proposed structure. Each line is a markdown heading prefixed with ` ` (space, existing/unchanged) or `+` (new heading being added) or `-` (removed/reworded):
        ```diff
        +# connecting-java-to-c.md
        +## Garbage Collection
        +### malloc
        +### another subheading etc
        +## Heading about ... some topic
        +### Subheading 1
        +# connecting-misc-lang-to-c.md | Connecting Misc Languages to C 
        +## Blah blah
         # c.md
         ## malloc
        +### Connecting from Java
        ```
        - Lines with `+` are **new** headings (either in a new file or inserted into an existing file).
        - Lines with ` ` (space prefix) are **existing** headings shown for context so the reader knows where new content is being inserted.
        - If the h1 title matches the filename, don't create a `# C` h1 in the real file — the filename will already be displayed like one.
        - For each h1, use the filename as the heading tile. 
            - Put the filename first, and only append " | " with the heading text if we are going to create a h1 in the real file because it doesn't match the filename. 
        - A new file gets all `+` lines. An existing file has a mix of ` +-`.
        - Only show enough existing headings for parent context around insertions and highly related sibling nodes; don't list the entire file.
    - **STOP. Ask what my goal is for the new content. Do NOT create or edit any files until I respond.**

3. After confirming the goal (wait for explicit user confirmation before proceeding): Create a new markdown file or sub-heading in `bin/apps/` that:
    - Starts with `#ai-slop` header. (Only human editing can remove this I have reviewed the output.)
    - Structure for clarity; don't blindly copy the structure of the referenced files.
    - Lead with **problem/context** (why does this matter? what mental model helps?)
    - Organizes content into clear sections with descriptive headings explaining either bottom-up or top-down the abstractions.
    - Sections should flow logically (e.g., spectrum/comparison → specific technology → where it shows up → gotchas).
    - Adds **Examples** subsections when listing products/platforms/technologies
    - Incorporates insights from semantically related notes
    - The goal is **curated, structured knowledge** that's easy to reference later, not a verbatim copy of the source material.

    **Redundancy rules**:
    - Never state the same fact in two places (e.g. table cell AND a separate paragraph). Pick the one best location.
    - If a fact fits in a table cell, keep it there — don't also write a standalone paragraph restating it.
    - Don't add table columns where values are obvious from context or uniform across all rows.
    - When `bin/apps/` already has a dedicated page for a topic, use a `[[wikilink]]` cross-reference as mentioned in @markdown.mdc

    **Link placement**: attach URLs to the named concept inline, not as trailing "See [link]" or "[Vendor] documents this [URL]". Prefer `[Windows Setup](URL) does X` over `Windows Setup does X. See [Microsoft docs](URL).` as mentioned in @markdown.mdc

4. As you end each iteration, check back on the task list, and for any possible content hasn't been extracted yet
    1. In an earlier chat, I might have said I wanted to come back to another topic.
    2. List possible goals/tasks.
    3. Output a code block with individual `trash` lines for files in `~/notes/MyNotes/inbox/` or `MyNotes/` (ending with extra blank line); I'll decide what to run.
    4. Do not try to delete existing files using Agent native functionality or your terminal/tools.
