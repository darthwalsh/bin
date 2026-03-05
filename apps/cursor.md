## Browsing all workspace chats
Clone and run https://github.com/thomas-pedersen/cursor-chat-browser
- Can browse most chats, but not cursor worktree?
	- [ ] look into [Chat missing ](https://github.com/thomas-pedersen/cursor-chat-browser/issues/23#issuecomment-2661116563)

- [ ] WAIT on [No Way To Search All Chats or Export All Chats · Issue #34](https://github.com/thomas-pedersen/cursor-chat-browser/issues/34)
## Model Multipliers
I tried asking ChatGPT for the model multipliers (i.e. **Gemini-3-Flash** uses 0.5x token multiplier, while **Opus** uses 5x?) But the numbers didn't match https://cursor.com/en-US/dashboard?tab=usage

*AI finding: after you hit your monthly limit, you can keep using Auto model selection without additional usage-based pricing*
## Workaround for pwsh crashing Agent

Cursor’s integrated agent defaults to PowerShell, causing:
```
System.InvalidOperationException: Cannot locate the offset in the rendered text that was pointed by the original cursor.
   at Microsoft.PowerShell.PSConsoleReadLine.RecomputeInitialCoords(Boolean isTextBufferUnchanged) 
   at Microsoft.PowerShell.PSConsoleReadLine.ReallyRender(RenderData renderData, String defaultColor) 
   at Microsoft.PowerShell.PSConsoleReadLine.ForceRender() 
   at Microsoft.PowerShell.PSConsoleReadLine.Insert(Char c) 
   at Microsoft.PowerShell.PSConsoleReadLine.SelfInsert(Nullable`1 key, Object arg) 
   at Microsoft.PowerShell.PSConsoleReadLine.ProcessOneKey(PSKeyInfo key, Dictionary`2 dispatchTable, Boolean ignoreIfNoAction, Object arg) 
   at Microsoft.PowerShell.PSConsoleReadLine.InputLoop() 
   at Microsoft.PowerShell.PSConsoleReadLine.ReadLine(Runspace runspace, EngineIntrinsics engineIntrinsics, CancellationToken cancellationToken, Nullable`1 lastRunStatus)
```

`PSReadLine` crashes under Cursor’s terminal rendering.
If you set *your* Cursor default shell to `pwsh` then you can't change the *agent's* default back to `zsh`.

It's [been](https://forum.cursor.com/t/composer-agent-terminal-powershell-readline-issues-new-since-0-44/36943) reported [before](https://forum.cursor.com/t/powershell-terminal-integration-issues-in-cursor-ai/53099/11).
### Solution: Conditional Shell Switch
`printenv` diff between terminal and agent shows several signals we can use.
1. Set `zsh` as default shell in Cursor settings.
2. In `~/.zshrc`, detect Cursor terminal and only then switch to PowerShell:
```bash
if [ "$TERM_PROGRAM" = "vscode" ] && [ "$TERM" = "xterm-256color" ]; then
    echo "Detected vscode/cursor terminal! Switching to PowerShell..." >&2
    exec pwsh
fi
```

Now, iTerm2 and Cursor agent shells stay in `zsh`.
Cursor terminal automatically switches to `pwsh`!
