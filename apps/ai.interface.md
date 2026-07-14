- [ ] [GitHub Copilot app](https://github.com/features/preview/github-app)
- [ ] [Gemini for macOS](https://gemini.google/mac/) almost identical features to web chat. Main pro is you can enter Live Mode with desktop/app screen share? And has native keyboard shortcuts for launching with context? (if you pay $100/month, can use Spark feature for cloud VM AI Agent)
	- [ ] The web interface at `gemini.google.com` does not support Gemini Live.
- [ ] Find my chat conversation about pivoting this away from CLI/GUI and more for "only chat" or "has bash"

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

### Automatically Referencing Past chats
- [[claude-ai]] [requires paid plan](https://support.claude.com/en/articles/11817273-use-claude-s-chat-search-and-memory-to-build-on-previous-context "Use Claude’s chat search and memory to build on previous context | Claude Help Center")
### Live Mode
Claude.ai has the useful feature that live mode lets you set the voice to be faster.

## Planning / PRD Generator
- [ ] Need to try this more, think if this is a "new interface" or "just asking the chat tool to do a kind of work"
### Kasava requests all private repos
This seemed neat: https://www.kasava.dev/features/plan-generation
- [x] Sent message
> Hey, I tried connecting GitHub and noticed the OAuth prompt requests write access to code, settings, deploy keys, webhooks, and org management. I get that the @kasava bot needs to post comments on issues and PRs, but those extra scopes feel broader than necessary.
> 
> Is there a GitHub App install option that scopes this down to just what the bot actually needs?

- [x] They fixed it now!
- [x] Tried again
- [ ] Look through https://app.kasava.dev/products/3ca1e71b-c34c-42f9-a66e-59ab488bf99d/documents  🔼 

## Work-Specific features enabled
See [[OneDrive/ai]]
