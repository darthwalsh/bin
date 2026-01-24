#ai-slop 
Using AI assistants during video calls (Teams, Zoom) for note-taking, summarization, and live Q&A.

## Sync or Async

**Post-processing** — Record meeting, transcribe, then summarize with AI afterward.
- Unobtrusive, no workflow change
- Uses Teams Recap / Copilot notes (endorsed at my work)

**Real-time** — AI listens live, can answer questions or draft notes during the call.
- More interactive, can nudge/clarify in the moment
- Requires audio routing setup

## Async: Sprint Planning → JIRA Updates
The goal is basically to 
1. **Live preview surface** — Teams/Loop page shows AI notes during meeting
2. **Per-ticket drafts** — AI generates proposed description/comment using custom Prompt
	- If using audio transcript, see [[SpeechRecognition]] — local transcription with Whisper/mlx-whisper
	- [ ] Try adding cont
	1. [ ] Improve our [[Teams meeting AI Summary prompt|internal prompt]] to get good results 
3. **Review** — human checks content
4. Maybe: script can loop over notes and append comments to all jira issues

Options for the shared artifact:
- **Teams + Loop** — Facilitator/Copilot notes, everyone can edit live
- **Jira issue panel** — draft appears in Jira, "Apply" button to commit

At my work: Zoom AI Companion disabled globally. Use Teams Copilot instead.

## Sync: ChatGPT Voice Mode as Meeting Copilot
- [ ] Try this!
```
Teams audio
   ├──→ Your headphones (you hear)
   └──→ BlackHole (ChatGPT hears)
```
### Requirements (macOS)
1. **BlackHole 2ch** — virtual audio cable (`brew install blackhole-2ch`)
2. **Multi-Output Device** — routes audio to both headphones and BlackHole
3. **ChatGPT Live Voice** — listens via BlackHole input
4. Wear headphones
### Setup
1. Open **Audio MIDI Setup** → Create Multi-Output Device
2. Check: ✅ BlackHole 2ch, ✅ Your headphones
3. Enable **Drift Correction** on BlackHole
4. Rename to `Teams → Headphones + ChatGPT`

**Teams settings:**
- Speaker: `Teams → Headphones + ChatGPT`
- Microphone: your normal mic

**ChatGPT settings:**
- Microphone input: `BlackHole 2ch`
- Speaker output: headphones (NOT BlackHole)
### Usage Modes

**Silent Listener (recommended):**
- ChatGPT stays muted to the meeting
- You ask it questions verbally or via text
- It answers only to you
- Can show during screen share

**Controlled interjection:**
- Temporarily switch Teams mic to ChatGPT output
- Let it speak, then switch back
- Don't leave this on
## Multi-User Shared Chat
Real-time collaborative ChatGPT sessions (Google-Docs-style) **not supported** in our enterprise deployment.

**What works:**
- Share links (read-only, forks on interact)
- Custom GPTs (shared config, separate chat histories)

**Workarounds:**
- Screen share + driver model
- Slack thread + ChatGPT app
- Shared prompt doc + everyone runs independently
