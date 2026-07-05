- [ ] With the new [Agents Window](https://cursor.com/blog/cursor-3) does this solve all the problems below?

Agent extensibility: [[mcp]] servers for callable tools, [[ai.skills]] for workflow instructions. Cursor has no plugin/marketplace layer — see [[ai.plugins]].

## Agent skills

Cursor adopts the [Agent Skills open standard](https://agentskills.io/specification) ([[ai.skills]]). Official docs: [Cursor Skills](https://cursor.com/docs/context/skills).

| Scope | Path |
| ----- | ---- |
| Personal | `~/.cursor/skills/<skill-name>/SKILL.md` |
| Project | `.cursor/skills/<skill-name>/SKILL.md` |

The agent loads skill metadata at startup and reads the full `SKILL.md` when a skill is activated. Invoke by name in chat (`Run slack-catchup`) — there are no slash commands.

### Installing from a Claude Code plugin

Extract the `skills/<name>/` directory from a [[claude.plugins|Claude Code plugin]] checkout and symlink or copy it into `~/.cursor/skills/`. Details: [[ai.skills#Port a skill between hosts]].

## Gaps in Cursor's Dev Container support vs VS Code

Cursor-specific concerns with [[devcontainer]]:

- Use the **Anysphere**-published Dev Containers extension (not Microsoft's). Cursor is a VS Code fork; Microsoft's extension may conflict.
- The `customizations.vscode.extensions` block in `devcontainer.json` may not install correctly with the Anysphere extension — some extension lists cause failures.
- Removing extensions with a `-` prefix (negative extension directives) is not reliably supported.
- Occasional SSH/container attachment mismatches on reconnect.

## Searching workspace chats
- [ ] Update this with the [Cursor Agents Windows](https://cursor.com/blog/cursor-3) which solves many of these problems!
	- [ ] AI says: stop treating Cursor’s archive as a reliable retrieval system. Archiving may keep the UI clean, but it looks risky as your long-term “audit log.”

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
## Billing and request multipliers
See [[cursor.billing]] for per-model request multipliers, the "long chat = 1 request" behavior, and the post-quota Auto-fallback.

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
