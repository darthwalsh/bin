---
aliases:
    - RecycleBin
    - Trash
---
Where do deleted files go? How to make deletion [[reversible]]?
Typically the OS filesystem manager Delete will actually send to System Trash.

One xplat solution: 
- [trash](https://github.com/sindresorhus/trash) supports macOS, Linux, and Windows

## CLI commands that permanently delete
- `rm`
- `rmdir`
- `del`
- `unlink`
- `mv ... $file`
- `cp ... $file`
- `git clean -fd`
- shell output redirection `>` (truncates the file to zero length)

## Windows
Recycle Bin is a **Shell operation**: a per-volume, protected location managed by Explorer.

- **VB FileIO** has recursive `[Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory()`
- [PSCX `Remove-ReparsePoint`](https://github.com/Pscx/Pscx?tab=readme-ov-file#remove-reparsepoint) is the closest historical attempt
- No project achieves full `Remove-Item` semantic parity
- **COM Shell `delete` verb** (may show UI):
	```powershell
	$shell = New-Object -ComObject Shell.Application
	$item = $shell.Namespace((Split-Path -Parent $path)).ParseName((Split-Path -Leaf $path))
	$item.InvokeVerb("delete")
	```

## macOS
Trash is `~/.Trash/`. Trashing a file moves content to volume's `/.Trashes/<uid>/` and writes a metadata entry to `.DS_Store`.

- Can't just do `mv file ~/.Trash/` if you want Finder integration to view in Trash, and to put the file back in the right place.
- `/usr/bin/trash` included on macOS Ventura (13.0) 
- AppleScript: `tell application "Finder" to delete ...`
- Homebrew `trash`: `trash <path>`: moves to `~/.Trash` with collision handling
- [shell-safe-rm](https://github.com/kaelzhang/shell-safe-rm) (also supports Linux)
- From apps, use API: `-[NSFileManager trashItemAtURL:...]`

## Linux
FreeDesktop.org Trash spec: trash at `~/.local/share/Trash/files/` and `info/` metadata.

- **gio trash** (GLib; follows the spec): `gio trash <path>`
- **trash-cli**: `trash-put`, `trash-list`, `trash-restore`, etc.
- **kioclient** (KDE): `kioclient move <path> trash:/`
- [rmtrash](https://github.com/PhrozenByte/rmtrash) wraps trash-cli

## OneDrive
https://onedrive.live.com/?qt=recyclebin.
Can also [restore](https://onedrive.live.com/?v=restore) *all* edits after a certain time. (Including, can undo other restores.)

## Google Drive
https://drive.google.com/drive/u/0/trash

## Other workarounds
- Filesystem snapshots
- git version control
- Backups: BackBlaze, time machine, [[FileBackup#Borg]]

## Aliases
#ai-slop 
- [ ] Try just `mv -i` e.g. aliases for now?
- [ ] Actually try these (maybe reduce scope, to something that is built-in)

### Pros / cons of interactive-only “safe delete” shims

- **Won’t apply to scripts**: aliases/functions are typically only defined in interactive shell startup files, so non-interactive scripts won’t see them.
    - Footgun: `source ./script.sh` runs in your current interactive shell, so the shim *does* apply.
- **Scope is limited**: you can’t realistically “fix” everything in `## CLI commands that permanently delete`.
    - Redirection (`>`) is handled by the shell before a command runs; you can’t alias your way into an undo buffer.
    - Commands like `git clean -fd` are already explicit “make it gone” tools; wrapping them usually creates false confidence.
- **Flag semantics must be respected**: if you shim `rm`, it needs to either emulate common flags (`-f`, `-r`, `--`) or fail loudly on unsupported ones (silently ignoring flags is worse than breaking).

### bash / zsh (macOS + Linux)

**Install a Trash command** (pick one):

- **Cross-platform (recommended)**: `trash` (Node; macOS/Linux/Windows)
    - `npm install --global trash`
- **macOS**: Homebrew `trash`
    - `brew install trash`
- **Linux**: `trash-cli` (FreeDesktop spec tooling)
    - Debian/Ubuntu: `sudo apt install trash-cli` (provides `trash-put`)

Add this to `~/.zshrc` and/or `~/.bashrc`:

```sh
# Interactive-only.
case "$-" in
  *i*) ;;
  *) return ;;
esac

_trash_cmd() {
  if command -v trash >/dev/null 2>&1; then
    trash "$@"
  elif command -v gio >/dev/null 2>&1; then
    gio trash "$@"
  elif command -v trash-put >/dev/null 2>&1; then
    trash-put "$@"
  else
    printf '%s\n' "rm shim needs a trash command (trash/gio/trash-put) installed" >&2
    return 127
  fi
}

rm() {
  # Supports: rm [-f] [-r|-R] [--] paths...
  # Fails on unknown flags to avoid silently ignoring intent.
  local force=0 recurse=0 arg
  while [ "$#" -gt 0 ]; do
    arg=$1
    case "$arg" in
      --) shift; break ;;
      -*) # parse short flags, including combined like -rf
        arg=${arg#-}
        while [ -n "$arg" ]; do
          case "${arg%${arg#?}}" in
            f) force=1 ;;
            r|R) recurse=1 ;;
            *) printf '%s\n' "rm shim: unsupported flag: -${arg%${arg#?}}" >&2; return 2 ;;
          esac
          arg=${arg#?}
        done
        shift
        ;;
      *) break ;;
    esac
  done

  if [ "$#" -eq 0 ]; then
    printf '%s\n' "rm shim: missing operand" >&2
    return 1
  fi

  # Basic parity: refuse directories unless -r/-R.
  if [ "$recurse" -eq 0 ]; then
    for arg in "$@"; do
      if [ -d "$arg" ]; then
        printf '%s\n' "rm shim: $arg: is a directory" >&2
        return 1
      fi
    done
  fi

  # Trash tools generally don't have an rm-like -f; we treat -f as “don't prompt”.
  # If your trash tool prompts, configure it separately.
  _trash_cmd -- "$@"
}
```

### PowerShell (Windows + macOS)

**Install** (recommended, cross-platform): `trash` (Node)

```powershell
npm install --global trash
```

Add to your PowerShell profile (`$PROFILE`):

```powershell
function Remove-ToTrash {
    [CmdletBinding(DefaultParameterSetName = "Path")]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = "Path")]
        [string[]] $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "LiteralPath")]
        [string[]] $LiteralPath
    )

    begin {
        $trash = Get-Command trash -ErrorAction SilentlyContinue
    }

    process {
        $inputs = if ($PSCmdlet.ParameterSetName -eq "LiteralPath") { $LiteralPath } else { $Path }
        foreach ($p in $inputs) {
            foreach ($rp in (Resolve-Path -LiteralPath $p -ErrorAction Stop)) {
                $fsPath = $rp.ProviderPath

                if ($trash) {
                    & $trash.Source -- $fsPath
                    continue
                }

                if (-not $IsWindows) {
                    throw "trash command not found. Install it (npm i -g trash) or add a platform-specific fallback."
                }

                if (Test-Path -LiteralPath $fsPath -PathType Container) {
                    [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory(
                        $fsPath,
                        [Microsoft.VisualBasic.FileIO.UIOption]::OnlyErrorDialogs,
                        [Microsoft.VisualBasic.FileIO.RecycleOption]::SendToRecycleBin
                    )
                } else {
                    [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile(
                        $fsPath,
                        [Microsoft.VisualBasic.FileIO.UIOption]::OnlyErrorDialogs,
                        [Microsoft.VisualBasic.FileIO.RecycleOption]::SendToRecycleBin
                    )
                }
            }
        }
    }
}

# Common muscle-memory shims (interactive profiles only).
Set-Alias rm    Remove-ToTrash -Force
Set-Alias ri    Remove-ToTrash -Force
Set-Alias del   Remove-ToTrash -Force
Set-Alias rmdir Remove-ToTrash -Force
```
