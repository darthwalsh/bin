(Not focusing on claude.ai interactive chat.)

## Model Comparison
*Each model has a different cost-multiplier for tokens used*
- (1x) **Haiku 4.5** - Fastest for quick answers and rapid iteration
- (3x) **Sonnet 4.5 (Default)** - Recommended for most work
- (5x) **Opus 4.5** - Most capable for complex work, architecture decisions, and difficult debugging
- (6x) **Sonnet 1M context** - For long sessions requiring extended context. *Only (4.5x) for output*

## Plan types and sign-in methods

| Plan                       | Official name                                                | Payment                          | Sign in                           | API keys?                  |
| -------------------------- | ------------------------------------------------------------ | -------------------------------- | --------------------------------- | -------------------------- |
| Personal chat subscription | [Claude.ai Max/Pro/Free](https://claude.ai)                  | Credit card, monthly             | Google or email magic link or SSO | No — consumer product only |
| Enterprise/team seats      | [Claude for Work](https://www.anthropic.com/claude-for-work) | Invoice / seat licensing         | SSO via your IdP (Azure AD etc.)  | No — `claude` hides it     |
| Developer access           | [Claude API via Console](https://platform.claude.com)        | Pay-per-token or committed spend | Google, magic link, or SSO        | Yes — you create keys here |
## Account ban risk
A 2026 ban wave targeted consumer OAuth tokens used in third-party tools to automate Claude outside approved clients. [Anthropic's Consumer ToS](https://www.anthropic.com/terms) (Oct 2025) explicitly restricts this; The Register [covered](https://www.theregister.com/2026/02/20/anthropic_clarifies_ban_third_party_claude_access/) enforcement.

Rule of thumb: **API key (Console/developer plan) = safe in any tool. Consumer subscription OAuth in a third-party harness = ban risk.**

| Pattern                                                               | Risk                                                                                              |
| --------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| [claudecodeui](https://github.com/siteboon/claudecodeui) on localhost | Low — drives the official CLI, not raw OAuth                                                      |
| claudecodeui exposed over LAN/internet                                | Medium — ToS bars sharing account access to others                                                |
| Third-party tool (e.g. OpenCode) via consumer OAuth                   | High — this triggered bans ([incident thread](https://github.com/anomalyco/opencode/issues/6930)) |
## claudecodeui on Android Pixel Linux VM
- [ ] Try this!

[claudecodeui](https://github.com/siteboon/claudecodeui) is a Node/Express + WebSocket server with a PTY-backed terminal that drives Claude Code CLI. Running it on the [Pixel Linux Terminal](https://www.howtogeek.com/how-to-use-pixel-hidden-linux-terminal/) (Android 15+ Debian VM) should be feasible for short sessions; leaving it running while multitasking is unreliable.

The core problem with Terminal: Android reclaims the VM when it's backgrounded or under memory pressure.

Mitigations that might help:
- [ ] **Split-screen** Terminal + Chrome (keeps VM foregrounded)
- [ ] **Reduce Node heap**: `NODE_OPTIONS=--max-old-space-size=512` before starting the server
- [ ] **Run browser inside the VM** if the Debian GUI session is usable — avoids Android Chrome competing for RAM
- [ ] **Swap/zram**: some guides report [increasing swap](https://www.androidauthority.com/android-linux-memory-fix-3555799/) reduces crash frequency

See [[HandsFreeCoding]] for the full Pixel VM architecture and mic/audio test results.
