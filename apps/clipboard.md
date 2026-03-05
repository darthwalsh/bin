Most modern OS support **multiple MIME types per clipboard entry** (e.g., `text/plain`, `text/html`, images), but interoperability depends on:
- Source app: populates richer formats?
- Dest app: requests/accepts richer formats?

Some OS also support Share/intents, which solve a similar problem.

## xplat
Powershell commands: `Get-Clipboard` and `Set-Clipboard`

Viewer: Browser might lose some formats, but it's a lowest-common-denominator: [Clipboard Inspector](https://evercoder.github.io/clipboard-inspector/)
## macOS
OS commands: `pbpaste` and `pbcopy`

View clipboard with [ClipboardViewer.app](https://superuser.com/questions/541335/clipboard-viewer-for-os-x-that-allows-extracting-the-data-in-any-available-forma/1591637#comment2362993_1104703)

## Windows
OS command: `clip > pasted.txt` and `< copy.txt clip`
- [ ] Viewer: not sure

- [ ] test if this works to paste HTML format?
```powershell
Add-Type -AssemblyName System.Windows.Forms
$d = [System.Windows.Forms.Clipboard]::GetDataObject()

if ($d.GetDataPresent("HTML Format")) {
  $d.GetData("HTML Format")   # CF_HTML wrapper string$htmlCf
} else {
  throw "No HTML on clipboard"
}
```

## Linux
OS command: `xclip -o > pasted.txt` and `< copy.txt xclip -i`
- [ ] Viewer: not sure

## Android
Viewer:
- Recommended to go through browser: [Clipboard Inspector](https://evercoder.github.io/clipboard-inspector/)
- [SimpleClipboardEditor](https://github.com/TrianguloY/SimpleClipboardEditor) lists MIME types, but only displays plaintext 
- [ ] Try https://github.com/KaustubhPatange/XClipper (but it's focused more on Windows, as a clipboard history sync took!)
- Gboard Clipboard UI: Built into Pixel, but doesn't help view clipboard formats

### Share Sheet
**Share sheet** (`ACTION_SEND` intents) is a **different pipeline** than clipboard:
- Can include `ClipData` objects, but interoperability varies
- For rich content transfer, **Share as file** is more reliable than clipboard.

### GPT Canvas Workaround
When viewing a chat on Android, tapping Copy on the canvas yields plain text with no markup. (The web version gets Markdown in `text/plain` and also has HTML).

**Workaround**: **Open the canvas view** then copy: clipboard will contain:
- `text/plain` with Markdown syntax
- `text/html` flavor

### Converting clipboard HTML to Markdown
- [ ] Haven't tested mobile Obisidian
