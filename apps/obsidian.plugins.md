### Plugins I'm using
- https://github.com/mgmeyers/obsidian-kanban
- https://github.com/vslinko/obsidian-outliner
    - Reorder bullets / sub-bullets with hotkeys
- https://github.com/shichongrui/obsidian-reveal-active-file
    - Make obsidian act more like how I use vscode
- https://github.com/obsidian-tasks-group/obsidian-tasks
    - Can add `explain` to query to get English breakdown
    - [ ] Working on query for `.todo.md` files
- https://github.com/omnivore-app/obsidian-omnivore
    - Config: 
        - Query: sync archived
        - folder: MyNotes/Omnivore/{{{date}}}
        - Article template: add `{{{ content }}}` to the end
    - [ ] Try removing date in folder
    - [ ] Try configuring this folder to open read-only
    - [ ] Try some tool to embed the highlights, query whether "inbox" is handled, and to create tasks?
    - [ ] set up auto sync
- https://github.com/kemayo/obsidian-smart-links
    - Need to press CMD+E to "Toggle Reading Mode" -- known limitation that it doesn't work in edit mode,  https://github.com/kemayo/obsidian-smart-links/issues/1
- https://github.com/scambier/obsidian-omnisearch
    - smarter search ordering, instead of the builtin-search order by-timestamp or by-filename
        - downrank folders like Omnivore content
    - [x] set up custom keyboard shortcut?
	    - [x] Moved default search to include `CTRL+`
      - [ ] same on #windows
    - [ ] Local HTTP server for search results, [user-script](https://publish.obsidian.md/omnisearch/Inject+Omnisearch+results+into+your+search+engine) add results to Google
    - Can search images, if using https://github.com/scambier/obsidian-text-extractor
- https://github.com/ryanjamurphy/lumberjack-obsidian
    - Only using on Android (on desktop I have [`in` CLI script](../in.ps1) that redirects STDIN to today's daily note)
    - One-tap access from android home-screen to current daily note by opening URL `obsidian://log`
    - Configured:
        - prefix: ""
        - timestamp: false
        - always-new-pane: false
        - inbox: inbox
        - filename: YYYY-MM-DD
### Stopped using
- https://github.com/fleetingnotes/fleeting-notes-obsidian
    - Now in maintenance mode
    - Can use obsidian android app to share links or write short noteskemayo/obsidian-smart-links/issues/1
- https://github.com/marc0l92/obsidian-jira-issue
    - Felt kind of clunky
    - I often paste in the full JIRA url
    - I have terminal scripts / browser shortcuts to open JIRA issues

### Interested to try
- [ ] https://github.com/scambier/obsidian-text-extractor
- [ ] https://github.com/ryangomba/obsidian-todo-sort
- [ ] https://github.com/alangrainger/obsidian-lazy-plugins
	- [ ] On macbook, takes maybe 4 seconds to open; not too bad. What about #windows ? But would rather debug the slow launch if needed

#### Some AI tech
- [ ] https://github.com/brianpetro/obsidian-smart-connections
    - [ ] Uses OpenAI API key
    - [ ] ChatGPT on your notes
    - [ ] Suggests links
- [ ] 228⭐️ https://github.com/your-papa/obsidian-Smart2Brain
    - [ ] RAG LLM, also chat, with local LLM
- [ ] 142⭐️https://github.com/pieces-app/obsidian-pieces
    - [ ] Want to understand more about this Pieces OS

### Plugins I've contributed to
- https://github.com/obsidianmd/obsidian-importer/commits?author=darthwalsh
- https://github.com/darthwalsh/obsidian-open-folder/tree/main?tab=readme-ov-file#roadmap-to-v0-mvp-that-can-be-shared-privately
        - 2% complete plugin for viewing folder as file
