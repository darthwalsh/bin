*Note: Seems to work, but Obsidian app doesn't recommend symlinks.*
- [ ] Move the symlink to [[bin/apps/dotfiles|dotfiles]] in git
- [ ] `CMD + OPTION + N` shortcut for `app:toggle-right-sidebar` isn't picked up??? 🛫 2024-09-14 
	- [ ] https://forum.obsidian.md/t/hotkeys-with-opt-alt-char-do-not-work-on-macos-they-insert-a-symbol-when-the-editor-is-active/72431/6?u=darthwalsh
### Symlink the hotkeys.json file to Onedrive:
setup
```powershell
mkdir ~/OneDrive/whatever/.obsidian
mv .obsidian/hotkeys.json ~/OneDrive/whatever/.obsidian/
New-Item -ItemType SymbolicLink -Path .obsidian/hotkeys.json -Target (Resolve-Path ~/OneDrive/whatever/.obsidian/hotkeys.json)
```

then run Obisidian command "Reload app without saving"

- [x] Try doing the same in #windows
- [ ] Bug in powershell to need (Resolve-Path), or my understanding? 🛫 2025-01-01 
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
*If reading files from OneDrive causes problems, could also symlink into this git repo?*

