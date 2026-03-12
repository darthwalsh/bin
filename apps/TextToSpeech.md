#ai-slop
---
aliases:
  - TTS
  - text-to-speech
---
See also: [[SpeechRecognition]] for STT (input).

## The Gap: LLM Intelligence vs. Audio Scrub UI

Current LLM tools (ChatGPT, Claude, Gemini voice modes) can *speak* their responses, but they're conversational agents — you can't load arbitrary text and get a scrub-seek-highlight playback UI. That feature lives in dedicated TTS readers, not AI assistants.

The two capabilities sit in different product categories today:

| Capability | Where it lives |
|---|---|
| Synchronized text highlighting + pause/rewind/scrub | TTS readers (Speechify, Voice Dream) |
| LLM-quality content generation | ChatGPT, Claude, Gemini |
| Both in one product | Not yet |

**Practical hybrid workflow:** Generate or summarize text with an LLM → paste into a TTS reader for highlighted playback.

---

## Dedicated TTS Readers (Desktop / Mobile)

### Speechify
Best-in-class for the highlight+scrub experience. Reads web pages, PDFs, and docs with word-level sync highlighting and full playback controls. Human-like voices. Freemium.
- [App Store](https://apps.apple.com/us/app/speechify-text-to-speech/id1209815023)

### Voice Dream Reader
Preferred on iOS/macOS for studying. Reads almost anything, robust playback controls, highly customizable. No LLM features but excellent audio quality and controls.

### Readwise Reader (Docs TTS)
Document-first. Lets you play, jump, and highlight while listening. Better for long-form articles and saved content than for interactive LLM output.
- [Readwise Docs](https://docs.readwise.io/reader/docs/faqs/text-to-speech)

### NaturalReader / TTSReader
Simpler, paste-and-play TTS engines. Less polished UI, but free and direct. Good enough for quick reads.

---

## Browser Extensions for TTS

Useful for reading web articles and technical pages without leaving the browser.

### ReadX Text to Speech
Most configurable for technical use. Has an **element filtering system** (can exclude specific DOM elements like `<pre>` or `<code>` blocks) and **custom pronunciation rules** for abbreviations/technical terms. Not automatic — requires manual configuration of which elements to skip.
- [Chrome Web Store](https://chromewebstore.google.com/detail/readx-text-to-speech/nnpkmeadcahjgbmiemkbdlbnkhkoinff)

### Read Aloud: A Text to Speech Voice Reader
Most popular browser TTS extension. Highlights text while reading. Supports 40+ languages. Can use cloud voices (Google WaveNet, Azure, Amazon Polly, OpenAI) with a BYOK API key. No automatic code-block skipping, but lets you read only selected text.
- [Chrome Web Store](https://chromewebstore.google.com/detail/read-aloud-a-text-to-spee/hdhinadidafjejphmfkjgnolgimiaplp)

### Voice Out
Natural voices, PDF/Doc/webpage support, playback controls (pause, skip, pitch/speed). Interactive but no semantic code-block awareness.
- [voiceout.app](https://voiceout.app)

### Talkie
Minimal, quick TTS for selected text. Free tier is usable. No customization, but zero friction for "just read this paragraph."
- [GitHub](https://github.com/joelpurra/talkie)

### FreeVoiceReader (local, WebGPU)
Runs entirely in-browser via WebGPU using the Kokoro model. No data leaves your machine. Less polished than mainstream options, but interesting if you want local/private TTS.
- [Reddit thread](https://www.reddit.com/r/TextToSpeech/comments/1pca463)

---

## Handling Technical Content (Code Blocks)

**The core problem:** Browsers expose code blocks as plain text — extensions have no semantic awareness of `<code>` vs `<p>`. None skip code blocks automatically.

**Workarounds, roughly in order of friction:**

1. **Select only prose** before invoking TTS — most extensions read only the highlighted selection.
2. **Reader Mode first** — Firefox/Edge reader view or similar strips page chrome and often removes inline code, then run TTS on the cleaned view.
3. **ReadX element filtering** — manually configure which CSS selectors to exclude (e.g., `pre`, `.highlight`). One-time setup per site.
4. **Custom pronunciations** (ReadX or similar) — add rules like `API` → "A P I", `fn` → "function", `err` → "error" to make code-adjacent text less jarring when it does get read.
5. **LLM pre-processing** — paste technical content into ChatGPT/Claude, ask it to produce a prose summary omitting code details, then feed to TTS.

---

## Related
- [[SpeechRecognition]] — STT, Whisper, local transcription, ConversationStack app-idea
- [[browser.plugins]] — Chrome extension list, Tampermonkey for custom scripts
- [[HandsFreeCoding]] — voice input for coding sessions, Talon Voice
