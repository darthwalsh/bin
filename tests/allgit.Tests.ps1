<#
.SYNOPSIS
Pester tests for allgit.ps1
#>

BeforeAll {
    # A PowerShell command with a switch, to prove named switches reach the target
    # (the reason agit needed -Expr). Defined here so allgit's Invoke-Expression can see it.
    function Test-Switch {
        param([switch] $Flag)
        "Flag=$Flag"
    }
}

Describe 'allgit' {
    BeforeEach {
        $testRoot = Join-Path (Convert-Path Temp:\) "allgit-test-$(New-Guid)"
        New-Item -ItemType Directory $testRoot | Out-Null
        foreach ($name in 'repoA', 'repoB') {
            git init --quiet (Join-Path $testRoot $name)
        }
        New-Item -ItemType Directory (Join-Path $testRoot 'plain') | Out-Null
        Push-Location $testRoot
    }
    AfterEach {
        Pop-Location
        Remove-Item -Recurse -Force $testRoot -ErrorAction SilentlyContinue
    }

    It 'runs a script block in each git repo' {
        $names = allgit { Split-Path -Leaf (Get-Location) }
        $names | Should -Be @('repoA', 'repoB')
    }

    It 'skips folders that are not git repos' {
        $names = allgit { Split-Path -Leaf (Get-Location) }
        $names | Should -Not -Contain 'plain'
    }

    It 'passes a command with arguments to each repo' {
        $result = allgit git rev-parse --is-inside-work-tree
        $result | Should -Be @('true', 'true')
    }

    It 'passes a switch to a PowerShell command' {
        $result = allgit Test-Switch -Flag
        $result | Should -Be @('Flag=True', 'Flag=True')
    }

    It 'quotes arguments containing spaces' {
        $result = allgit Write-Output 'hello world'
        $result | Should -Be @('hello world', 'hello world')
    }
}
