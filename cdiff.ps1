<#
.SYNOPSIS
Gets text from Clipboard and DIFFs the parts
.EXAMPLE
$ python -m unittest test.test_file.TestClass.test_class -v *>&1 | rg AssertionError | scb ; cdiff
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$content = Get-Clipboard

if ($content.StartsWith("AssertionError: ")) {
    $content = $content.Substring("AssertionError: ".Length)
}

$left, $right, $c = $content -split " != " # MAYBE handle other delta patterns too
if ($c) {
    throw "Expected 2 parts, got $($c.Length + 1)"
}
if (!$right) { 
    throw "Expected 2 parts, got 1"
}

$leftPath = New-TemporaryFile
$rightPath = New-TemporaryFile

Set-Content -path $leftPath -value $left
Set-Content -path $rightPath -value $right

# MAYBE switch for GUI: code --diff $rightPath $leftPath

try{
    # Could use --word-diff=porcelain to split diffs by line
    git diff --no-index --word-diff=color --word-diff-regex=. $rightPath $leftPath | tail -n +5
} catch {
}

