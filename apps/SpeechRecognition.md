---
aliases:
  - SpeechToText
  - Speach
---
- [ ] Import from OneNote "Podcasting Captions"
- [ ] https://github.com/ccoreilly/vosk-browser browser lib speech to text
- [ ] https://github.com/ggerganov/whisper.cpp - https://youtu.be/nE5iVtwKerA 
	- [ ] whisper.cpp ran the best  https://blog.lopp.net/open-source-transcription-software-comparisons/#textgrade20CPU2C20is-whispercpp-with20the20small
## Accents
- [ ] [LENGTH and LINKING in British, American and Australian accents!](https://youtu.be/tPi2jtU7Tl4?si=XSEteiC74Dsg8cpK): Accents vowels have different lengths faaather

>Use pitch manipulation for accents! First get a lot of voice samples of different accents then find some algorithm to shift the pitch on specific vowels in specific words-- that would make for a pretty neat Instagram "filter" if you could give yourself an Irish or Scottish accent?

- The way to learn about transcription is to create a narration API that the first thing to do is to look at vowels doing a Fourier transform over 0.1 second intervals and looking for the in the frequency domain how diphthongs look
- An interesting test would be to try to speech recognition of songs, and see how closely you can match the official lyrics #app-idea created: 2018-02-18
- Could you separate out the singing and different instruments into different tracks? 
## ConversationStack
#app-idea 
Always listening, would let you "ok Google pop the conversation Stack" maybe has heuristics like how excited you are, can go back and forward excited peaks, has haptic feedback to tell you when you are talking over people measured by 1/N time or by listening. Instead of repeating an idea, you could tell it to remember your last idea. Has "Shut up Carl" mode to auto-push every conversation and interrupt with "shut up carl"
- [ ] if it hears conversation, auto pause Netflix, and rewind 5 seconds so it's ready to resume `created: 2017-12-07`
	- [ ] If using [Eno Real-Time Brain Activity Monitoring Headphones](https://getenophone.com/) it also pause when you're not being Mindful
- [ ] When it hears "let's put a pin in that" do the same as slack UI `created: 2017-12-24`
## gubbgoogla
#app-idea 
As an app in the [[#ConversationStack]] ecosystem, would help you find answers to questions that you spoke earlier.

>The Swedish slang **“gubbgoogla”** roughly means _“to guesstimate in a group instead of actually checking the facts”_.
>- It comes from **“gubbe”** (old man / man) + **“googla”** (to Google / look something up).
>- It describes a situation where people (often men, hence “gubbe”) sit around speculating, reasoning, and guessing together about a fact or answer, rather than just grabbing their phone or computer and _googling_ it.

1. App always records current conversation
2. On "wake word" (or manual interaction) activates
3. Finds which part of transcript likely have the question
4. *If I find that on-device STT is too low quality,* prompt the user before sending audio to cloud STT
5. Asks LLM for the answer to the main question, with references
### Cloud
Definitely most feasible to make a Discord voice bot. 
For Teams / Zoom / Meet: none of the other video calling apps seem to have non-enterprise real-time streaming APIs
- [ ] PoC Discord STT bot
### OnDevice
Very infeasible to just run SpeechToText (STT) running 24/7
- If running on phone CPU 100%, would struggle to just keep up with real-time
- Only one app can listen at once, so not possible to assist in a phone call.
Looked into companion device that can record audio to ring buffer in RAM, and transfer on request.
- `SpeechRecognizer` can to live STT using NPU, but cannot take audio file as input.
 #ai-slop generated PoCs:
- Android app using `SpeechRecognizer` https://chatgpt.com/share/68c649e8-3698-8011-ba93-1cdb7fde330d
- Python script showing how to use TFLITE, but missing token->text decoder at end https://g.co/gemini/share/565fd2847734
## Consumer Hardware
Wearable/handheld "AI devices" that promise always-on transcription. Key question: where does STT happen?

| Device                | Form          | STT Location |
| --------------------- | ------------- | ------------ |
| **Limitless Pendant** | Clip/necklace | ☁️ Cloud     |
| **Humane AI Pin**     | Chest clip    | ☁️ Cloud     |
| **Rabbit R1**         | Handheld      | ☁️ Cloud     |
| **Plaud NotePin**     | Clip          | ☁️ Cloud     |

## Local Transcription Tools (Apple Silicon)
On Macbook Pro, see [[transcribe_stereo.py]]. Transcribes left/right channels separately, about 10-20x real realtime.

| Tool | Install | Notes |
|------|---------|-------|
| **mlx-whisper** | `uvx --from mlx-whisper mlx_whisper` | Fastest on M-series, Python API |
| **whisper.cpp** | `brew install whisper-cpp` | Simple CLI, no Python |
| **WhisperKit** | Swift package | Apple-native, more setup |

Best model for accuracy: `mlx-community/whisper-large-v3-mlx`
## Diarization (Speaker Labels) Is Surprisingly Hard
I expected a simple `--diarize` flag. It doesn't exist. The Whisper ecosystem treats transcription and diarization as completely separate problems, requiring a two-pass pipeline (transcribe → diarize → align). For a quick phone call transcript, splitting stereo channels is dramatically simpler than setting up pyannote.

**The easy case:** Stereo recording where left=person A, right=person B. Just split channels with `ffmpeg`, transcribe separately, merge by timestamp. This is deterministic and works perfectly. (`transcribe_stereo.py` does this.)

**The hard case:** Mono recording with multiple speakers. Now you need actual diarization:

| Approach | Quality | Setup |
|----------|---------|-------|
| **pyannote.audio** | Best | Heavy (PyTorch, HuggingFace auth, model downloads) |
| **Cloud APIs** (AWS/Google/Azure) | Good | Easy but costs $, data leaves machine |
| **Heuristic clustering** | Meh | Fast but unreliable with similar voices or overlap |

## Polished text
https://wisprflow.ai/features
> "Let’s meet at 2… actually 3,”

-> `Let's meet at 3`
- [ ] Check https://wisprflow.ai/android ⏳ 2026-10-20 

