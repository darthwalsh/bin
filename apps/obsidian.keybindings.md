
> [!WARNING] ***This is a Work-In-Progress***
> 
> Seems to work, but Obsidian app doesn't recommend symlinks.

### Symlink the hotkeys.json file to Onedrive:
setup
```powershell
mkdir ~/OneDrive/whatever/.obsidian
mv .obsidian/hotkeys.json ~/OneDrive/PixelShare/.obsidian/
```
### macOS creation
```powershell
New-Item -ItemType SymbolicLink -Path .obsidian/hotkeys.json -Target ~/OneDrive/PixelShare/.obsidian/hotkeys.json
```
- [ ] Test the windows version on #macbook 
### Windows creation
```powershell
New-Item -ItemType SymbolicLink -Path .obsidian/hotkeys.json -Target (Resolve-Path ~/OneDrive/PixelShare/.obsidian/hotkeys.json)
```

then run Obisidian command "Reload app without saving"

- [x] Try doing the same in #windows
- [ ] Bug in powershell to need (Resolve-Path), or my understanding? 🛫 2025-01-01 
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

