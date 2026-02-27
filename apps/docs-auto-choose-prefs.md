#ai-slop 
#app-idea 
# Auto-Select Preferred Tabs on Docs Sites

## Problem

Docs pages often show multiple install/usage variants (OS, shell, package manager), but they don't know your preferences—so you waste time repeatedly clicking the "right" tabs across sites.

## Dead Ends

- **HTTP headers/content negotiation:** no standard for "preferred shell/package manager," and sites won't read custom headers anyway.
- **Relying on OS detection:** can only guess OS (sometimes), not "install with brew" vs macports or bash vs fish, and guesses are often wrong.
- **"Universal" protocol adoption:** would require most doc frameworks/sites to implement it, which won't happen for a consumer-side fix.

## Suggested Solutions

- **Browser extension/userscript:** detect tabbed UI patterns and auto-select tabs based on your preference order (best general consumer solution).
- **Personal "copy helper" extension:** adds a copy button that copies the command from your preferred tab even if the UI doesn't switch (fallback when switching is hard).
- **Per-site rules:** let you pin overrides for specific domains ("this site uses 'Homebrew' label; that site uses 'brew'").
- **LocalStorage seeding:** many doc frameworks (Docusaurus, VitePress, etc.) persist tab selection in localStorage—an extension could pre-populate known keys on first visit.

---

## How an Extension Would Auto-Pick Tabs

### 1. Setup preferences once (ordered lists)

- OS: macOS > Linux > Windows
- Package manager: Homebrew > MacPorts > apt > dnf > pacman
- Shell: zsh > bash > fish

### 2. On each docs page, the extension:

- **Finds tab groups** by scanning for common accessibility patterns:
    - elements with `role="tablist"` containing children with `role="tab"`
    - buttons/links with `aria-controls`, `aria-selected`, `data-state="active"`, etc.
- **Scores each tab label** against your preference lists (normalize text: lowercase, strip punctuation; map synonyms like brew ↔ homebrew, osx ↔ macos, powershell ↔ pwsh).
- **Clicks the best match** in each independent group, in priority order, and remembers what it changed (backs off if you manually override).

### Practical Heuristics

- Treat each detected tablist as a "dimension" and pick the top match per list.
- Only auto-select once per page load; don't fight user clicks.
- Observe late-rendered content (React/Vue/etc.) via MutationObserver, then re-run the matching pass briefly.
