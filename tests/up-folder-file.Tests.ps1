Describe 'up-folder-file' {
    BeforeEach {
        $testRoot = Join-Path (Convert-Path Temp:\) "up-folder-file-test-$(New-Guid)"
        New-Item -ItemType Directory $testRoot | Out-Null
    }
    AfterEach {
        Remove-Item -Recurse -Force $testRoot -ErrorAction SilentlyContinue
    }

    It 'replaces a single-file folder with the file' {
        $folder = Join-Path $testRoot 'note'
        New-Item -ItemType Directory $folder | Out-Null
        Set-Content (Join-Path $folder 'note') -Value 'hello'

        up-folder-file $folder

        (Test-Path $folder -PathType Leaf) | Should -BeTrue
        Get-Content $folder | Should -Be 'hello'
    }

    It 'throws when folder has more than one file' {
        $folder = Join-Path $testRoot 'multi'
        New-Item -ItemType Directory $folder | Out-Null
        Set-Content (Join-Path $folder 'a') -Value 'a'
        Set-Content (Join-Path $folder 'b') -Value 'b'

        { up-folder-file $folder } | Should -Throw "*Expected exactly 1 file*"
    }

    It 'throws when folder is empty' {
        $folder = Join-Path $testRoot 'empty'
        New-Item -ItemType Directory $folder | Out-Null

        { up-folder-file $folder } | Should -Throw "*Expected exactly 1 file*"
    }

    It 'throws when path is not a directory' {
        $file = Join-Path $testRoot 'plain.txt'
        Set-Content $file -Value 'x'

        { up-folder-file $file } | Should -Throw "*Not a directory*"
    }
}
