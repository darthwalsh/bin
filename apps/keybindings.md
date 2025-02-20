---
aliases:
  - hotkeys
---

- [ ] Write script that can parse i.e. [[hotkeys.json|dotfiles/.obsidian/hotkeys.json]] and `~\AppData\Roaming\Code\User\keybindings.json`? 🔼
    - [x] look for python or js libaries?
    - [ ] JSON format is different
    - [ ] Does it need to take into account the **default** keybindings too?
    - [ ] windows keyboard has ctrl/WIN/alt, while macos remapped with ctrl/alt/cmd
    - [ ] Error on system limitations from other OS
    - [ ] Goal is to make it easier to think about i.e. "CTRL+B" shouldn't be toggle sidebar because it's already BOLD
## editors
### [[obsidian.keybindings]]
https://keycombiner.com/collections/obsidian/
- [ ] Has Navigate back/forward default: on windows it collides with custom sidebar: fix!
- [ ] Come up with "Toggle Left Sidebar" that's not `CTRL+CMD+LEFT` ⏫ 
- [ ] https://github.com/timhor/obsidian-editor-shortcuts project aims to set keybindings similar to vscode
### [[vscode.keybindings]]
https://keycombiner.com/collections/vscode/
- [ ] Maybe turn off setting-sync for keybindings, and symlink to git or drive?
- [ ] import all these notes from #OneNote

- [ ] Ensure something like this is synced
```json
[
  {
    "command": "-editor.action.goToReferences",
    "key": "shift+f12",
    "when": "editorHasReferenceProvider && editorTextFocus && !inReferenceSearchEditor && !isInEmbeddedEditor"
  },
  {
    "command": "editor.action.showSnippets",
    "key": "ctrl+k s"
  },
  {
    "command": "-gitlens.showQuickRepoStatus",
    "key": "alt+s",
    "when": "gitlens:enabled && config.gitlens.keymap == 'alternate'"
  },
  {
    "command": "-references-view.findReferences",
    "key": "shift+alt+f12",
    "when": "editorHasReferenceProvider"
  },
  {
    "command": "references-view.findReferences",
    "key": "shift+f12",
    "when": "editorHasReferenceProvider"
  }
]
```
## Media keys
### [[Karabiner-Elements]]
- [ ] import all these notes from #OneNote
- [ ] Consider mapping some keyboard button to Power button, or Option–Command–Power button, based on [docs](https://support.apple.com/en-us/102650)
- [x] Probably want to use `OPTION+F8` to match windows, and make stepping through chrome debugger easier
### [[AutoHotKey]]
On Windows, define media keys using [media.ahk](../win/media.ahk).
- i.e on default macOS `F8` is pause, but now `ALT+F8`. On Windows, `WIN+F8` sends `Media_Play_Pause`
Install with: `WIN+R` then `shell:startup` then create shortcut to `media.ahk`
## Clipboard
### [[PowerToys]]
- [ ] Paste as plain text, default to `WIN+ALT+CTRL+V` -- maybe make the same as macOS?
## [[WindowManagement]]
### [[WindowManagement#Rectangle|Rectangle]]
- Uses almost all `CTRL+OPTION+` prefixes
- [ ] #macbook copy common shortcuts, generally all `CTRL+OPTION+`
### [[PowerToys]] FancyZones
- `Win+Arrow` keys to move windows
- [ ] Probably want to make the same as Rectangle

## Chrome Browser
[[browser.plugins#Keybindings]]
## Default Common Actions

| Name                                                               | Carl's customization                 | vscode                         | Obsidian                             |
| ------------------------------------------------------------------ | ------------------------------------ | ------------------------------ | ------------------------------------ |
| Go Back<br>Navigate Back                                           | `CTRL+ALT+LEFT`<br>`CMD+OPTION+LEFT` | `ALT+LEFT`<br>`CTRL+-`         | `CTRL+ALT+LEFT`<br>`CMD+OPTION+LEFT` |
| Move Line up                                                       | `ALT+UP`<br>`OPTION+UP`              | `ALT+UP`<br>`OPTION+UP`        | *none*                               |
| Move List+Sublist up<br>(outliner plugin)                          | n/a                                  | n/a                            | `CTRL+SHIFT+UP`<br>`CMD+SHIFT+UP`    |
| Toggle Left Sidebar<br>View: Toggle Primary Side Bar Visibility    |                                      | `CTRL+B`<br>`CMD+B`            | n/a                                  |
| Toggle Right Sidebar<br>View: Toggle Secondary Side Bar Visibility |                                      | `CTRL+ALT+B`<br>`CMD+OPTION+B` | n/a<br>                              |

- [x] Implement all these
	- [x]  #windows
	- [x]  #macbook

| legend                               |
| ------------------------------------ |
| *windows default*<br>*macOS default* |

## System Limitations
### macOS limitations
Obsidian can't listen to `CMD+OPTION+N` or `+D`, see [[obsidian.keybindings]]
Semantically these are part of OS:
- `CMD+LEFT` /`+RIGHT` go to start/end of line
- `OPTION+LEFT` /`+RIGHT` move by one word
- `+SHIFT` with *either* of the above movements selects text
- `CTRL+LEFT` /`+RIGHT` switches spaces (aka desktops) 
	- easy to change: System Preferences > Keyboard > Shortcuts > Mission Control
- `CTRL+UP`: swap windows
- There are other options with `FN-` which is currently mapped to `NUMPAD -` by Karabiner
- Full list: https://support.apple.com/en-us/102650
- [ ] What other keyboard movements? #macbook 

Also, anything with `CTRL+CMD` won't work on other OS where these are semantically the same key

Also, lots of keyboard shortcuts are mapped globally by default. e.g. chrome devtools inspector (maybe CMD+OPTION+I) might be mapped to Mail... (or to iTerm, huh...?)
1. Open System Preferences
2. Select Keyboard
3. Select Keyboard Shortcut
4. Scroll through, disabling keyboard shortcuts

- [ ] create [keyboard shortcut for mac keyboard brightness](https://github.com/pqrs-org/Karabiner-Elements/issues/2645) 🔼 

### Windows limitations
- Any key-binding with Windows key is likely not to work
	- Rule: Don't create macOS hotkey from macbook using `OPTION` 
- Rule: macOS Key-binding can't have both `CMD+CTRL` 
- Rule: `CTRL+ALT+DELETE` is not a good hotkey
## Extra key using CAPS LOCK
- [ ] #macbook try https://hyperkey.app/ or karabiner to remap CAPS 🔼 
- [ ] NEXT, something similar in windows


