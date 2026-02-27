#ai-slop
# Hands-Free Coding While Walking

How to write code while standing or walking outdoors, with a heads-up display and voice/minimal-hands input.

TODO: Add AI Coding Agent to this. i.e.
- [ ] [Claude Code On-the-Go (granda.org)](https://granda.org/en/2026/01/02/claude-code-on-the-go/) using Termius -> mosh -> Cloud VM -> Claude Code CLI

Another creator:
https://steve-yegge.medium.com/introducing-beads-a-coding-agent-memory-system-637d7d92514a
> I don’t go anywhere or do _anything_, not even sleep, without my laptop. Well, except for when I’m running, I haven’t quite cracked vibe coding there yet.
- [ ] After trying something, share with Steve?

## High-Level Requirements

### Display
- **80-column terminal minimum** (real Unix/Linux shell)
- **Heads-up / AR display** (phone stays in pocket/backpack)
- **Resolution:** 1080p or better per eye
- **Refresh:** 60 Hz+ (90–120 Hz typical for modern XR glasses)
- **Form factor:** XR/AR glasses preferred (instead of chest mount or smartwatch)

### Compute
- **Real Linux environment** with terminal, git, python, etc
- **Portable** (fits in backpack or pocket)
- **Battery:** 2+ hours for outdoor session
- helps to be **SSH capable** (local or remote development)

### Input
- **Voice-first** (dictation + command grammar for coding)
- **Minimal physical controls** (push-to-talk, escape, enter)
- **Fallback:** one-handed keyboard or pull phone out for precise edits

### Connectivity
- **Wi-Fi or cellular** for git, package install, remote SSH
- **Optional:** local-only mode for offline work

---

## Solution 1: Pixel 6a + Linux Terminal VM (Debian)

**Architecture:** Android phone with built-in Debian VM; use Android SSH client (Termux/ConnectBot) to connect; dictate in SSH app.

### Components
- **Display:** XR glasses need USB-C DisplayPort Alt Mode (Pixel 6a **doesn't support** wired DP)
    - Workaround: wireless bridge (XREAL Beam) or DisplayLink dock + adapter chain
- **Compute:** Pixel's Debian VM (experimental GUI/audio support as of Android 15)
    - *(Not "RealX" but leaving this breadcrumb here for me to grep this page later)*
- **Input:** 
    - Android SSH client (Termius, ConnectBot) for terminal with Gboard dictation
    - Android Voice Access for system-level voice control
- **Voice/AI:** VS Code Speech (if VM GUI works) or SSH + dictation in Android

### Top Risks
1. **Pixel 6a lacks USB-C DP Alt Mode** → glasses need wireless bridge or complex adapter chain (latency, flakiness, extra hardware to carry).
2. **Debian VM limited IME/audio** → Gboard dictation doesn't work in VM terminal UI; must SSH from Android instead (extra layer, can't use VM app directly).
3. **No Talon support** → Android VM isn't a desktop OS; Talon won't work. Stuck with basic dictation + Voice Access (no power-user coding grammars).

---

## Solution 2: Raspberry Pi 5 + XR Glasses

**Architecture:** Pi in backpack with battery pack; XR glasses as external monitor; Bluetooth keyboard or SSH from phone.

### Components
- **Display:** Pi 5 dual 4K@60 HDMI → active HDMI-to-USB-C (DP) adapter → XR glasses (wired)
- **Compute:** Raspberry Pi OS (Debian-based), switch to X11 session for Talon
- **Input:**
    - Talon Voice (X11 required) for terminal/editor voice control
    - Bluetooth foot pedal (PTT, Escape, Enter)
    - Fallback: Tap Strap 2 (one-handed wearable keyboard)
- **Voice/AI:** Talon + VS Code Speech + local or remote AI agent

### Top Risks
1. **Pi OS defaults to Wayland** → must manually switch to X11 for Talon; if stuck on Wayland, fall back to EasySpeak/OpenWayl (less mature than Talon).
2. **HDMI → USB-C adapter compatibility** → not guaranteed "just works" with every XR glasses model; some trial/error or specific adapter needed.
3. **Bulk and cables** → Pi + battery + adapter + cable to glasses = more gear to carry; cable management while walking can be awkward.

---

## Solution 3: Steam Deck + XR Glasses

**Architecture:** Steam Deck in sling/backpack; XR glasses via USB-C (native DP Alt Mode); Desktop Mode for Linux terminal.

### Components
- **Display:** Steam Deck USB-C (DP 1.4 Alt Mode) → XR glasses (wired, up to 1080p@120Hz)
- **Compute:** SteamOS (Arch-based); Desktop Mode runs KDE Plasma (X11 by default)
- **Input:**
    - Talon Voice (X11 in Desktop Mode)
    - Bluetooth foot pedal
    - Fallback: Tap Strap 2 or built-in Deck controls (not ideal while walking)
- **Voice/AI:** Talon + VS Code Speech + agent (local or remote)

### Top Risks
1. **Desktop Mode only (not Gaming Mode)** → Talon needs X11; Gaming Mode is Wayland (gamescope). Must stay in Desktop Mode, which is heavier on battery.
2. **Wayland transition risk** → if future SteamOS updates switch Desktop Mode to Wayland by default, Talon breaks; would need Wayland voice stack (EasySpeak/OpenWayl).
3. **Weight and battery** → Steam Deck is ~670g + glasses + pedal; battery in Desktop Mode doing terminal work may only last 2–3 hours (vs 6+ hours gaming). (But, mgith be possible to trim to 2/3 size with [Steam Brick Mod](https://crastinator-pro.github.io/steam-brick/))

---

## Solution 4: Wait for New Phone (USB-C DP Alt Mode) + XR Glasses

**Architecture:** Upgrade to Pixel 8+ or other phone with native USB-C DP Alt Mode; phone in pocket drives glasses directly.

### Components
- **Display:** Phone USB-C → XR glasses (wired, no adapter needed)
- **Compute:** Phone (Android) running Termux or Debian VM, or SSH to remote Linux
- **Input:**
    - Android Voice Access + Gboard dictation in SSH client
    - Bluetooth foot pedal
    - Fallback: Tap Strap 2 or pull phone out
- **Voice/AI:** VS Code Speech (if VM GUI works) or SSH + dictation

### Top Risks
1. **New phone cost** → Pixel 8 starts ~$700; need to verify DP Alt Mode actually works with chosen XR glasses (some report issues even on supported phones).
2. **Android limitations persist** → still no Talon (desktop OS only); still dependent on Debian VM GUI/audio improvements; may hit same IME issues as Pixel 6a.
3. **Battery drain** → phone driving glasses + compute + cellular/Wi-Fi may drain battery quickly (2–3 hours); need external battery or frequent charging.

---

## Solution Comparison Summary

| Solution           | Display setup                    | Talon?               | Bulk                          | Battery                        | Top blocker           |
| ------------------ | -------------------------------- | -------------------- | ----------------------------- | ------------------------------ | --------------------- |
| **Pixel 6a + VM**  | Wireless bridge or adapter chain | ❌ (Android)          | Low (phone + bridge)          | 2–3h (phone)                   | No DP Alt Mode        |
| **Raspberry Pi 5** | HDMI adapter → glasses           | ✅ (if X11)           | Medium (Pi + battery + cable) | 2–4h (depends on battery pack) | Wayland default       |
| **Steam Deck**     | USB-C direct → glasses           | ✅ (Desktop Mode X11) | High (~670g + glasses)        | 2–3h (Desktop Mode)            | Weight and battery    |
| **New Phone (DP)** | USB-C direct → glasses           | ❌ (Android)          | Low (phone only)              | 2–3h (phone)                   | Cost + Android limits |

---

## Input Stack Details

### Voice Control for Coding

**Talon Voice** (X11 Linux/macOS/Windows)
- Command grammar: "insert function", "wrap with try", "go line 120", "select word", "snake case"
- Requires X11 (Wayland not supported)
- Eye tracking + noise (pop/hiss) for hands-free mouse control (optional)

**VS Code Speech** (cross-platform)
- Dictation into editor + voice interaction with Copilot Chat
- Works on any platform running VS Code GUI

**Wayland alternatives** (if X11 not viable)
- **EasySpeak:** Wayland-native voice control (GNOME-focused)
- **OpenWayl:** dictation using `ydotool` for input injection

**Android**
- **Android Voice Access:** system-level voice navigation + text editing

### Physical Controls

**Foot pedal** (Bluetooth HID)
- Kinesis Savant Elite2 (~$198): programmable keyboard/mouse actions
- iKKEGOL Bluetooth HID (~$50–$100): Linux + Android support (config needs desktop first)
- Mappings: Pedal 1 = PTT, Pedal 2 = Escape, Pedal 3 = Enter

**One-handed wearable**
- **Tap Strap 2** (~$200): chorded keyboard/mouse, tap on leg/pocket, ~10h battery

---

## XR Glasses Reference

### Common Models
- **XREAL Air 2 Pro:** 1920×1080/eye, 120Hz, ~$399
- **Rokid Max:** 1080p, 120Hz, ~$399
- **VITURE Pro XR:** 1080p/eye, 120Hz, ~$549 (discounts ~$459)

### Connection Methods
- **Direct USB-C (DP Alt Mode):** cleanest; phone/Deck/Pi must support DP output
- **Wireless bridge:** XREAL Beam (~$199); phone casts to puck, puck drives glasses
- **Neckband/compute:** Rokid Station, XREAL Beam Pro (~$199), VITURE Pro Neckband (~$249–$328)

---

## Workflow: Voice → AI Agent → Test

1. **Speak intent** ("add retry logic to fetch_data", "refactor this function")
2. Agent generates patch/diff (runs on Pi/Deck/remote)
3. **Review via voice navigation** ("show diff", "open file", "search for retry")
4. Accept or iterate ("apply", "undo", "try again with...")
5. **Run tests** ("pytest -v", "ruff check")

Voice + AI minimizes exact character typing; foot pedal handles PTT/Escape/Enter; fallback keyboard for passwords/identifiers.

---

## T1 Action Items (Do First)

- [ ] **Confirm SSH + dictation works:** install Termius or ConnectBot on Pixel 6a; SSH to any host; verify Gboard dictation in SSH text field
- [ ] **Pick compute platform:** Pi vs Deck vs Pixel VM vs wait for new phone
- [ ] **If Pi or Deck:** boot into Desktop Mode and confirm X11 session (not Wayland)
- [ ] **Talon test:** on chosen Linux box, verify mic works, Talon can dictate + run simple commands ("press enter", "copy line")
- [ ] **10-minute walking test:** SSH from Android, dictate commands (`git status`, `pytest -q`), check 80-column terminal on target screen, note failure modes (network drops, latency, wind noise)
- [ ] **Choose fallback input:** one-handed wearable keyboard vs pull phone out for 30-second edits

## T2 Research Topics

- [ ] **X11 vs Wayland per platform:** Pi = can stay X11? Deck = will Desktop Mode stay X11 long-term?
- [ ] **Wayland voice stack:** if forced to Wayland, test EasySpeak + OpenWayl vs accept limited dictation
- [ ] **Agent workflow design:** where does agent run (local on Pi/Deck vs remote)? What's the speak → diff → review loop?
- [ ] **Pixel VM role:** just an SSH target, or try to use VM GUI directly (uncertain audio/IME)?
- [ ] **AR glasses + compute validation:** buy/borrow glasses, test cable/comfort while walking, confirm resolution/refresh meets needs

---

## Related

- [[SpeechRecognition]] — STT, Whisper, accents, ConversationStack app-idea
- [[RaspberryPi]] — Pi as media server, display projects
- [[cursor]] — VS Code Speech, model comparison, Agent/pwsh crash workaround
- [[ai.interface]] — voice as interface for AI agents
