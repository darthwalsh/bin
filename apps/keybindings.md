---
aliases:
  - hotkeys
---
I try to have similar key-binding/hotkeys across different text editors, across Windows and macOS.

[[obsidian.keybindings]]
https://keycombiner.com/collections/obsidian/
- [ ] Write script that can parse i.e. `~\OneDrive\PixelShare\.obsidian\hotkeys.json` and `~\AppData\Roaming\Code\User\keybindings.json`?
    - [ ] JSON format is different
    - [ ] Does it need to take into account the **default** keybindings too?
    - [ ] windows keyboard has ctrl/WIN/alt, while macos remapped with ctrl/alt/cmd
    - [ ] Goal is to make it easier to think about i.e. "CTRL+B" shouldn't be toggle sidebar because it's already BOLD

[[vscode.keybindings]]
https://keycombiner.com/collections/vscode/
- [ ] Maybe turn off setting-sync for keybindings, and symlink to git or drive?
- [ ] import all these notes from #OneNote
[[Karabiner-Elements]]
- [ ] import all these notes from #OneNote

[[AutoHotKey]]
- [ ] import all these notes from #OneNote
- [ ] defined in [media.ahk](../win/media.ahk)

## System Limitations
macOS: Obsidian can't listen to `CMD+OPTION+N` or `+D`, see [[obsidian.keybindings]]
Semanticallly:
- `CTRL+LEFT` moves cursor
- [ ] What other keyboard movements? #macbook 

Also, lots of keyboard shortcuts are mapped globally by default. e.g. chrome devtools inspector (maybe CMD+OPTION+I) might be mapped to Mail... (or to iTerm, huh...?)
1. Open System Preferences
2. Select Keyboard
3. Select Keyboard Shortcut
4. Scroll through, disabling keyboard shortcuts

Windows: Any key-binding with Windows key is a little suspect. (Basically, don't try to create shared hotkey from macbook using `OPTION` )
## Extra key using CAPS LOCK
- [ ] #macbook try https://hyperkey.app/ or karabiner to remap CAPS
- [ ] NEXT, something similar in windows


