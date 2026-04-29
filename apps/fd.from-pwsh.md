#ai-slop #to-anki

`fd` is gitignore-aware by default and prunes ignored subtrees up front — unlike `Get-ChildItem -Exclude`, which filters *after* walking into `node_modules`.

Key mental shift: **`fd` outputs path strings**, not `FileSystemInfo` objects. Add `| Get-Item` when metadata (size, `LastWriteTime`, etc.) is needed downstream.

`| fn` gives you the `FullName` string from a `FileSystemInfo` object (inverse bridge: objects → strings).

---

## 1. Recurse all files by extension

### GCI
```powershell
Get-ChildItem -Path .\src -Recurse -File -Filter *.cs
```

### fd
```powershell
fd --extension cs .\src
```

---

## 2. Find directories matching a name at limited depth

### GCI
```powershell
Get-ChildItem -Path . -Recurse -Directory -Filter bin -Depth 4
```

### fd
```powershell
fd --type directory --max-depth 4 '^bin$' .
```

---

## 3. Include hidden files (dotfiles like `.env`)

### GCI
```powershell
Get-ChildItem -Path . -Recurse -File -Force -Filter *.env
```

### fd
```powershell
fd --hidden --extension env .
```

---

## 4. Delete matched files

### GCI
```powershell
Get-ChildItem -Path . -Recurse -File -Filter *.tmp | Remove-Item -Force
```

### fd
```powershell
fd --extension tmp . | Remove-Item -Force
```

---

## 5. Move files to another folder

### GCI
```powershell
Get-ChildItem -Path .\assets -Recurse -File -Filter *.png |
  Move-Item -Destination .\images
```

### fd
```powershell
fd --type file --extension png .\assets | Move-Item -Destination .\images
```

---

## 6. Sort by last write time, take newest N

### GCI
```powershell
Get-ChildItem -Path .\logs -Recurse -File -Filter *.log |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 10
```

### fd
```powershell
fd --extension log .\logs |
  Get-Item |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 10
```

---

## 7. Find files matching a name pattern (regex)

### GCI
```powershell
Get-ChildItem -Path . -Recurse -File | Where-Object Name -Match '^test_.*\.py$'
```

### fd
```powershell
fd --type file '^test_.*\.py$' .
```

---

## 8. Find large files (size filter)

### GCI
```powershell
Get-ChildItem -Path . -Recurse -File |
  Where-Object Length -GT 10MB |
  Sort-Object Length -Descending
```

### fd
```powershell
fd --type file --size +10m . |
  Get-Item |
  Sort-Object Length -Descending
```

---

## 9. Open/edit matched files (get FullName strings)

### GCI
```powershell
Get-ChildItem -Path . -Recurse -File -Filter *.md | fn
```

### fd
```powershell
fd --extension md .
```

> `fd` already outputs strings, so `| fn` is only needed on the GCI side when piping `FileSystemInfo` objects to tools that expect a path string.

---

## 10. Enumerate only tracked + untracked repo files (gitignore-aware, no fd required)

### GCI
```powershell
# No native equivalent — walks node_modules, .git, etc.
Get-ChildItem -Path . -Recurse -File
```

### git ls-files
```powershell
git ls-files --cached --others --exclude-standard
```

> Use this inside a git repo when you want only files Git knows about (tracked) or would track (untracked, not ignored). Faster than `fd` for repo-scoped enumeration since Git's index is already built.

---

## Cheatsheet

| GCI flag | fd equivalent |
| --- | --- |
| `-Recurse -File` | `fd` (default: files, recursive) |
| `-Directory` | `--type directory` |
| `-Filter *.ext` | `--extension ext` |
| `-Force` (hidden) | `--hidden` |
| `-Depth N` | `--max-depth N` |
| `\| Where-Object Name -Match 'pat'` | `fd 'pat'` (fd arg is a regex) |
| `\| Sort-Object LastWriteTime` | `\| Get-Item \| Sort-Object LastWriteTime` |
| `\| fn` (get path string) | not needed — fd outputs strings |
