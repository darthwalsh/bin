Documented limit for combined rules is 500 lines, but try to keep it under 200 lines.

Don't add rules if your linter+formatter can just auto-fix it:
> One of the most common things that we see people put in their CLAUDE.md file is code style guidelines. Never send an LLM to do a linter's job. LLMs are comparably expensive and incredibly slow compared to traditional linters and formatters. We think you should always use deterministic tools whenever you can.


## .cursorrules
- The `.cursorrules` (legacy) file in your project root is still supported but **[will be deprecated](https://cursor.com/docs/context/rules#cursorrules)**.
- They recommend migrating to Project Rules or to `AGENTS.md`.


### 📋 Cursor Rules Hierarchy (Team Summary)

When we use Cursor, the AI doesn't just look at one file. It merges context from multiple levels. If a conflict occurs, the more "specific" rule usually wins.

| **Level**            | **Scope**                | **Where it lives**    | **Best for...**                               |
| -------------------- | ------------------------ | --------------------- | --------------------------------------------- |
| **1. Global (Team)** | Every project in the org | Cursor Dashboard      | Hardcoded company security & compliance.      |
| **2. Remote/Shared** | Selected projects        | Shared Git Repo       | Our team's logic & shared patterns            |
| **3. Project**       | One repository           | `.cursor/rules/*.mdc` | Specific logic unique to _just_ that project. |
| **4. User**          | Your IDE only            | Cursor Settings       | Personal preferences (e.g., "be concise").    |

### 🔗 Useful Documentation for the Team
- **[Cursor Rules (.mdc files)](https://docs.cursor.com/context/rules-for-ai):** How to write modular rules with frontmatter and globs.
- **[Cursor Features Overview](https://www.google.com/search?q=https://docs.cursor.com/get-started/features):** General guide on how Cursor handles codebase context.
- **[Folders & Configuration](https://docs.cursor.com/context/ignore-files):** How to manage what Cursor sees in your directory.

### how to share our team's rules
- **symlink script** (best) like [[setup-cursor.ps1]] 
	- Don't use `stow` for adding symlinks across all projects
	- **make a simple python script to run once for each repo** (best)
- ~~copy-paste across repos~~
- ~~submodule clone a repo with `/rules/` into `./.cursor/~~

### how to backup cursor agent rules created through cursor UI?
❌ It's not plaintext in `~/.cursor` - you'd need to query/update the cursor sqlite DB instead.
