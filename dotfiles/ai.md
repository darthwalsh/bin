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

2. **Discover related content using Smart Connections MCP** (tool reference: `bin/apps/smart-connections-mcp.md`):
    - Call the Smart Connections MCP tools* directly:
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
    - If these didn't find anything closely relevant, use regular plaintext search across all workspace folders (by filename and by file content)
    - Read all discovered related notes to understand the full context
    - Identify connections between the referenced files and related content found via semantic search
    - Suggest files in `bin/apps/` that have relevant content to append to, and suggest new files to create.
    - **STOP. Ask what my goal is for the new content. Do NOT create or edit any files until I respond.**

3. After confirming the goal (wait for explicit user confirmation before proceeding): Create a new markdown file or sub-heading in `bin/apps/` that:
    - Starts with `#ai-slop` header. (I'll remove this if I think your output is high quality.)
    - Structure for clarity; don't blindly copy the structure of the referenced files.
    - Lead with **problem/context** (why does this matter? what mental model helps?)
    - Organizes content into clear sections with descriptive headings explaining either bottom-up or top-down the abstractions.
    - Sections should flow logically (e.g., spectrum/comparison → specific technology → where it shows up → gotchas).
    - Adds **Examples** subsections when listing products/platforms/technologies
    - Incorporates insights from semantically related notes found via Smart Connections
    - The goal is **curated, structured knowledge** that's easy to reference later, not a verbatim copy of the source material.

    **Redundancy rules**:
    - Never state the same fact in two places (e.g. table cell AND a separate paragraph). Pick the one best location.
    - If a fact fits in a table cell, keep it there — don't also write a standalone paragraph restating it.
    - Don't add table columns where values are obvious from context or uniform across all rows.
    - When `bin/apps/` already has a dedicated page for a topic, use a `[[wikilink]]` cross-reference as mentioned in @markdown.mdc

    **Link placement**: attach URLs to the named concept inline, not as trailing "See [link]" or "[Vendor] documents this [URL]". Prefer `[Windows Setup](URL) does X` over `Windows Setup does X. [Microsoft docs](URL).` as mentioned in @markdown.mdc

4. As you end each iteration, check back on the task list, and for which possible content hasn't been extracted yet
    1. In an earlier chat, I might have said I wanted to come back to another topic.
    2. List possible goals/tasks.
    3. Output a code block with individual `trash` lines for files in `~/notes/MyNotes/inbox/` or `MyNotes/` (ending with extra blank line); I'll decide what to run.
    4. Do not try to delete existing files using Agent native functionality or your terminal/tools.
