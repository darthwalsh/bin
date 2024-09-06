
> [!WARNING] ***This is a Work-In-Progress***

### Symlink the hotkeys.json file to Onedrive:
```pwsh
mkdir ~/OneDrive/whatever/.obsidian
mv .obsidian/hotkeys.json ~/OneDrive/PixelShare/.obsidian/
New-Item -ItemType SymbolicLink -Path .obsidian/hotkeys.json -Target ~/OneDrive/PixelShare/.obsidian/hotkeys.json
cat .obsidian/hotkeys.json/
```
*If reading files from OneDrive causes problems, could also link into this git repo*

- [ ] Try doing the same in #windows 