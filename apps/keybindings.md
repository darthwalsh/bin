---
aliases:
  - hotkeys
---

- [ ] Write script that can parse i.e. `~\OneDrive\PixelShare\.obsidian\hotkeys.json` and `~\AppData\Roaming\Code\User\keybindings.json`? ⏫ 
    - [ ] JSON format is different
    - [ ] Does it need to take into account the **default** keybindings too?
    - [ ] windows keyboard has ctrl/WIN/alt, while macos remapped with ctrl/alt/cmd
    - [ ] Error on system limitations from other OS
    - [ ] Goal is to make it easier to think about i.e. "CTRL+B" shouldn't be toggle sidebar because it's already BOLD
## editors
### [[obsidian.keybindings]]
https://keycombiner.com/collections/obsidian/
- [ ] Has Navigate back/forward default: on windows it collides with custom sidebar: fix!
### [[vscode.keybindings]]
https://keycombiner.com/collections/vscode/
- [ ] Maybe turn off setting-sync for keybindings, and symlink to git or drive?
- [ ] import all these notes from #OneNote
## Media keys
### [[Karabiner-Elements]]
- [ ] import all these notes from #OneNote
- [ ] Consider mapping some keyboard button to Power button, or Option–Command–Power button, based on [docs](https://support.apple.com/en-us/102650)
- [ ] Probably want to use `OPTION+F8` to match windows, and make stepping through chrome debugger easier
### [[AutoHotKey]]
On Windows, define media keys using [media.ahk](../win/media.ahk)
- i.e `F8` on maOS is pause. On Windows, `WIN+F8` sends `Media_Play_Pause`
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

## Default Common Actions

| Name                                      | Carl's customization                 | vscode                  | Obsidian                             |
| ----------------------------------------- | ------------------------------------ | ----------------------- | ------------------------------------ |
| Go Back<br>Navigate Back                  | `CTRL+ALT+LEFT`<br>`CMD+OPTION+LEFT` | `ALT+LEFT`<br>`CTRL+-`  | `CTRL+ALT+LEFT`<br>`CMD+OPTION+LEFT` |
| Move Line up                              | `ALT+UP`<br>`OPTION+UP`              | `ALT+UP`<br>`OPTION+UP` | *none*                               |
| Move List+Sublist up<br>(outliner plugin) | n/a                                  | n/a                     | `CTRL+SHIFT+UP`<br>`CMD+SHIFT+UP`    |

- [ ] Implement all these
	- [x]  #windows
	- [ ] #macbook  ⏳ 2024-12-10

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
## Extra key using CAPS LOCK
- [ ] #macbook try https://hyperkey.app/ or karabiner to remap CAPS 🔼 
- [ ] NEXT, something similar in windows


