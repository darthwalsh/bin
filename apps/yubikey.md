[YubiKey - Wikipedia](https://en.wikipedia.org/wiki/YubiKey)

For SSO to Azure ActiveDirectory / Entra ID, you’re probably using **FIDO2/WebAuthn**. WebAuthn is **per operation** (each auth/sign request is a fresh ceremony), and the key’s **touch** is a **User Presence (UP)** check that prevents silent/background use. Prompts are driven by **policy + client UX**, and can still happen every time (especially for **PIN/biometric**, i.e. **User Verification (UV)**).

#ai-slop
## What Happens in a “YubiKey Session”?
There isn’t one universal “YubiKey session” across all YubiKey applications.

- **User Presence (UP)**: usually **touch** (proof you’re physically present)
- **User Verification (UV)**: **PIN or biometric** (proof it’s you
- “Session”-like behavior is usually **host/client caching** (OS, browser, middleware, or agents), not the YubiKey becoming “logged in”
## Common YubiKey Applications and Where “Sessions” Actually Live

| Application                | What’s actually happening                                             | What ends it (typical)                                   |
| -------------------------- | ---------------------------------------------------------------------- | --------------------------------------------------------- |
| **PIV (Smart Card / PKI)** | PIN is verified by the token, but “session” is mostly OS/middleware UX | Removal, lock/logout, timeout (varies by stack)           |
| **FIDO2/WebAuthn**         | Per-login ceremony; UP is commonly required per assertion              | No long-lived “session” on the key                        |
| **OATH (TOTP/HOTP)**       | App-level access while app is open / device present                    | App closes or key removed                                 |
| **OpenPGP**                | `gpg-agent` may cache PIN (host-side)                                  | Timeout, agent restart, reboot, or device removal         |

## FIDO2/WebAuthn: why does it ask for a PIN so often?
PIN/biometric prompting is primarily driven at **authentication time** by:
- **RP/IdP request** (the site/identity provider can request UV via WebAuthn’s `userVerification` preference)
- **Organization policy** (e.g., Entra ID / Conditional Access can require UV for security keys)
- **Client UX choices** (browser/OS decides how/when to re-prompt)

### 🧩 Workarounds or Simplifications?
You can’t skip the PIN entirely, but here are ways to make things smoother:

| Option                  | Description                                                                                  |
| ----------------------- | -------------------------------------------------------------------------------------------- |
| ✅ **Biometric YubiKey** | Some YubiKeys (like the YubiKey Bio) let you use a fingerprint instead of a PIN.             |
| ✅ **Windows Hello SSO** | If your org allows, using Windows Hello + a YubiKey might reduce how often you need the key. |
| ❌ **No PIN**            | Often not allowed when the IdP/org requires UV for security keys; you generally can’t override. |

## What are the security risks from not having UV/UP
Removing UP/UV usually **does not weaken the cryptography** (private key still doesn’t leave the device), but it *does* change the **authorization semantics**: the key becomes more of a **passive credential** that software (or a nearby person) can use with less friction.

### My threat model

- **Trusted host**: no malware; any process running as you is assumed benign/authorized.
- **Trusted UX**: you’re not defending against UI confusion / “you thought you clicked X but it was Y”.
- **Remote web compromise is “not my problem”**: if an RP/IdP/browser is buggy enough to allow weird background auth flows, you treat that as *their* bug.
- **Automation is allowed**: scripts using SSH/signing without manual prompts is acceptable.
- **Login-as-you is not inherently harmful**: being signed into your own account is not a security-relevant event by itself.

In [[ThreatModel]] terms: you primarily care about **non-extractability** and **anti-impersonation by remote attackers without the physical key**; you don’t require “proof of user intent” on each operation.

### WebAuthn
What you still get without UP/UV
- **Phishing resistance (origin binding)**
- **Remote attacker can’t authenticate without the key** still holds.

What you lose without UP/UV
- **No “I intended to authenticate right now” signal** (UP loss). A login ceremony could be triggered by software without requiring your physical participation.
- **Less resistance to opportunistic local/physical use** (UP/UV loss). If someone can use your *already-unlocked* browser session + the inserted key, there’s less friction.

Under “single RP + clean host + login itself not harmful” assumptions: the marginal risk reduction from UP/UV can be **near-zero**, because “silent login as you, into your own account” doesn’t grant the attacker a new capability I care about.

### OpenPGP
This is where UP/UV matter more often, because “sign/decrypt” operations can be meaningful even on a trusted machine.

What you still get without UP/UV
- **Remote attacker can’t use the key without access to your host/session + key** still holds.
- **UP and/or short PIN cache** (host-side): this lets you run many scripts without the UP/UV check, but it still keeps a deliberate *attention point* for the first sensitive operation.

What you lose without UP/UV
- **Ambient signing/decryption becomes possible**: any process that can reach your GPG stack can request operations without a “breakpoint” (touch/PIN prompt).
- **Reduced “human attention” feedback loop**: UP/UV prompts are often the only moment you notice “why am I signing right now?”
- **No UP/UV**: “Anything running as me can ask `gpg` to sign/decrypt with no extra speed bump.” This removes the last user-visible checkpoint between “process requested crypto” and “crypto happened”.

### SSH
What you still get without UP/UV
- **MITM / remote attacker still can’t authenticate without the key** still holds.

What you lose without UP/UV
- **No user-intent boundary for “start an SSH auth now”**: any process that can talk to the key (directly or via an agent) can authenticate whenever the key is present.
- **Higher risk from unattended-but-uncompromised scenarios**: e.g., you step away from an unlocked machine with the key inserted; an opportunistic person can initiate SSH from your session with less friction.

Under assumptions (“scripts should be allowed to SSH without prompts”, “no malware”, “I trust local processes”): turning off UP/UV is mostly a **convenience trade**, not a cryptographic downgrade.

## When do you need UP/UV?
- **You need UP** when you want “no silent use” as a security property:
    - shared/workplace environments, travel, demos, coffee shops
    - you want an attention checkpoint before auth/sign operations
    - **UP ≠ intent validation**: touch proves presence, not “you understood exactly what is being signed”. For true “intent”, you need a secure display/confirm-on-device workflow (rare outside hardware wallets).
- **You need UV** when you want “possession + knowledge/biometric”:
    - key theft / brief physical access matters
    - you don’t fully trust *all* local processes as “intentionally authorized”
