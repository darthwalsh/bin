Describe 'rgg' {
  BeforeAll {
    # Use local fixture: from dir1, rgg searches parent (rgg-data) including sibling dir2
    Push-Location "$PSScriptRoot/rgg-data/dir1"
  }

  AfterAll {
    Pop-Location
  }

  It 'finds files in sibling directories at specified path' {
    $result = rgg -search 'FINDME' -path 'sample.md'
    $result | Should -Match 'dir2/sample.md:.*FINDME'
  }

  It 'glob matches nested files' {
    # matches files anywhere in tree
    $result = rgg -search 'NESTED_FINDME' -path 'nested.md'
    $result | Should -Match 'dir2/subdir/nested.md:.*NESTED_FINDME'
  }

  It 'should find hidden files' {
    $result = rgg -search 'CONFIG' -path '.dotfile'
    $result | Should -Match 'CONFIG'
  }
}
