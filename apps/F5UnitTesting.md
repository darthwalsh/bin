---
tags: app-idea
created: 2017-10-02
---
*I originally thought of this for Visual Studio, but now using vscode launching the debugger is simple with [[vscode.keybindings]]*
```json
{
  {
    "command": "test-explorer.redebug",
    "key": "f6",
    "when": "debugState != 'running'"
  },
  {
    "command": "test-explorer.rerun",
    "key": "ctrl+f6",
    "when": "debugState != 'running'"
  }
}
```
## Original idea
https://visualstudio.uservoice.com/forums/121579-visual-studio-ide/suggestions/31718125-pressing-f5-on-a-test-project-should-run-tests-in
- [ ] hack together a solution if Visual Studio doesn't think it's worth implementing this...
- Maybe make the unit test project a console app, find the TestResults folder to deduce what was run last, and launch vstest.console by either using reflection to call the Main method or launching a new process (under the debugger?) 
- Maybe a VS extension could support this?

