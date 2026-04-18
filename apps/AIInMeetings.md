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

## Async: Structuring a Transcript

After transcribing (see [[SpeechRecognition]]), two useful post-processing steps:

**1. Polish the raw transcript** — clean up whisper hallucinations, filler words, merge short segments:

---

You are given a transcript file split for a phone call with Me and You speakers. Produce a **polished transcript** (no preamble/commentary).

**Requirements:**
* If the same phrase is repeated 5+ times (whisper model hallucination), replace with `[Transcription Failure]`
	* If you see `You know, You know, You know, You know, You know, You know, You know,` → `You know... [Transcription Failure]`
	* Detect transcription failures **before** normal repetition condensing. 
* Keep the general text formatting like `[00:12] Me: I said something.`
* Merge short speech sections into natural sentence boundaries (speaker change, long pause, or output line getting long)
* Infer misheard words **only when there is a clear, unambiguous technical term implied by immediate context**
	* "cash server" → "cache server"


Polished written prose:
- **Remove filler words**, false starts, and verbal tics unless they materially affect meaning.
- **Resolve self-corrections** into the final intended phrasing.
- **Lightly normalize grammar and sentence structure** (spoken fragments → complete sentences where appropriate), inferring commas but avoiding em-dashes.
- **Condense repetitions** that do not add new information.
- Preserve **speaker turns and timestamps**, but allow timestamps to represent logical breaks rather than exact utterance timing.
- Retain **interruptions or overlaps only when they affect meaning**, marking them concisely (e.g., `[interrupting]`).

Do **not** introduce new information, interpretations, or summaries.
Only include a postscript if there was `[Transcription Failure]`, with the timestamps.

---

**2. Diagram the conversation** — after polishing, extract structure (chapters + outline + decisions):
- [ ] Try this
Paste the polished transcript into an AI with this prompt:

```text
You are given a many-minute conversation transcript. The transcript includes:
- speaker labels (e.g., "Carl:", "Alex:")
- timestamps (e.g., "[07:32]" or "07:32")

Your job: produce a structured "conversation diagram" that starts with CHAPTERS (time-ranged segments), then for EACH chapter outputs:
1) Outline (hierarchical bullets)
2) Open Questions
3) Tasks / Action Items

Hard requirements:
- Start with a short "Chapter List" that has 4–8 chapters max for a 20-minute transcript.
- Every chapter MUST include an explicit time range like "07:10–10:45".
- Prefer concrete paraphrases over long quotes. Only quote short phrases when necessary.
- Tie claims to evidence by including timestamps (and speaker names when relevant).
- Be conservative: if something is implied but not stated, mark it as "inferred" and include the evidence timestamp.

Output format (follow exactly):

# Chapter List
1. <Chapter title> (<start–end>)
2. ...

# Chapter 1: <Title> (<start–end>)
## Outline
- <Top-level point> [timestamp]
  - <Subpoint> (Speaker) [timestamp]
  - <Subpoint> (Speaker) [timestamp]
- <Top-level point> [timestamp]

## Open Questions
- Q: <question text> [timestamp where it came up]
  - Context: <why it's open / what was said> (Speaker) [timestamp]
  - Owner (if stated): <name or "unspecified">
  - Needed to answer: <what info/decision is missing>

## Tasks / Action Items
- [ ] <task verb + object> — Owner: <name or "unspecified"> — Due: <date or "unspecified"> [timestamp]
  - Acceptance criteria: <what "done" looks like, if stated or inferred>
  - Dependencies/Risks: <if mentioned>

After all chapters, add:
# Cross-Chapter Summary
## Decisions Made
- <decision> [timestamp]
## Key Themes
- <theme> [chapter refs]
## Parking Lot (Deferred)
- <deferred topic/question> [timestamp]
## Task Rollup
- <task> — Owner — Due [timestamp]

Now do the work on the transcript below.

----------------------------------------------------------------
EXAMPLES (these are examples of the desired style; do NOT treat them as facts)

Example Chapter List:
1. Framing the problem (00:00–03:20)
2. Constraints and requirements (03:20–07:05)
3. Options discussed (07:05–12:40)
4. Converging on a plan (12:40–17:30)
5. Next steps and owners (17:30–20:00)

Example Chapter (style example):
# Chapter 2: Constraints and requirements (03:20–07:05)
## Outline
- Define non-negotiables for the solution [03:25]
  - "Must work offline for installers" (Alex) [03:40]
  - "Avoid new auth prompts during silent install" (Carl) [04:05]
- Identify integration constraints [05:10]
  - Existing dependency on <System X> (Alex) [05:22]
  - Concern about rate limits (Carl) [06:10]

## Open Questions
- Q: What's the acceptable timeout threshold during install? [06:35]
  - Context: Carl raised concern about retries; no threshold agreed. (Carl) [06:35]
  - Owner (if stated): unspecified
  - Needed to answer: installer performance budget; historical telemetry

## Tasks / Action Items
- [ ] Pull installer telemetry for average install duration — Owner: Alex — Due: unspecified [06:50]
  - Acceptance criteria: report with p50/p90/p99 and notes about slow-path causes
  - Dependencies/Risks: access to telemetry dashboard
```

- Good for: decision meetings, troubleshooting calls, negotiation

### Topic timeline ("chapters")

Shows when topics start/stop, pacing, and digressions — already captured by the chapter list above. Can also be rendered visually:

- Mermaid timeline (Markdown) in Obsidian/GitHub
- Miro / FigJam (drag blocks along a horizontal line)

Example:
```
00:00–03:20: Problem framing
03:20–09:10: Constraints + requirements
09:10–14:30: Options
14:30–18:40: Decision
18:40–20:00: Next steps
```

### Entity/Concept map (future research)

Shows the mental model that emerged from the conversation. Nodes = concepts/products/teams/risks; edges = "relates to / blocks / depends on". Edges can be annotated with timestamps of where they came up.

Tools: Obsidian Canvas, Excalidraw, yEd, draw.io, Miro mind map
