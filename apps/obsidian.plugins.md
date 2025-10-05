### Plugins I'm using
- https://github.com/mgmeyers/obsidian-kanban
    - works OK, but if I needed live filters I'd use https://imdone.io/
- https://github.com/vslinko/obsidian-outliner
    - Reorder bullets / sub-bullets with hotkeys
- https://github.com/shichongrui/obsidian-reveal-active-file
    - Make obsidian act more like how I use vscode
    - [ ] With new obsidian release, might not need this now!
        - [x] File Explorer now includes an option to automatically reveal the active file.
        - [x] https://obsidian.md/changelog/2025-01-30-desktop-v1.8.3/
        - [ ] https://www.reddit.com/r/ObsidianMD/comments/1h0bmwh/is_there_a_way_for_the_folder_tree_autoexpand_and/
            - [x]  #windows
            - [ ] #macbook try removing this! 
- https://github.com/obsidian-tasks-group/obsidian-tasks
    - [Queries](https://publish.obsidian.md/tasks/Queries/About+Queries) with ```` ```task````
    - Can add `explain` to query to get English breakdown
    - Problem: setting custom status using right click [only works](https://publish.obsidian.md/tasks/Editing/Toggling+and+Editing+Statuses#'Change+task+status'+context+menu) in Reading mode (not Live Preview)
    - Use `path includes {{query.file.path}}` for a task-list summary at top-of-file
    - `show tree` to change layout to [[hierarchy]] mode
    - *Not part of tasks*, but if you just want the builtin search plugin can use ```` ```query````
    - [ ] Would be nice to have a hotkey to increase the priority: normal -> medium -> high using the emojis. Maybe with [JS script](https://github.com/eoureo/obsidian-runjs) or [[obsidian.plugin.dev#Light scripting]] or i can fork/create plugin to add the commands?? 🔼 
    - [x] https://publish.obsidian.md/tasks/Getting+Started/On+Completion#Supported+actions try using checkered flag emoji signifier for delete on recurring?
    - [ ] try https://publish.obsidian.md/tasks/Queries/Layout#Hide+and+Show+Tree
        - [ ] Watching releases
        - [x] Signed up to Watch for releases
        - [ ] Read releases backward https://github.com/obsidian-tasks-group/obsidian-tasks/releases from 7.14.0 and earlier
        - [ ] Check for an email 🛫 2024-12-13 
            - [ ] NEXT if that doesn't work, sign up for some RSS?
    - [ ] Android widget for obsidian tasks query? ⏫ 
- https://github.com/kemayo/obsidian-smart-links
        - Need to press CMD+E to "Toggle Reading Mode" -- known limitation that it doesn't work in edit mode, https://github.com/kemayo/obsidian-smart-links/issues/1
- https://github.com/scambier/obsidian-omnisearch
    - smarter search ordering, instead of the builtin-search order by-timestamp or by-filename
        - downrank folders: `MyNotes/Omnivore,OmnivoreExport,node_modules`
    - [x] set up custom keyboard shortcut?
        - [x] Moved default search to include `CTRL+`
        - [ ] can't do same on #windows need to solve [[keybindings]] problem with double `CTRL` 
    - Can search images, if using https://github.com/scambier/obsidian-text-extractor
    - [ ] Local HTTP server for search results, [user-script](https://publish.obsidian.md/omnisearch/Inject+Omnisearch+results+into+your+search+engine) add results to Google
    - [ ] Can it prioritize exact match? Don't want to always use `"` to get exact jira ticket Id search
- https://github.com/ryanjamurphy/lumberjack-obsidian
    - Only using on Android (on desktop I have [`in` CLI script](../in.ps1) that redirects STDIN to today's daily note)
    - One-tap access from android home-screen to current daily note by opening URL `obsidian://log`
    - Configured:
        - prefix: ""
        - timestamp: false
        - always-new-pane: false
        - inbox: inbox
        - filename: YYYY-MM-DD
    - Set up using [these instructions](https://github.com/ryanjamurphy/lumberjack-obsidian/pull/17/files)
    - [ ] With new Obsidian feature release, could uninstall this?
        - >Daily Notes: New `daily` Obsidian URI action to automatically open or create your daily note.
### Stopped using
- https://github.com/omnivore-app/obsidian-omnivore
    - Config: 
        - Query: sync archived: `in:archive`
        - folder: `MyNotes/Omnivore/{{{date}}}`
        - Article template: add `{{{ content }}}` to the end, `{{{note}}}` to start
    - Doesn't seem to be syncing the "Article Notes" i.e. [this](https://omnivore.app/me/mkdocs-linkcheck-py-pi-19230563b36) ⏫
        - [x] Fixed by adding `{{{note}}}` to template (*separate* from `#highlights .note`) [docs](https://docs.omnivore.app/integrations/obsidian.html#sync-all-the-items-into-a-single-note)
    - [-] Try removing date in folder ❌ 2024-10-31
    - [-] Try configuring this folder to open read-only ❌ 2024-10-31
    - [-] Try some tool to embed the highlights, query whether "inbox" is handled, and to create tasks? ❌ 2024-10-31
    - [-] set up auto sync ❌ 2024-10-31
- https://github.com/fleetingnotes/fleeting-notes-obsidian
    - Now in maintenance mode
    - Can use obsidian android app to share links or write short noteskemayo/obsidian-smart-links/issues/1
- https://github.com/marc0l92/obsidian-jira-issue
    - Felt kind of clunky
    - I often paste in the full JIRA url
    - I have terminal scripts / browser shortcuts to open JIRA issues
- https://github.com/Vinzent03/obsidian-git
    - Stopped because I wanted SSH auth, which isn't supported in mobile JS host
    - Can still view https://github.com/darthwalsh/bin markdown directly
    - [ ] But should be feasible to set up in-vault access using HTTPS and PAT? Test if the git folder plugin would support reading into a parallel subfolder that is ignored by OneDrive? Probably easiest to test first on desktop 🔼 
    - [ ] IF NOT mobile-git, could make a single auto-generated index file in the Personal OneNote that just links to all the files in the bin/ repo? Then from mobile obsidian it can find them all without the git repo locally. (But, would be better to set up the mobile git?)
- [-] Was considering writing [PWA that can write files](https://whatpwacando.today/file-system/) into `inbox/` that could receive natives shares? Would shows some toast/notification to let you edit the markdown file?

### Interested to try
- [ ] https://github.com/zolrath/obsidian-auto-link-title to convert plain URL into title ⏫ 
    - [ ] for private sites https://github.com/zolrath/obsidian-auto-link-title/issues/143
    - [ ] Then consider [[browser.plugins#[Tab Copy - Chrome Web Store](https //chromewebstore.google.com/detail/tab-copy/micdllihgoppmejpecmkilggmaagfdmb)]]
- [ ] https://github.com/ivan-lednev/obsidian-day-planner 🔼 
    - [ ] Block out tasks from Daily / "Periodic Notes" plugin on calendar, with ICS calendar viewing.
    - [ ] Renders future start dates on calendar?
    - [ ] NEXT, https://github.com/702573N/Obsidian-Tasks-Timeline or https://github.com/Leonezz/obsidian-tasks-calendar-wrapper
- [ ] https://github.com/therden/packrat to move completed notes down 🔼 
    - [ ] reply to [this comment](https://www.reddit.com/r/ObsidianMD/comments/19aed04/comment/lnkpnmm/) if it works
    - [ ] NEXT, try https://github.com/ryangomba/obsidian-todo-sort
- [ ] Convert bare URLs into the semantic title, kind of like [Tab Copy Chrome Extension](https://chromewebstore.google.com/detail/tab-copy/micdllihgoppmejpecmkilggmaagfdmb)? 🔼 
    - [ ] Also pasting a URL should in a bare URL text instead of a markdown link with duplicate text/link
- [ ] https://github.com/scambier/obsidian-text-extractor
- [ ] https://github.com/jsrozner/obsidian-tab-shifter
    - [ ] lets you move current tab into a split pane / tag group to the right
    - [ ] >This plugin does not use an official API.
- [ ] https://github.com/ivan-lednev/better-search-views
    - [ ] gives breadcrumbs with subheading context to search result
- [ ] https://github.com/sytone/obsidian-queryallthethings
    - [ ] QATT lets your write SQL and output handlebar templates
- [ ] https://github.com/nothingislost/obsidian-query-control
    - [ ] Extends embedded query search with sorting controls
- [ ] https://github.com/alangrainger/obsidian-lazy-plugins
    - [x] On macbook, takes maybe 4 seconds to open; not too bad. 10 seconds on windows, but the plugins are fast. the slow part is Deferred Tabs(?)
- [ ] Buttons
    - [ ] https://github.com/shabegom/buttons but it's not that maintained
    - [ ] ? https://github.com/mProjectsCode/obsidian-meta-bind-plugin
- [ ] Spaced repetition plug-in to practice [[Internet adages and named laws]]
    - [ ] try https://github.com/debanjandhar12/Obsidian-Anki-Sync
    - [ ] NEXT https://github.com/ObsidianToAnki/Obsidian_to_Anki
    - [ ] NEXT https://github.com/mlcivilengineer/obsankipy
    - [ ] Don't need [[keybindings]] because can use keycombiner.com
- [ ] https://github.com/vslinko/obsidian-zoom which is like a version of [[ObsidianFolderOpen]]
- [ ] AI ChatGPT archive importer
	- [ ] https://github.com/Superkikim/nexus-ai-chat-importer
- [ ] embed a slack message/thread
- [ ] track all my / specific github PRs, so I don't need to poll them
- [ ] a dashboard showing unified inbox: gmail, your Microsoft to do reminders, your obsidian tasks, etc.
- [ ] https://github.com/quanru/obsidian-lifeos
    - [ ] [LifeOS for Obsidian (PARA Method/Periodic Notes/Fullcalendar)](https://lifeos.vip/) 
    - [ ] Don't install, but just look through [Directory Structure)](https://lifeos.vip/guide/quick-start/directory-structure.html) and default plugins like periodic / calendar?
- [ ] better tag refactoring: https://github.com/pjeby/tag-wrangler
- [ ] https://github.com/hdykokd/obsidian-advanced-close-tab prevent pinned tabs from closing
- [ ] https://github.com/liamcain/obsidian-periodic-notes
    - [ ] See [issue](https://github.com/liamcain/obsidian-periodic-notes/issues/249) -- hasn't released in 3 years 👎
- [ ] Vim mode
- [ ] Copy inline text: https://github.com/ozavodny/obsidian-copy-inline-code-plugin
    - [ ] instead of adding buttons, add keyboard shortcut for ALL contextual copy https://github.com/Moyf/easy-copy
- [ ] obsidian CSS to more easily tell difference between H2 H3 H4
- [ ] calulator
    - [ ] (like OneNote where you can enter `1 + 2 =` and it autocompletes the answer!)
- [ ] https://github.com/mvdkwast/obsidian-copy-as-html
- [ ] Append to daily note
	- [ ] Install raycast plugin https://github.com/marcjulianschwarz/obsidian-raycast?tab=readme-ov-file#append-to-daily-note
	- [ ] Requires https://github.com/Vinzent03/obsidian-advanced-uri
#### Some AI tech
- [ ] 2.6k⭐️ https://github.com/brianpetro/obsidian-smart-connections
    - [x] Installed
    - [ ] Document setup ⏫ 
    - [ ] Uses OpenAI API key
    - [ ] ChatGPT on your notes
    - [ ] Suggests links
- [ ] 561⭐️ https://github.com/your-papa/obsidian-Smart2Brain
    - [ ] RAG LLM, also chat, with local LLM
- [ ] 159⭐️ https://github.com/pieces-app/obsidian-pieces
    - [ ] Want to understand more about this Pieces OS
- [ ] 86⭐️ https://github.com/systemsculpt/obsidian-systemsculpt-ai
- [ ] https://github.com/logancyang/obsidian-copilot
#### Tabbing through all hierarchies
#app-idea 
For [[hierarchies]], let you TAB/UNTAB through multiple layers, up from subbullets, to bullets, un-bulleted text, headings, and eventually new files.
i.e. if you TAB-TAB-TAB-indent on some text that is an H4, it would first become plain (un-bulletted) text, then top-level bullet. And the opposite: if you UNTAB-UNTAB-UNTAB-dedent a top-level bullet to be like a H6 or whatever the configured-lowest level is for the document is.
If you keep untabbing, could it become a separate file? 
If so, you could select multiple files in a foldr, and tab, and they each become H1 in one file?
Maybe it could just error out is trying to do something unsupported like create multiple files? Or is the obsidian heading hierarchy doesn't quite line up. This is just unsupported? 
Would be like a proof of concept for my earlier plug-in idea

(Confluence wiki seems to support this untabbing )

### Plugins I've contributed to
- https://github.com/obsidianmd/obsidian-importer/commits?author=darthwalsh
- https://github.com/darthwalsh/obsidian-open-folder/tree/main?tab=readme-ov-file#roadmap-to-v0-mvp-that-can-be-shared-privately
    - 2% complete 
    - plugin for viewing folder as file
    - [ ] related: https://github.com/aidenlx/alx-folder-note

## CSS setup
https://help.obsidian.md/snippets#Adding+a+snippet
Sync to [[dotfiles]]
