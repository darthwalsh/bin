<#
.SYNOPSIS
Prints each Unicode code unit, and number
.EXAMPLE
PS> "0 2" | chars
"0" 0x30 48
SPC 0x20 32
"2" 0x32 50
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest


foreach ($line in $input) {
  foreach ($char in $line.ToCharArray()) {
    $code = [int][char]$char
    $hex = $code.ToString("X").PadLeft(2, "0")
    $display = if ([char]::IsControl($char) -or [char]::IsWhiteSpace($char)) {
      $name = switch ($code) {
        0 { "NUL" } 7 { "BEL" } 8 { "BS" } 9 { "TAB" } 10 { "LF" }
        11 { "VT" } 12 { "FF" } 13 { "CR" } 27 { "ESC" } 32 { "SPC" }
        127 { "DEL" } default { "x$hex" }
      }
      $name.PadRight(3)
    } else { "`"$char`"" }
    Write-Output "$display 0x$hex $code"
  }
  ""
}
