#ai-slop

# Tasker: Alarm-Triggered Auto-Open

On Android, an alarm can trigger a [[Tasker]] task that reads a file and opens a URL or web search — no hardcoded destinations, no Obsidian URI required.

## Core Pattern: Read File, Open URL

Store the target URL (or just a search query) in a plain text file. Tasker reads it at alarm time:

1. **File → Read Line** → File: `Download/morning_target.txt`, Line: `1`, To Var: `%firstline`
2. **Net → Browse URL** → URL: `%firstline`

Storing the URL in a file means you can change tomorrow's destination without opening Tasker — just edit the file.

## Upgrade: Two-Choice Dialog (First Line + Random Line)

Show a dialog with two options — a "priority" item (manually placed at top) and a random pick — then open a web search for whichever is chosen.

Use a **JavaScriptlet** (Code → JavaScriptlet) instead of chaining 7 Tasker actions:

```javascript
var path = "Download/topics.txt";
var data = readFile(path);
var lines = data.split("\n").filter(line => line.trim() !== "");

if (lines.length > 0) {
    var first = lines[0];
    var randIdx = Math.floor(Math.random() * (lines.length - 1)) + 1;
    var random = lines[randIdx] || first; // fallback if only 1 line

    setLocal("%option_first", first);
    setLocal("%option_random", random);
    setLocal("%random_index", randIdx + 1); // Tasker arrays are 1-indexed
}
```

Then use **Alert → Text Dialog** with two buttons ("First" / "Random"), and **Net → Search** with the chosen variable.

### Deleting the chosen line after use

Removes the item so the queue stays fresh (zero repeats):

```javascript
// Run after user picks; `choice` is "first" or "random", `random_index` from above
var index = (choice === "first") ? 0 : (random_index - 1);
lines.splice(index, 1);
writeFile(path, lines.join("\n"), false);
```

The `topics.txt` file is just one topic per line — no URL encoding needed since Tasker's **Net → Search** handles it.

## Focus Mode on Alarm

Tasker can't toggle Android's native Focus Mode (Digital Wellbeing) directly — it's a protected system setting. Options:

| Method | Works on Android 14+? | Notes |
|---|---|---|
| ADB WiFi (Tasker action) | Yes | Must re-enable ADB WiFi after each reboot |
| Samsung Routines bridge | Samsung only | Tasker sends a notification; Routine detects it and toggles Focus Mode |
| Tasker-native "focus" | Yes | DND + app-blocking via "App Changed" event; no system Focus Mode |

**ADB command** for the ADB WiFi method:
```
cmd statusbar click-tile com.google.android.apps.wellbeing/.focusmode.quicksettings.FocusModeTileService
```

See [[Tasker]] for Shizuku setup (needed for Wi-Fi/system toggles on Android 14+).

## Gotchas

- **URL encoding**: If note names have spaces, add a Variable Search Replace before Browse URL: space → `%20`.
- **JavaScriptlet vs Python**: Tasker supports JS natively (no Termux needed). Python requires SL4A or Pytasker — more trouble than it's worth.
- **Empty queue**: Add an `If %all_notes(#) < 1` guard to notify when `topics.txt` runs out.
