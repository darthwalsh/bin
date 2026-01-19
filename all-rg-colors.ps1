<#
.SYNOPSIS
Output all ripgrep --colors options
.DESCRIPTION
Shows all named colors available for rg --colors 'match:fg:COLOR' and 'match:bg:COLOR'
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$colors = @('red', 'green', 'yellow', 'blue', 'magenta', 'cyan', 'white', 'black')

"Foreground colors:"
foreach ($color in $colors) {
    $cmd = "rg --colors match:fg:$color"
    $out = $cmd | rg --color always --colors "match:fg:$color" $color
    "  $out"
}

""
"Combined (black fg on colored bg):"
foreach ($color in $colors) {
    if ($color -eq 'black') { continue }
    $cmd = "rg --colors match:fg:black --colors match:bg:$color"
    $out = $cmd | rg --color always --colors 'match:fg:black' --colors "match:bg:$color" $color
    "  $out"
}
