[[vscode.plugins]]
[[vscode.keybindings]]
## Install 64-bit
On Windows, always install the 64-bit version of vscode!
https://stackoverflow.com/a/74698482/771768
>On Windows I had the same problem with dotnet x86 and x64 incompatibility. I have 32-bit vscode installed, which installs `ms-dotnettools.csharp-1.25.2-win32-ia32`, which downloads that x86 version of Omnisharp. But I had `C:\Program Files\dotnet` before `C:\Program Files (x86)\dotnet` on my PATH, so when the vscode extension ran `dotnet` the x64 version was found, which failed.
>
>The fix was to move `C:\Program Files (x86)\dotnet` to be before the x64 dotnet on my PATH, either temporarily on the command line, or in the system environment variables.
## Terminal features
- [ ] Try these
https://code.visualstudio.com/updates/v1_84#_terminal-quick-fixes
*MAYBE these require vscode terminal integration? I have this turned off generally...*

- [ ] Explain errors: triggered via the sparkle icon (Ctrl+.) next to the current terminal prompt.
- [ ] Copilot can now offer CLI command suggestions via the Ctrl+I keybinding when the terminal is focused. This brings up Quick Chat with @workspace /terminal pre-filled: