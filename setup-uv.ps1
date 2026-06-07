<#
.SYNOPSIS
Sets up common uv, activating p3env
#>

set_PIP_INDEX_URL 

Write-Host "Not using va on this project! Use " -ForegroundColor Blue -NoNewline
Write-Host "uv sync --all-groups" -ForegroundColor Green -BackgroundColor White -NoNewline
Write-Host " to install dependencies" -ForegroundColor Blue

export UV_PROJECT_ENVIRONMENT=p3env
uv sync --all-groups
. p3env/bin/activate.ps1

function global:ruff {
  throw "TODO ruff should run using pre-commit version somehow??"
}

