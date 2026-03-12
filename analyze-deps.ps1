<#
.SYNOPSIS
Analyze native command dependencies across all bin/ scripts.
.DESCRIPTION
Walks the PowerShell AST of all .ps1 files in bin/ (and the OS-specific subdir) to find every command invocation.
For each unique Applications on PATH, check if in system folders or bin/, else error.
To analyze scripts on another OS, use that OS.
#>

using namespace System.Collections.Generic

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$osSubDir = if ($IsWindows) { 'win' } elseif ($IsMacOS) { 'mac' } else { 'lnx' }

$ManagedInstallDirs = @(
  if ($IsWindows) {
    'C:\Windows\System32\',
    'C:\Windows\SysWOW64\'
  }
  else {
    '/usr/bin/', '/bin/', '/sbin/', '/usr/sbin/'
  }
) + @((Get-Bin), (Resolve-Path "~/.local/share/mise"))


# Parse a .ps1 file and return all literal command names found via the AST.
function Get-AstCommandNames([System.IO.FileInfo]$FilePath) {
  $ast = [System.Management.Automation.Language.Parser]::ParseFile(
    $FilePath.FullName, [ref]$null, [ref]$null
  )
  $names = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::OrdinalIgnoreCase
  )
  $ast.FindAll(
    { $args[0] -is [System.Management.Automation.Language.CommandAst] }, $true
  ) | ForEach-Object {
    $elem = $_.CommandElements[0]
    if ($elem -is [System.Management.Automation.Language.StringConstantExpressionAst]) {
      $names.Add($elem.Value) | Out-Null
    }
  }
  # NOTE: locally-defined functions (e.g. `function readRepo` in githist.ps1) will appear in
  # $allCommands but are implicitly filtered: they have no Application entry in $pathIndex.
  # If a local function name collides with a real tool name, it could produce a false positive.
  return $names
}

# Build a raw map of command name → all known Application paths.
# For aliases, uses the alias name and resolves to the terminal application path.
# Not useful to include Functions/Cmdlets with -CommandType All
function Build-PathIndex() {
  $map = [Dictionary[string, List[string]]]::new([System.StringComparer]::OrdinalIgnoreCase)

  Get-Command -CommandType Application -All | ForEach-Object {
    $appName = if ($IsWindows) { [System.IO.Path]::GetFileNameWithoutExtension($_.Name) }
    else { $_.Name }
    ($map[$appName] ??= [List[string]]::new()).Add($_.Source)
  }

  Get-Command -CommandType Alias | ForEach-Object {
    $name = $_.Name
    $cmd = $_
    while ($cmd -is [System.Management.Automation.AliasInfo]) {
      $cmd = $cmd.ResolvedCommand
    }
    if ($null -eq $cmd -or $cmd -isnot [System.Management.Automation.ApplicationInfo]) { return }
    ($map[$name] ??= [List[string]]::new()).Add($cmd.Source)
  }

  return $map
}

# Given all known paths for a command, return the first path that qualifies as a
# native dep, or $null if covered (any path is system, or all paths are in binRoot).
function Get-NativeDepPath(
  [string[]]$Paths,
  [string[]]$ExtraPrefixes = @()
) {
  $allPrefixes = $ManagedInstallDirs + $ExtraPrefixes

  foreach ($path in $Paths) {
    foreach ($prefix in $allPrefixes) {
      if ($path.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $null   # any system instance → whole command is covered
      }
    }
  }

  return $Paths | Select-Object -First 1
}

# Read keys from a deps.yaml file as a set of handled command names.
function Get-DepsYamlKeys([string]$Path) {
  $yaml = Get-Content $Path -Raw | ConvertFrom-Yaml
  return [string[]]$yaml.Keys
}

# Return [PSCustomObject]{ Command; Path; UsedIn } rows for unaccounted deps in $Dir.
# UsedIn is the relative name of the first script that references the command.
function Find-UnhandledDeps(
  [string]$Dir,
  [string]$BinRoot,
  [Dictionary[string, List[string]]]$PathIndex,
  [string[]]$Stems,
  [string[]]$HandledNames = @(),
  [string[]]$ExtraPrefixes = @()
) {
  $files = if (Test-Path $Dir) { Get-ChildItem $Dir -Filter '*.ps1' } else { return }

  # Build command → first script that uses it (relative to BinRoot)
  $firstUsedIn = [Dictionary[string, string]]::new([System.StringComparer]::OrdinalIgnoreCase)
  foreach ($file in $files) {
    $rel = [System.IO.Path]::GetRelativePath($BinRoot, $file.FullName)
    foreach ($cmd in (Get-AstCommandNames $file)) {
      if (-not $firstUsedIn.ContainsKey($cmd)) {
        $firstUsedIn[$cmd] = $rel
      }
    }
  }

  foreach ($name in ($firstUsedIn.Keys | Sort-Object)) {
    if ($name -in $Stems) { continue }
    $paths = $PathIndex[$name]
    if (-not $paths) { continue }   # PS builtin, local function, etc.
    $path = Get-NativeDepPath $paths -ExtraPrefixes $ExtraPrefixes
    if (-not $path) { continue }
    if ($name -in $HandledNames) {
      Write-Verbose "Skipping $name (declared in deps.yaml)"
      continue
    }
    [PSCustomObject]@{ Command = $name; Path = $path; UsedIn = $firstUsedIn[$name] }
  }
}

# Main — skipped when dot-sourced for testing
if ($MyInvocation.InvocationName -ne '.') {
  $pathIndex = Build-PathIndex

  $binRoot = Get-Bin
  $binNames = (Get-ChildItem $binRoot -Filter '*.ps1').BaseName

  $xplatHandled = Get-DepsYamlKeys (Join-Path $binRoot 'deps.yaml')

  # OS-specific package manager prefixes: commands installed here are assumed
  # covered by the OS-level package manifest (Brewfile, scoop, etc.)
  $osPkgPrefixes = @(if ($IsWindows) {
      "$env:USERPROFILE\scoop\shims\"
    }
    elseif ($IsMacOS) {
      '/opt/homebrew/bin/', '/opt/homebrew/sbin/'
    }
    else {
    })

  $osDir = Join-Path $binRoot $osSubDir
  $binOsNames = $binNames + (Get-ChildItem $osDir -Filter '*.ps1').BaseName
  $osHandled = $xplatHandled + (Get-DepsYamlKeys (Join-Path $osDir 'deps.yaml'))

  @(
    # Root scripts: no extra prefixes — every dep must be accounted for
    Find-UnhandledDeps $binRoot $binRoot $pathIndex $binNames $xplatHandled
    # OS-specific scripts: OS package manager prefixes are allowed
    Find-UnhandledDeps $osDir $binRoot $pathIndex $binOsNames $osHandled -ExtraPrefixes $osPkgPrefixes
  ) | Sort-Object Command | Format-Table -AutoSize
}
