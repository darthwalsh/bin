# Process AI notes into bin/apps/ content

When I reference a file from `ai/` (inbox notes, a timestamped markdown chat with GPT) I'm asking for you to confirm the goal, then to create/append files `bin/apps/`.

## The workflow

1. **Summarize the chat**: Read the source file from `ai/`, summarize each section of the chat: the core of what I was asking for, and a few sentences of the reply. Suggest a few files in bin/apps that have relevant content to append to, and suggest a few new files to create.

2. After confirming the goal: **Structure for clarity**: Create a new markdown file or sub-heading in `bin/apps/` that:
   - Starts with `#ai-slop` header. (I'll remove this if I think your output is high quality.)
   - Leads with **problem/context** (why does this matter? what mental model helps?)
   - Organizes content into clear sections with descriptive headings explaining either bottom-up or top-down the abstractions.
   - Sections should flow logically (e.g., spectrum/comparison → specific technology → where it shows up → gotchas).
   - Adds **Examples** subsections when listing products/platforms/technologies

The goal is **curated, structured knowledge** that's easy to reference later, not a verbatim copy of the source material.
