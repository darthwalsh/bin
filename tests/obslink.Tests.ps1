Describe 'obslink' {
  BeforeAll {
    # Create a temporary notes directory in home for testing
    # obslink.ps1 expects ~/notes to exist
    $script:notesDir = Join-Path $HOME "notes"
    $script:notesExistedBefore = Test-Path $notesDir
    
    if (-not $script:notesExistedBefore) {
      New-Item -ItemType Directory -Path $notesDir -Force | Out-Null
    }
    
    # Create temporary source directory  
    $script:sourceDir = Join-Path $TestDrive "source"
    New-Item -ItemType Directory -Path $sourceDir -Force | Out-Null
  }
  
  AfterAll {
    # Clean up temp symlinks created in notes directory
    if (Test-Path $notesDir) {
      Get-ChildItem $notesDir | Where-Object { 
        $_.Name -like "*test*" -or $_.Name -like "*special*" 
      } | ForEach-Object {
        if ($_.Attributes -band [IO.FileAttributes]::ReparsePoint) {
          Remove-Item $_.FullName -Force
        }
      }
    }
    
    # Remove notes directory only if we created it
    if (-not $script:notesExistedBefore -and (Test-Path $notesDir)) {
      Remove-Item $notesDir -Recurse -Force
    }
  }

  Context 'URL Encoding' {
    BeforeEach {
      # Initialize captured URL variable
      $script:capturedUrl = $null
    }
    
    It 'uses [uri]::EscapeDataString for URL encoding' -Skip:$IsWindows {
      # Create a test file with spaces in the name
      $testFilePath = Join-Path $sourceDir "special_chars_and_spaces.md"
      "Test" | Out-File $testFilePath
      
      # We can't easily mock Start-Process across script boundaries
      # Instead, let's test by examining the actual behavior difference:
      # HttpUtility.UrlEncode uses + for spaces
      # [uri]::EscapeDataString uses %20 for spaces
      
      # First, let's verify the current behavior by looking at the source
      $obslinkContent = Get-Content "$PSScriptRoot/../obslink.ps1" -Raw
      
      # After the change, it should use [uri]::EscapeDataString
      $obslinkContent | Should -Match '\[uri\]::EscapeDataString'
      
      # And NOT use HttpUtility.UrlEncode
      $obslinkContent | Should -Not -Match '\[System\.Web\.HttpUtility\]::UrlEncode'
    }
    
    It 'encodes spaces as %20 not +' -Skip:$IsWindows {
      # Test the encoding behavior directly
      $testPath = "/home/test/file with spaces.md"
      
      # HttpUtility.UrlEncode uses + for spaces
      $httpUtilEncoded = [System.Web.HttpUtility]::UrlEncode($testPath)
      $httpUtilEncoded | Should -Match '\+' # Should have + for spaces
      
      # [uri]::EscapeDataString uses %20 for spaces  
      $uriEncoded = [uri]::EscapeDataString($testPath)
      $uriEncoded | Should -Match '%20'
      $uriEncoded | Should -Not -Match '\+' # Should not have + for spaces
      
      # Both encode forward slashes
      # The key difference is spaces: + vs %20
      # EscapeDataString is more standard for URI components
    }
  }

  Context 'Symlink Creation' {
    It 'creates a symlink in the vault directory' {
      $sourceFile = Join-Path $sourceDir "link-test.md"
      "Content" | Out-File $sourceFile
      
      # Mock Start-Process to avoid actually opening Obsidian
      Mock -CommandName Start-Process -MockWith { }
      
      & "$PSScriptRoot/../obslink.ps1" -ItemPath $sourceFile
      
      # Verify symlink was created in ~/notes
      $symlinkPath = Join-Path $HOME "notes/link-test.md"
      Test-Path $symlinkPath | Should -Be $true
      
      # Verify it's actually a symlink
      $item = Get-Item $symlinkPath
      $item.Attributes -band [IO.FileAttributes]::ReparsePoint | Should -Not -Be 0
      
      # Verify it points to the source
      $item.Target | Should -Be $sourceFile
    }
    
    It 'does not overwrite existing symlink pointing to same target' {
      $sourceFile = Join-Path $sourceDir "idempotent.md"
      "Content" | Out-File $sourceFile
      
      Mock -CommandName Start-Process -MockWith { }
      
      # Create symlink first time
      & "$PSScriptRoot/../obslink.ps1" -ItemPath $sourceFile
      
      # Run again - should succeed without error
      { & "$PSScriptRoot/../obslink.ps1" -ItemPath $sourceFile } | Should -Not -Throw
    }
    
    It 'throws error if target exists and is not a symlink' {
      $sourceFile = Join-Path $sourceDir "conflict.md"
      "Source content" | Out-File $sourceFile
      
      # Create a regular file in vault with same name
      $conflictFile = Join-Path $HOME "notes/conflict.md"
      "Existing content" | Out-File $conflictFile
      
      Mock -CommandName Start-Process -MockWith { }
      
      # Should throw error
      { & "$PSScriptRoot/../obslink.ps1" -ItemPath $sourceFile } | Should -Throw "*not a symlink*"
    }
  }

  Context 'Remove Symlink' {
    It 'removes existing symlink with -Remove switch' {
      $sourceFile = Join-Path $sourceDir "remove-test.md"
      "Content" | Out-File $sourceFile
      
      Mock -CommandName Start-Process -MockWith { }
      
      # Create symlink
      & "$PSScriptRoot/../obslink.ps1" -ItemPath $sourceFile
      
      $symlinkPath = Join-Path $HOME "notes/remove-test.md"
      Test-Path $symlinkPath | Should -Be $true
      
      # Remove symlink
      & "$PSScriptRoot/../obslink.ps1" -ItemPath $sourceFile -Remove
      
      Test-Path $symlinkPath | Should -Be $false
      # Source file should still exist
      Test-Path $sourceFile | Should -Be $true
    }
    
    It 'throws error when trying to remove non-symlink' {
      # Create a regular file in vault
      $regularFile = Join-Path $HOME "notes/regular.md"
      "Content" | Out-File $regularFile
      
      # Try to remove it as if it were a symlink - need to pass the source path
      # but the target in notes is what matters
      { & "$PSScriptRoot/../obslink.ps1" -ItemPath $regularFile -Remove } | Should -Throw "*Not a symlink*"
    }
  }
}
