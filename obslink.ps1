<#
.SYNOPSIS
OBSidian symLINK a file/folder to Obsidian vault ~/notes
.DESCRIPTION
DANGER!!! See caveats below, and ensure that your files are backed up!

Bare-bones copy of https://gitlab.com/BvdG/obsidian-everywhere/-/blob/main/open-in-obsidian.sh

Big difference: DOESN'T check if the item is already inside any vault (either in place or linked)

It is a BAD idea to have multiple open links to the same files: https://help.obsidian.md/Files+and+folders/Symbolic+links+and+junctions
Check your existing vaults and files to ensure the file doesn't already exist in the vault
$obsSystem = if ($IsWindows) { $env:APPDATA } else { "~/Library/Application Support" }
(gc (Join-path $obsSystem "obsidian/obsidian.json") -Raw | ConvertFrom-Json).vaults.PSObject.Properties.Value.path
(gci ~/notes).LinkTarget

Also, DOESN'T mirror the folder structure and symlink the file: just symlinks the folder.

Obsidian seems to do a good job working with symlinks
on macOS:
- Deleting the symlink from Files view just removes the symlink, not affecting the target
- [ ] on Windows symlink to File doesn't show, but symlink to shows and is deleted just fine.

ALSO, DOESN'T seem to need `sleep 1` on my macbook.

See more context in apps/ObsidianFolderOpen.md
.PARAMETER ItemPath
File or Folder
.PARAMETER Remove
Remove existing link instead. (Doesn't change the target.)
#>

param(
    [Parameter(Mandatory=$true)]
    [string] $ItemPath,
    [switch] $Remove=$false
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$item = Get-Item $ItemPath
$notes = Join-Path ~ notes
if (!(Test-Path $notes)) {
    throw "Obsidian vault not found: $notes"
}
$target = Join-Path $notes $item.Name

if ($Remove) {
    $existing = Get-Item $target
    $is_symlink = $existing.Attributes -band [IO.FileAttributes]::ReparsePoint
    if (!$is_symlink) {
        throw "Not a symlink: $target"
    }
    Remove-Item $target
    return
}

function CarefullySymlink($item, $target) {
    if (!(Test-Path $target)) {
        New-Item -ItemType SymbolicLink -Path $target -Value $item.FullName | Out-Null
        return
    }

    $existing = Get-Item $target
    $is_symlink = $existing.Attributes -band [IO.FileAttributes]::ReparsePoint
    if (!$is_symlink) {
        throw "Target already exists and is not a symlink: $target"
    }

    $existing_target = Get-Item $existing.Target
    if ($existing_target.FullName -ne $item.FullName) {
        throw "Target already exists and is a different symlink to a different: $target != $existing_target"
    }
    # Nothing to do: symlink exists and points to the right place
}

CarefullySymlink $item $target

Write-Warning "Ensure that node_modules or .venv are in Obsidian Settings > Files and links > Advanced > Excluded files" # TODO automate detecting large excluded files, MAYBE update .obsidian settings somehow?

if ($item.PSIsContainer) {
    $recent = Get-ChildItem $target -Recurse -Filter "*.md" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (!$recent) { return }
    $vaultRoot = (Resolve-Path $notes).Path
    $relativePath = $recent.FullName.Substring($vaultRoot.Length + 1)
    # MAYBE refactor this relative path to a standalone function for `obsidian open` -- or file a bug to make full paths work like in obsidian:// URI?
} else {
    $relativePath = $item.Name
}
obsidian open vault=notes "path=$relativePath" newtab


