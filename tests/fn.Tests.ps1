Describe 'fn' {
  It 'returns FullName for FileInfo objects' {
    $testFile = Get-Item $PSCommandPath
    $result = $testFile | fn
    $result | Should -Be $testFile.FullName
  }

  It 'returns FullName for DirectoryInfo objects' {
    $testDir = Get-Item $PSScriptRoot
    $result = $testDir | fn
    $result | Should -Be $testDir.FullName
  }

  It 'returns Source for ExternalScriptInfo objects' {
    $scriptInfo = Get-Command fn
    $result = $scriptInfo | fn
    $result | Should -Be $scriptInfo.Source
  }

  It 'handles direct file path input' {
    $testFile = Get-Item $PSCommandPath
    $result = fn $testFile
    $result | Should -Be $testFile.FullName
  }

  It 'throws error for objects without Source or FullName properties' {
    $badObject = [PSCustomObject]@{ Name = 'test' }
    { $badObject | fn } | Should -Throw "Input object does not have Source or FullName property"
  }
}
