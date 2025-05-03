PowerShell has a complicated history with file encoding for shells. Unlike bash or cmd which push bytes through pipes, pwsh pipelines think in objects, and will write lines of text to files. 
These matter:
- `$OutputEncoding`
- `[Console]::InputEncoding`
- `[Console]::OutputEncoding` 

Generally Unicode is handled OK, but trying to pass a program binary through file redirection causes `10 [LF]` to be replaced by `13,10 [CRLF]` which the EXE file format will not handle gracefully. ([That](https://github.com/darthwalsh/bootstrappingCIL/commit/ddba8da24c064a1944434188f24f06e8e7916b8f#diff-fc0a0c94270a989f660dd2edba7b0dd1f11f61551b73f3a371c219a0eaa3edeaR10) took a long time to debug.)

See [[#Why am I seeing garbled unicode from pipx?]] that a program assuming UTF-8 console encoding can cause text encoding garbage.

## Changing Command Prompt system default to UTF-8
Epic answer: https://stackoverflow.com/a/57134096/771768
- as of Windows 10 version 1903 this feature is _still in beta_ and **fundamentally has _far-reaching consequences_**.
    - Still in beta in Windows 11 24H2
- would set _both_ the system's active OEM _and_ the ANSI code page to `65001`, UTF-8
- Global change, possibly breaks other apps?
- Changes pwsh.exe default, but not powershell.exe: Possibly better to use startup commands instead

### Windows 11 Current defaults
Default seems to be "OEM code page" https://www.ascii-code.com/CP437 but powershell settings matter 
```
$ chcp
Active code page: 437

$ $OutputEncoding
EncodingName      : Unicode (UTF-8)
CodePage          : 65001

$ [Console]::InputEncoding
EncodingName      : OEM United States
WebName           : ibm437

$ [Console]::OutputEncoding
EncodingName      : OEM United States
WebName           : ibm437

$ [char] 188
¼
$ [System.Text.Encoding]::BigEndianUnicode.GetBytes('¼')
0
188
```

## Displaying Unicode in PowerShell
Epic answer: https://stackoverflow.com/a/49481797/771768
- Both pwsh on Windows default to the **legacy system locale** via OEM code page
- _While a TrueType font is active_, the console-window _buffer_ correctly preserves (non-ASCII) Unicode chars. even if they don't _render_ correctly;
- `[Console]::OutputEncoding`: assumption for program output
- **`[Console]::InputEncoding`** sets the encoding for _keyboard input_ or how CLI process receives stdout
- `$PSDefaultParameterValues['*:Encoding'] = 'utf8'` affects all cmdlets. On powershell.exe you'd get UTF-8 files _with BOM_ (do not want this)
- An active `chcp` value of `65001` breaks the console output of some programs in Window before Win10
- [x] Run in windows `$PROFILE`
```powershell
$OutputEncoding = [Console]::InputEncoding = [Console]::OutputEncoding =
                    New-Object System.Text.UTF8Encoding
```

## Default output encoding
Epic answer: https://stackoverflow.com/a/40098904/771768
- Could replace the `> foo.txt` syntax with `| out-file foo.txt -encoding utf8` or `set-file` but this is awkward
- In powershell 5.1+ and pwsh, `>` and `>>` are effectively aliases of `Out-File`
- Can change both with `$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'` (again, on powershell.exe you'd get UTF-8 BOM)

## Why am I seeing garbled unicode from pipx?
Found weird issue where Unicode was being garbled:
```plaintext
$ pipx run pipdeptree
pipdeptree==2.24.0  
Γö£ΓöÇΓöÇ packaging [required: >=24.1, installed: 24.2]  
ΓööΓöÇΓöÇ pip [required: >=24.2, installed: 24.3.1]
```
*I thought the root cause was powershell, see investigation below :(*
*Didn't get error with `uv` though...*

But it wasn't an issue using native pip package
```plaintext
$ pip install pipdeptree
Successfully installed packaging-24.2 pipdeptree-2.24.0
$ .\env\Scripts\pipdeptree.exe
pipdeptree==2.24.0  
├── packaging [required: >=24.1, installed: 24.2]  
└── pip [required: >=24.2, installed: 24.3.1]
```

It also wasn't an issue directly running the package pipx had downloaded:
```plaintext
$ pipx -v run pipdeptree  
pip 24.1.1 (using 24.3.1, "C:\Users\cwalsh\pipx\.cache\4336fc8e23af568\Lib\site-packages")  

$ C:\Users\cwalsh\pipx\.cache\4336fc8e23af568\Scripts\pipdeptree.exe  
Warning!!! Duplicate package metadata found:  
"C:\Users\cwalsh\pipx\shared\Lib\site-packages"  
pip 24.1.1 (using 24.3.1, "C:\Users\cwalsh\pipx\.cache\4336fc8e23af568\Lib\site-packages")  
NOTE: This warning isn't a failure warning.  
------------------------------------------------------------------------  
pipdeptree==2.24.0  
├── packaging [required: >=24.1, installed: 24.2]  
└── pip [required: >=24.2, installed: 24.3.1]
```

Confirmed with direct test:
```plaintext
$ [console]::OutputEncoding.BodyName  
ibm437
$ cat a.py
print("💩")

$ python a.py
💩
$ pipx run a.py
≡ƒÆ⌐
$ uv run a.py
💩

$ [console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ pipx run a.py
💩
```

Known [pipx issue](https://github.com/pypa/pipx/issues/1423#issuecomment-2562896720).

### Red Herring seeing IBM437 where it's expected

I wanted to understand why `[console]::InputEncoding` and `[console]::OutputEncoding` were defaulting to `IBM437`...

It wasn't related to pwsh or Windows Terminal though: starting `conhost.exe` and using CMD:
```
C:\WINDOWS\system32>chcp
Active code page: 437

C:\WINDOWS\system32>systeminfo
OS Version:                10.0.19045 N/A Build 19045
System Locale:             en-us;English (United States)
Input Locale:              en-us;English (United States)

powershell
$ Get-WinSystemLocale | Select-Object Name, DisplayName,
>                         @{ n='OEMCP'; e={ $_.TextInfo.OemCodePage } },
>                         @{ n='ACP';   e={ $_.TextInfo.AnsiCodePage } }

Name  DisplayName             OEMCP  ACP
----  -----------             -----  ---
en-US English (United States)   437 1252
```

This all matches https://serverfault.com/a/836221/243251

- the **ANSI code page** to use when non-Unicode programs call the non-Unicode (ANSI) versions of the Windows API, notably the ANSI version of the `TextOut` function for translating strings to and from Unicode, which notably **determines how the program's strings render in the GUI**.
- the **OEM code page** to make active by default **in _console windows_**

But this setting doesn't prevent showing emoji from the terminal for most apps:
```powershell
$ [console]::OutputEncoding  
BodyName : ibm437  
$ [char]::ConvertFromUtf32(0x1F4A9)  
💩
```
