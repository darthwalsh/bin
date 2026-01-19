<#
.SYNOPSIS
Pester tests for git-diff-lines.ps1
#>

Describe "git-diff-lines" {
    It "parses standard git diff format with b/ prefix" {
        $diff = @"
diff --git a/file.txt b/file.txt
@@ -1,2 +1,2 @@
 context line
-old line
+new line
"@
        $result = $diff -split "`n" | git-diff-lines
        $result -join "`n" | Should -Be @"
  file.txt:1 context line
- file.txt:2 old line
+ file.txt:2 new line
"@
    }

    It "parses --no-prefix format" {
        $diff = @"
diff --git file.txt file.txt
@@ -1,2 +1,2 @@
 context line
-old line
+new line
"@
        $result = $diff -split "`n" | git-diff-lines
        $result -join "`n" | Should -Be @"
  file.txt:1 context line
- file.txt:2 old line
+ file.txt:2 new line
"@
    }

    It "tracks line numbers across multiple hunks" {
        $diff = @"
diff --git a/test.py b/test.py
@@ -10,1 +10,1 @@
-old at 10
+new at 10
@@ -20,1 +20,1 @@
-old at 20
+new at 20
"@
        $result = $diff -split "`n" | git-diff-lines
        $result -join "`n" | Should -Be @"
- test.py:10 old at 10
+ test.py:10 new at 10
- test.py:20 old at 20
+ test.py:20 new at 20
"@
    }

    It "strips ANSI codes for matching but preserves in output" {
        # Simulate colored diff: ESC[32m for green, ESC[m to reset
        $esc = [char]0x1b
        $diff = @"
diff --git a/file.txt b/file.txt
@@ -1 +1 @@
$esc[32m+colored line$esc[m
"@
        $result = @($diff -split "`n" | git-diff-lines)
        $result.Count | Should -Be 1
        # Should preserve the color code at the start of the line (before + marker)
        $result[0] | Should -BeLike "*+ file.txt:1 colored line*"
    }

    It "handles multiple files" {
        $diff = @"
diff --git a/first.txt b/first.txt
@@ -1 +1 @@
-old first
+new first
diff --git a/second.txt b/second.txt
@@ -5 +5 @@
-old second
+new second
"@
        $result = $diff -split "`n" | git-diff-lines
        $result -join "`n" | Should -Be @"
- first.txt:1 old first
+ first.txt:1 new first
- second.txt:5 old second
+ second.txt:5 new second
"@
    }

    It "skips commit message before diff" {
        $diff = @"
commit abc123
Author: Test <test@example.com>

    Commit message here

diff --git a/file.txt b/file.txt
@@ -1 +1 @@
-old
+new
"@
        $result = $diff -split "`n" | git-diff-lines
        $result -join "`n" | Should -Be @"
- file.txt:1 old
+ file.txt:1 new
"@
    }
}
