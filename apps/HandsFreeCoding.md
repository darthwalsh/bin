---
aliases:
  - MobileDev
---
#ai-slop
# Hands-Free Coding While Walking

How to write code while standing or walking outdoors, with a heads-up display and voice/minimal-hands input.

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

## Solution 5: Phone + Cloud VM (No Local Compute)

**Architecture:** Phone runs only a terminal client; all compute lives on a pay-per-use cloud VM accessed via Mosh + Tailscale. Described in detail by [granda.org](https://granda.org/en/2026/01/02/claude-code-on-the-go/).

```
Phone (Termius + mosh) → Tailscale VPN → Cloud VM → Claude Code / agent CLI
```

### Components
- **Display:** Phone screen only (no XR glasses required); or pair with any of the display solutions above
- **Compute:** Cloud VM (e.g. Vultr `vhf-8c-32gb` at ~$0.29/hr); pay only when working
- **Access:** Tailscale-only — no public SSH port exposed; VM's public IP has no SSH listener
- **Input:** Termius on iOS/Android; Mosh survives WiFi↔cellular transitions and sleep
- **Session persistence:** tmux auto-attach on login; agents keep running when phone is pocketed
- **Push notifications:** Claude Code `PreToolUse` hook POSTs to a webhook (e.g. [Poke](https://poke.lol)) when agent needs input → phone buzzes with the question
- **Parallel agents:** git worktrees + multiple tmux windows; deterministic port allocation per branch

### Top Risks
1. **Cost if left running** → VM costs accumulate; use start/stop scripts or an iOS Shortcut calling the cloud API to halt when done.
2. **Latency for interactive typing** → Mosh local echo mitigates this, but high-latency connections still feel sluggish for non-agent work.
3. **No display for XR glasses** → phone is just a terminal; to use glasses you'd still need a local compute device driving them.

---

## Solution Comparison Summary

| Solution              | Display setup                    | Talon?               | Bulk                          | Battery                        | Top blocker              |
| --------------------- | -------------------------------- | -------------------- | ----------------------------- | ------------------------------ | ------------------------ |
| **Pixel 6a + VM**     | Wireless bridge or adapter chain | ❌ (Android)          | Low (phone + bridge)          | 2–3h (phone)                   | No DP Alt Mode           |
| **Raspberry Pi 5**    | HDMI adapter → glasses           | ✅ (if X11)           | Medium (Pi + battery + cable) | 2–4h (depends on battery pack) | Wayland default          |
| **Steam Deck**        | USB-C direct → glasses           | ✅ (Desktop Mode X11) | High (~670g + glasses)        | 2–3h (Desktop Mode)            | Weight and battery       |
| **New Phone (DP)**    | USB-C direct → glasses           | ❌ (Android)          | Low (phone only)              | 2–3h (phone)                   | Cost + Android limits    |
| **Phone + Cloud VM**  | Phone screen (no glasses)        | ❌ (Android client)   | Minimal (phone only)          | Phone battery only             | No local display for XR  |

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

## Mobile Terminal & Remote Access Tools

### Terminal Clients (iOS/Android)

| Tool | Platform | Mosh? | Notes |
| ---- | -------- | ----- | ----- |
| **Termius** | iOS + Android | ✅ | Most polished; built-in SFTP, snippet one-tap buttons for saved commands |
| **Blink Shell** | iOS only | ✅ | Best Mosh implementation; highly customizable for power users |
| **Termux** | Android only | ✅ (via `pkg install mosh`) | Full Linux environment on-device; install CLIs locally or SSH out |
| **JuiceSSH** | Android | ✅ (plugin) | Classic Android client |
| **ConnectBot** | Android | ❌ | Open-source, simple; standard SSH only |

### Mobile Shell Protocols

| Protocol | Transport | Roaming | Local echo | Scrollback | Notes |
| -------- | --------- | ------- | ---------- | ---------- | ----- |
| **SSH** | TCP | ❌ | ❌ | ✅ | Drops on network switch; baseline |
| **Mosh** | UDP | ✅ | ✅ | ❌ | Use tmux for scrollback; doesn't forward SSH agent |
| **Eternal Terminal (ET)** | TCP | ✅ | ❌ | ✅ | Middle ground; needs server-side binary |

Mosh is the standard choice for mobile. Pair with tmux for scrollback and session persistence.

### Agent CLI Mobile UIs

**Happy Coder** — touch-optimized UI for agentic CLIs (Claude Code, etc.)
- Run relay on server: `npm install -g happy-coder`
- Android app from Play Store
- Features: Approve/Deny touch buttons, push notifications when agent needs permission, voice dictation
- Best for: delegating tasks on the move, not interactive coding

**AirCodum** — VS Code extension + native mobile app remote control
- Install extension in VS Code/Cursor; run "AirCodum: Start Server" from command palette
- Mobile app connects to the printed IP:port
- Shows a VNC-style mirror of VS Code UI; also supports file transfer, AI chat panels
- No built-in auth — network reachability is the only gate (see tunnel section below)
- Works in VSCodium; Cursor support unconfirmed (uses VS Code extension API)

### Remote Access: Getting Through NAT Without Port Forwarding

The core problem: your dev machine is behind a home router or corp VPN; your phone can't reach it directly.

**Mental model:** keep inner tools dumb (AirCodum, SSH), put auth at the edge.

```
Phone → [edge auth + TLS] → tunnel → dev machine (local port)
```

| Tool | Auth | Notes |
| ---- | ---- | ----- |
| **ngrok** | OAuth/basic auth on free/paid plans | Ephemeral URL; rotate token to revoke; HTTPS only; good for personal use |
| **Cloudflare Tunnel** | Cloudflare Access (SSO) | More robust for persistent setups; same outbound-only pattern |
| **Tailscale** | Device identity via SSO | Private overlay network; no public URL; best for trusted personal devices |
| **Tailscale Funnel** | Tailscale account | Exposes a Tailscale node to the public internet; sometimes blocked by corp VPN |

For **personal home use** (no port forwarding, no corp VPN): ngrok or Tailscale are both correct choices — not hacks. The VM is the outbound initiator; no inbound router rules needed.

For **corp VPN**: none of these work cleanly — the VPN likely blocks outbound tunnels or prevents personal devices from reaching the machine. Move compute to a cloud VM instead (Solution 5).

---

## Pixel Debian VM: Mic Test Results

The Android "Linux Terminal" app (Android 15+) runs a Debian VM via Android Virtualization Framework. Audio is exposed to the guest as a single `virtio-snd` virtual device.

**Finding:** Bluetooth headset mic paired to Android host is routed into the VM's `virtio-snd` device. After granting mic permission to the Terminal app, `arecord` captured voice and played it back correctly.

```bash
# Verify audio devices in Debian VM
arecord -l   # should show: card 0: VirtIO SoundCard
aplay -l

# Record 5s from mic and play back
arecord -D hw:0,0 -f S16_LE -r 48000 -c 1 -d 5 /tmp/mic.wav
aplay /tmp/mic.wav
```

**Key gotchas:**
- Android mic permission must be granted to the Terminal app (Settings → Apps → Linux Terminal → Permissions)
- Mic source selection (built-in vs Bluetooth) is controlled on the Android side — Debian only sees one virtual device
- Bluetooth audio quality may drop while mic is active (HFP/HSP profile limitation)
- The VM uses `weston` (Wayland compositor) running inside an X11 window as its display backend; software rendering via Mesa/llvmpipe (zink/Vulkan path)

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

- [ ] **Confirm SSH + dictation works:** install Termius on Pixel 6a; SSH to any host; verify Gboard dictation in SSH text field
- [ ] **Try Solution 5 first (lowest friction):** spin up a cloud VM, set up Tailscale + Mosh + tmux, run Claude Code CLI — no hardware purchase needed; see [granda.org pattern](https://granda.org/en/2026/01/02/claude-code-on-the-go/)
- [ ] **Pick local compute platform (if XR glasses needed):** Pi vs Deck vs Pixel VM vs wait for new phone
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
