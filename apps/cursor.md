- [ ] With the new [Agents Window](https://cursor.com/blog/cursor-3) does this solve all the problems below?

## Searching workspace chats
[cursor-history](https://github.com/S2thend/cursor-history) is fast
```
npx -y cursor-history search YOUR_SEARCH_TEXT
npx -y cursor-history show 1 --only user,assistant --short
npx -y cursor-history export 1 -o ~/notes/MyNotes/inbox/ai/cursor-chat.md
```
Has a library too! https://github.com/S2thend/cursor-history?tab=readme-ov-file#library-api
## Browsing all workspace chats
Try some of these? might be better than [[#cursor-chat-browser]]
- [ ] [Cursor Chronicle – search, export, and analyze your Cursor chat history - Showcase / Built for Cursor - Cursor - Community Forum](https://forum.cursor.com/t/cursor-chronicle-search-export-and-analyze-your-cursor-chat-history/153309)  
- [ ] [saharmor/cursor-view: Browse, search, export, and share your entire Cursor AI chat history](https://github.com/saharmor/cursor-view)  
- [ ] [abakermi/vscode-cursorchat-downloader: View and download your Cursor AI chat history](https://github.com/abakermi/vscode-cursorchat-downloader)
### cursor-chat-browser
Clone and run https://github.com/thomas-pedersen/cursor-chat-browser
- Can browse most chats, but not cursor worktree?
	- [ ] look into [Chat missing ](https://github.com/thomas-pedersen/cursor-chat-browser/issues/23#issuecomment-2661116563) for git worktrees missing

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
