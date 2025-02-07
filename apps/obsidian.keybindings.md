- [ ] disable `CTRL+-` for zooming in?
	- [ ] not a built-in hotkey, but part of electron: https://forum.obsidian.md/t/disable-zoom-in-out-hotkeys/81909
	- [ ] Probably feasible to re-map using either macOS system preferences or karabiner

## macOS keybinding limitation for  `CMD + OPTION + N`
`CMD + OPTION + N` shortcut for `app:toggle-right-sidebar` isn't picked up: [known problem ](https://forum.obsidian.md/t/hotkeys-with-opt-alt-char-do-not-work-on-macos-they-insert-a-symbol-when-the-editor-is-active/72431/6?u=darthwalsh)
- [x] Set up https://keycombiner.com to pick different keys
- [ ] Test https://keycombiner.com/collecting/collections/personal/36109/# on #windows  

## Symlink the hotkeys.json file to git dotfiles
*Note: Seems to work, but Obsidian app doesn't recommend symlinks for content.*
See [[dotfiles]] for process.
Seems to work well to link:
- appearance.json
- core-plugins.json
- daily-notes.json
- graph.json
- hotkeys.json

Don't link `community-plugins.json` because making changes to this JSON outside obsidian doesn't change what plugins are installed.

### Initial process: symlink setup using Onedrive
- [ ] Archive these old steps
setup
```powershell
mkdir ~/OneDrive/whatever/.obsidian
mv .obsidian/hotkeys.json ~/OneDrive/whatever/.obsidian/
New-Item -ItemType SymbolicLink -Path .obsidian/hotkeys.json -Target (Resolve-Path ~/OneDrive/whatever/.obsidian/hotkeys.json)
```

then run Obisidian command "Reload app without saving"

- [x] Try doing the same in #windows
- [ ] Bug in powershell to need `Resolve-Path`, or my understanding? 🔼 
	- [ ] Also, test code in `obslink.ps1`:
```powershell
$notes = Join-Path ~ notes
$target = Join-Path $notes $item.Name
New-Item -ItemType SymbolicLink -Path $target -Value "whatever"
```


...so, should work to use `New-Item -ItemType SymbolicLink -Path .obsidian/hotkeys.json -Target ~/OneDrive/PixelShare/.obsidian/hotkeys.json` but whatever...
*Without the `Resolve-Path` creating the symlink literally points at `~\` instead of the HOME dir...?*
*Probably fixed in [[pwsh.experimental]] PSNativeWindowsTildeExpansion vs PSNativePSPathResolution*

```plaintext
09/07/2024 06:59 AM <SYMLINK> hotkeys.json [~\OneDrive\PixelShare\.obsidian\hotkeys.json]  
09/07/2024 07:01 AM <SYMLINK> hotkeys2.json [C:\Users\cwalsh\OneDrive\PixelShare\.obsidian\hotkeys.json]
```

### test creation
```
cat .obsidian/hotkeys.json/
```

