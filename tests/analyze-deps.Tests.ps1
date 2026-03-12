BeforeAll {
  . "$PSScriptRoot/../analyze-deps.ps1"
}

Describe 'Get-AstCommandNames' {
  It 'extracts literal command names from a ps1 file' {
    $tmp = [System.IO.Path]::GetTempFileName() + '.ps1'
    Set-Content $tmp 'git status; gh pr list'
    try {
      $names = Get-AstCommandNames $tmp
      $names | Should -Contain 'git'
      $names | Should -Contain 'gh'
    }
    finally {
      Remove-Item $tmp -Force
    }
  }

  It 'does not include commands that only appear inside strings' {
    $tmp = [System.IO.Path]::GetTempFileName() + '.ps1'
    Set-Content $tmp '$x = "git status"'
    try {
      $names = Get-AstCommandNames $tmp
      $names | Should -Not -Contain 'git'
    }
    finally {
      Remove-Item $tmp -Force
    }
  }

  It 'extracts from pipelines and subcommands' {
    $tmp = [System.IO.Path]::GetTempFileName() + '.ps1'
    Set-Content $tmp '"$(echo)$(ls)" | cat && ps'
    try {
      $names = Get-AstCommandNames $tmp
      $names | Should -Contain 'echo'
      $names | Should -Contain 'ls'
      $names | Should -Contain 'cat'
      $names | Should -Contain 'ps'
    }
    finally {
      Remove-Item $tmp -Force
    }
  }
}

Describe 'Build-PathIndex' {
  It 'includes all paths for sudo (both the adsk shadow and /usr/bin/sudo)' {
    $map = Build-PathIndex
    $map['sudo'] | Should -Contain '/usr/bin/sudo'
  }

  It 'includes brew when installed at /opt/homebrew/bin/brew' {
    if (-not (Test-Path '/opt/homebrew/bin/brew')) {
      Set-ItResult -Skipped -Because 'brew not installed'; return
    }
    $map = Build-PathIndex
    $map['brew'] | Should -Contain '/opt/homebrew/bin/brew'
  }

  It 'includes an alias that resolves to an application (brew)' {
    if (-not (Test-Path '/opt/homebrew/bin/brew')) {
      Set-ItResult -Skipped -Because 'brew not installed'; return
    }
    Set-Alias -Name 'test-alias-for-brew' -Value 'brew'
    try {
      $map = Build-PathIndex
      $map['test-alias-for-brew'] | Should -Contain '/opt/homebrew/bin/brew'
    }
    finally {
      Remove-Item Alias:test-alias-for-brew -ErrorAction SilentlyContinue
    }
  }

  It 'does not include PS-only commands (Write-Host, gcm)' {
    $map = Build-PathIndex
    $map.Keys | Should -Not -Contain 'Write-Host'
    $map.Keys | Should -Not -Contain 'gcm'
  }
}

Describe 'Get-NativeDepPath' {
  It 'returns $null when any path is under a system prefix' {
    Get-NativeDepPath @('/opt/homebrew/bin/sudo', '/usr/bin/sudo') |
    Should -BeNull
  }

  It 'returns $null when all paths are inside BinRoot' {
    Get-NativeDepPath @(Join-Path (Get-Bin) 'tool') | Should -BeNull
  }

  It 'returns the first non-binRoot path when no system prefix matches' {
    $result = Get-NativeDepPath @('/opt/homebrew/bin/glow') 
    $result | Should -Be '/opt/homebrew/bin/glow'
  }

  It 'returns $null when path matches an ExtraPrefixes entry' {
    Get-NativeDepPath @('/opt/homebrew/bin/glow') -ExtraPrefixes @('/opt/homebrew/bin/') |
    Should -BeNull
  }

  It 'still returns path when ExtraPrefixes does not match' {
    $result = Get-NativeDepPath @('/usr/local/bin/gh') -ExtraPrefixes @('/opt/homebrew/bin/')
    $result | Should -Be '/usr/local/bin/gh'
  }
}

Describe 'Find-UnhandledDeps' {
  BeforeEach {
    $tmpDir = Join-Path ([System.IO.Path]::GetTempPath()) "analyze-deps-$([System.IO.Path]::GetRandomFileName())"
    New-Item -ItemType Directory $tmpDir | Out-Null

    $pathIndex = [Dictionary[string, List[string]]]::new([System.StringComparer]::OrdinalIgnoreCase)
    ($pathIndex['glow'] = [List[string]]::new()).Add('/usr/local/bin/glow')
    ($pathIndex['uv']   = [List[string]]::new()).Add('/usr/local/bin/uv')
  }
  AfterEach {
    Remove-Item $tmpDir -Recurse -Force
  }

  It 'returns a PSCustomObject with Command, Path, UsedIn' {
    Set-Content (Join-Path $tmpDir 'foo.ps1') 'glow README.md'
    $rows = @(Find-UnhandledDeps $tmpDir $tmpDir $pathIndex @() @())
    $rows | Should -HaveCount 1
    $rows[0].Command | Should -Be 'glow'
    $rows[0].Path    | Should -Be '/usr/local/bin/glow'
    $rows[0].UsedIn  | Should -Be 'foo.ps1'
  }

  It 'UsedIn is relative to BinRoot, not the scanned dir' {
    $subDir = Join-Path $tmpDir 'mac'
    New-Item -ItemType Directory $subDir | Out-Null
    Set-Content (Join-Path $subDir 'bar.ps1') 'glow README.md'
    $rows = @(Find-UnhandledDeps $subDir $tmpDir $pathIndex @() @())
    $rows[0].UsedIn | Should -Be 'mac/bar.ps1'
  }

  It 'suppresses commands in HandledNames' {
    Set-Content (Join-Path $tmpDir 'foo.ps1') 'uv run'
    $rows = @(Find-UnhandledDeps $tmpDir $tmpDir $pathIndex @() @('uv'))
    $rows | Should -BeNullOrEmpty
  }

  It 'suppresses commands covered by ExtraPrefixes' {
    ($pathIndex['brew'] = [List[string]]::new()).Add('/opt/homebrew/bin/brew')
    Set-Content (Join-Path $tmpDir 'foo.ps1') 'brew install glow'
    $rows = @(Find-UnhandledDeps $tmpDir $tmpDir $pathIndex @() @() -ExtraPrefixes @('/opt/homebrew/bin/'))
    $rows | Should -BeNullOrEmpty
  }

  It 'UsedIn shows the first script alphabetically that uses the command' {
    Set-Content (Join-Path $tmpDir 'aaa.ps1') 'glow foo'
    Set-Content (Join-Path $tmpDir 'zzz.ps1') 'glow bar'
    $rows = @(Find-UnhandledDeps $tmpDir $tmpDir $pathIndex @() @())
    $rows[0].UsedIn | Should -Be 'aaa.ps1'
  }
}
