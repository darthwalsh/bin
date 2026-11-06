#ai-slop

# AI chat search: referencing a specific past chat

Question: if you tell an AI "look back at what we discussed six months ago," how well can it find that *specific past chat* — as opposed to working from a synthesized profile of you?

Researched 2026-10-28. Facts below are as of that date; memory features are shipping fast, so re-check before relying on details.

## The two mechanisms (don't conflate them)

- **Synthesized profile** — the app builds a running summary of facts/preferences about you and injects it into new chats. Good for "what are my preferences / what am I working on." Weak for exact quotes, decisions, or a specific thread.
- **History retrieval** — the app searches your actual past conversations and pulls the specific discussion, ideally with a clickable reference back to the original chat. This is what "something from six months ago" actually tests.

## Where they differ

| Capability | ChatGPT | Claude | Gemini | Muse (Cosmo) |
|---|---|---|---|---|
| Searches actual past conversations on request | Yes, with Reference Chat History on | Yes, on-demand retrieval; best inside Projects | Not reliably | Yes — searches saved transcripts incl. side chats |
| Links/cites the original chat so you can verify | Yes | Partial (shows sources within Projects) | No | Yes — can quote the original messages and show where a memory came from |
| Memory model | Auto-synthesized "Dreaming" profile + saved memories | Running summary, refreshed ~every 24h | Saved info / Personal context list | Curated long-term memory files + full transcripts |
| Profile updates itself as facts change | Yes (Dreaming V3 rewrites stale facts) | Summary regenerates | Partial | Yes — Cosmo reconciles corrections into memory |
| Paid plan needed for real history referencing | Plus or Pro | No — free since 2026-03 | No | n/a |

Same across all four:

- None of them can read another app's chat history. Memory is a walled garden per product — whichever app holds the six-month-old conversation is the only one that can go find it.
- All four maintain *some* synthesized profile of preferences/facts, not just verbatim recall.

## Reference facts

### ChatGPT (OpenAI)

- "Reference chat history" announced 2025-04; ChatGPT can personalize from all past conversations.
- 2026-01: Plus/Pro gained full chat-history search back to account creation; when a past chat is used, it's shown as a clickable reference so you can open the original and verify.
- 2026-06-04: "Dreaming V3" memory rewrite rolled out (Plus/Pro, US first; Free/Go/international following). A single background process synthesizes memory across many conversations and updates existing memories as circumstances change (OpenAI's example: "you're going to Singapore in July" rewrites itself to "you went to Singapore in July 2026").
- OpenAI's self-reported evals: factual recall 67.9% → 82.8% with Dreaming V3; not independently audited.
- 2026-08: separate "Reference Chat History" toggle shipped, **off by default**, enabling search-and-cite of specific past conversations rather than relying only on synthesized summaries.
- Caveat: synthesized memory can be wrong or stale; the cite-the-original toggle is what makes specific claims checkable.

### Claude (Anthropic)

- Memory launched 2025-08 to paid plans; all paid users by 2025-10; free users 2026-03.
- Memory is a summarized synthesis, updated about every 24 hours — not verbatim storage.
- Distinctive approach: retrieval on demand. With memory enabled, Claude searches your past conversations when the question calls for it, rather than pre-loading everything.
- Inside **Projects**, conversation access is much stronger: you can ask Claude to reference past project discussions and it searches them and pulls specifics ("what did we decide last Tuesday" works). Outside Projects, expect good preference/theme recall, fuzzier recall of a detail from a random months-old chat.
- Chat memory is separate from Claude Code's push-to-talk voice input (that's dictation, not this).

### Gemini (Google)

- Learned-from-past-chats personalization rolled out 2025-08; renamed from "past chats" to "memories" 2026-03.
- Personal Intelligence (2026-01) connects Gmail, Photos, YouTube, and Search — Gemini knows your Google life better than it knows your Gemini chats.
- Weak spot for this use case: per Google support experts (2026-09), each chat is still fundamentally its own session, and "full automatic recall of every past conversation isn't something to count on yet." The reliable path is Saved info / Personal context — facts you can see and edit.
- No full-text search over the content of your own past conversations.
- Gotcha: remembered info is tied to the underlying chats/activity. Deleting a chat can remove the personalization derived from it. Don't delete source chats for facts you want kept unless they're also in Saved info.
- Personal Google accounts only — work/school accounts may not have these features.

### Muse (Cosmo)

- Not a profile-only system: Cosmo keeps curated long-term memory files (facts, decisions, commitments) **plus** searchable transcripts of past conversations, main chat and side chats.
- On request, Cosmo searches and reads the original messages, and can show where a stored memory came from (which conversation, what replaced what).
- Long threads get compacted into summaries in active context, but the original records remain retrievable.
- Corrections propagate: tell Cosmo a memory is wrong and it reconciles the stored entries, not just the current answer.
- Limits: history here only starts 2026-09 (account creation), so "six months ago" doesn't exist yet; curated memory holds what was judged durable — an offhand remark may need a transcript dig rather than being instantly at hand.

## Settings: precise steps

### ChatGPT

1. Open Settings → **Personalization** → **Memory**.
2. Turn on **Reference saved memories** (the explicit fact list).
3. Turn on **Reference chat history** (the search-and-cite mode; off by default as of 2026-08).
4. Review what's stored under **Manage memories** / the memory summary page; delete or correct stale entries — worth a periodic glance now that synthesis is automatic.
5. **Plan:** Plus or Pro for full-history search and Dreaming V3. Free gets a lighter, short-term version.

### Claude

1. Open Settings → **Capabilities** → **Memory**.
2. Turn on memory ("generate memory from chat history").
3. For reference-heavy work, put the conversations in a **Project** — that's where full past-conversation access applies.
4. **Plan:** not required — memory is on all plans including free (since 2026-03). Project *sharing* is Team/Enterprise only, but that doesn't affect your own recall.

### Gemini

1. Gemini → profile icon → **Settings** → **Personal context** (a.k.a. Saved info): add/edit the facts you want carried across chats.
2. Make sure past-chat personalization is on in Personal context, and that **Gemini Apps Activity → Keep Activity** is on (myactivity.google.com → Gemini Apps Activity).
3. Optional: Settings & help → **Personal Intelligence** to connect Gmail/Photos/etc. — separate from chat memory, and per-app revocable.
4. **Plan:** not required; needs a personal Google account.

### Muse

- Nothing to enable — memory and transcript search are on by design.
- Useful commands: "what do you remember about X," "show me where that memory came from," "forget X."

## Exports via browser extensions (placeholder)

TODO — ongoing project (Carl): use browser extensions to export full chat logs from the ChatGPT / Claude / Gemini web UIs, so verbatim local copies exist independent of each app's built-in memory and search.

- Goal: local, searchable archive of all AI chat history (feeds the Obsidian / second-brain setup).
- Open questions: which extensions, export format (Markdown vs JSON), per-app coverage, incremental vs full re-export.
- Muse-side logs don't need an extension: Cosmo can generate exports directly and rsync them into a Syncthing folder once this machine is a Syncthing peer (scope/cadence TBD).

## Sources

- ChatGPT Dreaming V3 and recall figures: https://www.techtimes.com/articles/317840/20260605/chatgpt-memory-dreaming-update-openai-rewrites-personalization-engine-limits-audit-trail.htm
- ChatGPT memory layers explained: https://memx.app/glossary/chatgpt-memory/
- ChatGPT full history search with citations: https://www.techedt.com/chatgpt-gains-full-chat-history-search-for-plus-and-pro-users
- Memory compared across ChatGPT/Claude/Gemini (2026): https://www.memorylake.ai/en/blogs/ai-memory-compared-2026
- Claude Projects full-conversation access: https://contextrankings.com/comparisons/2026-08-07-claude-projects-vs-chatgpt-projects-for-long-running-work/
- Claude memory setup and 24h summary: https://godofprompt.ai/blog/why-claude-forgets-you/
- Gemini session limits (Google support, recommended answer): https://support.google.com/gemini/thread/467044555/gemini-dosent-remember-what-we-talked-aboit-on-previous-chats?hl=en
- Gemini deletion caveat (Google support): https://support.google.com/gemini/thread/458458219?hl=en&msgid=458469980
- Gemini Personal Intelligence: https://www.producthunt.com/products/gemini-personal-intelligence
