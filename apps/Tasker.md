#ai-slop

# Tasker on Modern Android (14-16)

Android increasingly restricts apps from toggling system settings (Wi-Fi, Bluetooth, etc.) since API 29. Tasker alone can't do it anymore — it need helpers.

## The Problem: Sticky Wi-Fi

When walking away from home, your phone clings to weak Wi-Fi instead of switching to mobile data. Result: 5-15 second hangs on calls and apps.

**Try built-in fixes first:**
1. **Settings → Network & internet → Internet → Network preferences → "Switch to mobile data automatically"**
2. If calls still hang: **Settings → Network & internet → SIMs → Wi-Fi calling → Calling preference** → set to cellular preferred

If those don't help, or your problem is about mobile data not phone call, automate with Tasker.

## Setup: Tasker + Shizuku

- **Legacy approach**: [Tasker Settings helper](https://github.com/joaomgcd/TaskerSettings) (targets old API) — blocked on Android 14+ Play Store, requires ADB bypass, doesn't work on Android 16.
- **Modern approach**: Install [[Shizuku]] — runs ADB-level service that approved apps can talk to via Binder.
  - **Tasker Beta Required**: Native Shizuku support currently requires **Tasker 6.3.1+** (check [Tasker Beta](https://tasker.joaoapps.com/beta.html) to join the Play Store Beta).
  - [ ] Once 6.3.1+ is stable in Play Store, drop out of beta. ⏳ 2026-07-30 

## Tasker Task: Wi-Fi Off for 5 Minutes

1. **Create Task**: Tasker → Tasks → + → name it `Wi-Fi Off 5min`
2. **Add actions**:
   - `+ → Net → Wi-Fi → Set` → Off
   - `+ → Task → Wait` → 5 minutes (300 seconds)
   - `+ → Net → Wi-Fi → Set` → On
3. **Test manually**: Tap Play button in Task screen

On Android 16, there's no "Use Shizuku" checkbox — [it's implicit](https://www.reddit.com/r/tasker/comments/1nkl9vo) when Shizuku is running and authorized.

---

## v2: NFC Trigger (TODO)

An NFC tag on the front porch is a **semantic signal** ("I'm leaving") that beats RSSI heuristics.

### Why NFC?
- 5cm range = intentional tap only
- No battery drain (passive tags)
- Works without network connectivity
- Can choose not to tap when returning

### Setup
1. **Profile**: Tasker → Profiles → + → Event → NFC → Tag
2. **Scan tag** to register it
3. **Link to Task**: `Wi-Fi Off 5min`

### Alternative: Bluetooth BLE Beacons
Two beacons with 5ft range at different yard positions → track direction of travel (stateful: beacon A → beacon B = leaving).

**Resources:**
- [Room detection with BLE beacons](https://www.reddit.com/r/tasker/comments/5psl3a/howto_detect_which_room_you_are_in_with_bluetooth/)
- [NFC automation video](https://youtube.com/watch?v=t3cbS3aez6M)
