We have CLI coding agents running in CLI/Desktop window, and code running locally/cloud

| Category                                                        | code runs | UI paradigm               | Latency (s) |
| --------------------------------------------------------------- | --------- | ------------------------- | ----------- |
| CLI :SiGooglegemini::SiGithubcopilot::SiClaude::SiCursor:       | Both      | Terminal                  | 1–10        |
| IDE :SiGooglegemini::SiGithubcopilot::SiCursor::SiIntellijidea: | Both      | Desktop                   | 1–8         |
| Cloud workspace :SiGooglegemini::SiGithubcopilot:               | Cloud     | Web app<br>(desktop-size) | 2–15        |
| Agent sessions :SiGithubcopilot::SiClaude::SiCursor:            | Cloud     | Web + Mobile              | 3–120       |

- [ ] Look into how fast github agent sessions are when used interactively
- [ ] Check the emojis works after updating [[obsidian.plugins|Iconizer Plugins]] for latest SimpleIcons in 
## Interactive Chat
ChatGPT, Gemini, claude.ai chat have many nice features like Projects with nice [[RAG]].
But the are isolated to the web interface only -- not accessible through automation in e.g. CLI coding agent.

## Work-Specific features enabled
See [[OneDrive/ai]]
