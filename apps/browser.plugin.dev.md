#ai-slop

# Chrome Extension Dev Loop

## Minimal dev loop

1. Load extension unpacked from disk via `chrome://extensions` > Developer mode > Load unpacked
2. Edit source files in Cursor
3. Trigger the right reload (see table below)
4. Verify in the target tab

## What needs reloading after each change

| Changed | Reload needed |
|---|---|
| Content script JS/CSS | Reload the **page** (re-injects from disk) |
| Popup HTML/JS/CSS | Close and **reopen the popup** |
| Service worker / background (MV3) | **Reload extension** (`chrome://extensions` or `chrome.runtime.reload()`) |
| `manifest.json` | **Reload extension** |

Gotcha: content scripts with `run_at: document_start` may need a hard reload (`Cmd+Shift+R`) to preserve injection timing.

DevTools Workspaces ("green dot" file sync) is not required — it's for editing in DevTools and syncing back to disk, not for normal Cursor-based development.

## Automating extension reload (skip the `chrome://extensions` click)

Add a dev-only watcher to the service worker that calls [`chrome.runtime.reload()`](https://developer.chrome.com/docs/extensions/reference/api/runtime#method-reload) when a watched file changes:

```js
// service_worker.js — dev only, strip before shipping
if (DEV_HOT_RELOAD) {
  let last = "";

  async function readFile(path) {
    return new Promise((resolve) => {
      chrome.runtime.getPackageDirectoryEntry((root) => {
        root.getFile(path, {}, (fileEntry) => {
          fileEntry.file((file) => {
            const reader = new FileReader();
            reader.onloadend = () => resolve(String(reader.result || ""));
            reader.readAsText(file);
          });
        });
      });
    });
  }

  async function tick() {
    try {
      const content = await readFile("manifest.json");
      if (last && content !== last) chrome.runtime.reload();
      last = content;
    } catch { /* ignore */ }
  }

  setInterval(tick, 750);
}
```

Watch `manifest.json` as a cheap proxy — touch it on save to trigger reload. Add your SW bundle filename to the watch list for more precise triggering.

## `dist/` vs loading `src/` directly

Load `src/` directly if: plain JS/HTML/CSS, no bundler, `manifest.json` points at real source files.

`dist/` becomes necessary once you add TypeScript, module bundling, JSX, or environment flags. It also keeps generated artifacts out of source control and gives Chrome a single predictable folder to read.

Gotcha: [`--load-extension` is being removed from Chrome branded builds](https://groups.google.com/a/chromium.org/g/chromium-extensions/c/1-g8EFx2BBY) (Chrome 137+). Automation that passes this flag will break on standard Chrome; use Chromium or Chrome for Testing instead.

## Letting Cursor automate the dev cycle

Cursor's [Browser Agent](https://cursor.com/docs/agent/browser) can read console logs and network traffic directly, enabling a no-human loop: edit → reload → agent reads errors → patch → repeat.

### Setup

1. Run a local dev server (e.g. `npm run dev` with Vite, or `python3 -m http.server`)
2. In Cursor Agent: "Open `http://127.0.0.1:PORT/`, watch console + network for errors, apply minimal fixes, hard reload, confirm console is clean. Repeat until no errors."

### Validation tests (run once to confirm your environment)

**A — Console/network access**
- [ ] Create a page with `console.log("hello")` and a deliberate JS error. Ask agent to report console logs and errors. Pass = agent returns the log and stack trace.
- [ ] Add a fetch to a bad URL. Ask agent to report XHR failures. Pass = agent reports the failing request + status.

**B — Session persistence** (the open question — [community reports](https://forum.cursor.com/t/add-persistent-browser-state-cookie-configuration-to-built-in-playwright-mcp-server/136489) suggest Cursor's built-in browser launches fresh sessions)
- [ ] Log into a site in the Browser tool, close the session, reopen it. Pass = still logged in.

**C — Extension loading**
- [ ] Navigate to `chrome://extensions` in the Cursor browser. Pass = page loads and Developer Mode is toggleable.
- [ ] Load unpacked, close session, reopen. Pass = extension still installed.

If B or C fail, use [BrowserToolsMCP](https://github.com/AgentDeskAI/browser-tools-mcp) or [Chrome DevTools MCP](https://github.com/ChromeDevTools/chrome-devtools-mcp) instead: both drive a real persistent Chrome profile (signed in once, extension loaded once) and expose console/network to the agent.

### Safety

Keep action approvals on by default. Cursor's [security model](https://cursor.com/docs/agent/security) treats terminal commands and browser actions as sensitive — don't enable auto-approve on untrusted origins.
