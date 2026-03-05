Shizuku is a service that allows apps to use system APIs directly with ADB-level privileges. It is the modern standard for "power user" features on non-rooted Android devices.

## Threat Model

| Concern | Answer |
|---------|--------|
| Network exposure? | None — no TCP/UDP listeners, local Binder only |
| Battery impact? | Negligible — idle service, no polling |
| Banking apps / Play Integrity? | Unaffected — no root, no bootloader unlock |
| Persistence? | Session-based — stops on reboot unless re-started |

Shizuku is closer to "USB debugging temporarily enabled" than rooting. It sits orthogonal to Google's long-term "apps should not touch sharp objects" philosophy by moving power into explicit, user-mediated intent.

## Install (Android 16)

The Play Store doesn't allow listing it ("made for older Android").

1. Download the APK from [Shizuku GitHub releases](https://github.com/RikkaApps/Shizuku/releases)
2. Grant the Files app (or your browser) the "Install unknown apps" permission.

Note: I didn't need it, but you can install via ADB if manual install is blocked: `adb install --bypass-low-target-sdk-block Shizuku-vX.X.X.apk`

## Configuration

1. **Enable Wireless Debugging**: Settings → System → Developer options → Wireless debugging → ON
2. **Start Shizuku**: Open app, start service (one-time pairing via QR or code)
3. **Auto-start**: Enable in Shizuku settings (works most boots, occasional tap required)
4. **Accept persistent notification** — this is unavoidable on stock Android 16. It exists to prevent silent privilege escalation.

## Usage with Tasker

Once Shizuku is running, you must grant permission to Tasker:
- In Shizuku app → Authorized applications → grant Tasker.

See [[Tasker]] for specific automation recipes.

## Shizuku Shouldn't break in the future

Why it survives:
- Uses official ADB mechanism (Google can't remove it without breaking dev tooling).
- User-initiated, session-based, reversible.
- Aligns with Android's direction: dangerous actions should be *conscious*.

What can change:
- Specific system APIs becoming no-ops or read-only (already happening with Wi-Fi toggles).
- The *channel* (Binder IPC to ADB) is stable; the *capabilities* behind it can shrink.
