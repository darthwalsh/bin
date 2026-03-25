#ai-slop 
# Open new note in split pane

Goal: one keystroke → current note stays left, new blank note opens right (or below).

Split always duplicates the current view momentarily — immediately running "New note" in the new pane replaces the duplicate. The brief flicker is expected.

## 0. Built-in commands (no plugins)

Two manual steps, no setup required:

1. Command Palette → **Split right** (or **Split down**)
2. Command Palette → **New note** (`Cmd+N`)

- [ ] Bind **Split right/down** in [[obsidian.keybindings]]

## 1. Tab Shifter plugin

See [[obsidian.plugins#Tab Shifter]] — moves the current tab into a new split pane to the right. Doesn't create a new note, but useful if you want to reposition an existing note.

> Note: does not use an official API.

## 2. QuickAdd macro (one keystroke)

See [[obsidian.scripting#QuickAdd]] for plugin setup.

Create a macro with these **Command** steps:

**2-step (try first):**
1. `Split right` / `Split vertically`
2. `New note`

**3-step fallback** (if split doesn't auto-focus the new pane):
1. `Split right` / `Split vertically`
2. `Focus next pane`
3. `New note`

Same pattern for split-down: replace step 1 with `Split down` / `Split horizontally`.

### Suggested hotkeys

Extending `Cmd+T` (new tab) with modifier variants:

| Action | Hotkey |
|---|---|
| New note, split right | `Cmd+Shift+T` |
| New note, split down | `Cmd+Option+T` |

Bind in Settings → Hotkeys → search for the QuickAdd macro name.

> **Gotcha**: `Cmd+Option+<char>` hotkeys [don't fire on macOS](https://forum.obsidian.md/t/hotkeys-with-opt-alt-char-do-not-work-on-macos-they-insert-a-symbol-when-the-editor-is-active/72431/6) when the editor is active — they insert a Unicode symbol instead. Use [[obsidian.keybindings]] / keycombiner.com to pick an alternative if `Cmd+Option+T` doesn't work.
