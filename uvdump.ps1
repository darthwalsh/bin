<#
.SYNOPSIS
Dump installed uv tools to current github repo
#>

[CmdletBinding()]
param()

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
  Write-Verbose "uv not found"
  return
}

function Get-UvToolSummary($ToolName, $ToolsRoot) {
  $python = Join-Path $ToolsRoot $ToolName $(if ($IsWindows) { "Scripts/python.exe" } else { "bin/python" })
  if (-not (Test-Path -LiteralPath $python)) { return }

  Write-Verbose "Getting summary for $ToolName using $python"
  & $python -X utf8 -c @"
import importlib.metadata
import sys

try:
    print(importlib.metadata.metadata(sys.argv[1])["Summary"])
except Exception:
    pass
"@ $ToolName
}

$toolsRoot = uv tool dir
$tools = @(Get-ChildItem -Path $toolsRoot -Directory | ForEach-Object Name | Sort-Object)

$lines = [System.Collections.Generic.List[string]]::new()
foreach ($tool in $tools) {
  $summary = Get-UvToolSummary $tool $toolsRoot
  if ($summary) {
    $lines.Add("## $summary")
  }
  $lines.Add($tool)
}

$uvfile = Join-Path (Get-Bin) apps "uvdump-$(hostname).md"
Set-Content -Path $uvfile -Value $lines -Force
"Written to $uvfile"
