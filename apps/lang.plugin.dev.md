#ai-slop

# Plugin Dev: New Environment Checklist

Practical steps for getting productive fast in a constrained scripting/plugin host (Obsidian QuickAdd, Tasker, Google Apps Script, Excel VBA, game engine scripting, etc.). For plugin *architecture*, see [[lang.plugin]]. For browser extensions specifically, see [[browser.plugin.dev]].

This is a checklist you can hand to an AI agent or work through yourself. Many steps produce a one-line answer — collect them into a cheatsheet for the specific platform.

## 1. Identify the runtime

The runtime determines which APIs exist, which language features work, and what debugging looks like.

| Probe | What it tells you |
|---|---|
| `typeof window !== 'undefined'` | Browser/WebView context |
| `typeof process !== 'undefined'` | Node.js context |
| `typeof globalThis` | ES2020+ engine |
| `navigator.userAgent` | Engine version (V8, JSC, SpiderMonkey) |
| `import sys; sys.version` | Python version + build |
| `import sys; sys.executable` | Which Python binary is running |

For hosts that don't document their engine, run these probes as throwaway scripts.

Gotcha: some hosts (Tasker, Shortcuts) run a stripped engine where standard globals exist but are no-ops or throw at runtime.

## 2. Find the output stream

Before you can debug anything, you need to know where `print` goes.

| Try | Common in |
|---|---|
| `console.log()` then open DevTools | Electron-based apps (Obsidian, VS Code) |
| Host-specific toast/notice API | Obsidian `new Notice()`, Tasker `flash()` |
| `alert()` | WebView-based hosts |
| `console.log()` to a log file | Apps Script (Stackdriver), Shortcuts |
| Write to a temp file | When all else fails |

Gotcha: some hosts swallow `stderr` silently. Always test error output separately from normal output (throw an intentional error to see where the stacktrace lands).

## 3. Map the edit-run cycle

The speed of this loop dominates your productivity. Classify where your host falls:

| Model | Iteration speed | Examples |
|---|---|---|
| File-watched hot reload | Seconds | Obsidian + hot-reload plugin, VS Code extensions |
| Manual reload/re-enable | ~10s | Browser extensions, some game engines |
| Paste-and-run | ~15s | Tasker, Shortcuts, QuickAdd macros |
| Build + deploy | Minutes | Apps Script `clasp push`, compiled plugins |

For paste-and-run hosts: keep your code in a real editor and copy-paste. A file watcher that copies to clipboard on save (`fswatch` + `pbcopy`) saves friction.

For file-based hosts: symlink your dev directory into the plugin folder so edits are live without copying. See [[obsidian.plugin.dev]] for an example.

## 4. Get IntelliSense working

Type hints prevent the most common time sink: guessing API shapes.

**Search order:**
1. Official `@types/` package on npm (e.g. `@types/obsidian`, `@anthropic-ai/sdk`)
2. Community type stubs (search GitHub for `<app-name> .d.ts`)
3. The host's own source/SDK if open-source
4. Ask an AI to generate a `global.d.ts` with stubs for the 5-10 objects you'll actually use

For Python hosts: look for a `.pyi` stub file or a `py.typed` marker in the SDK package.

Even a 20-line `.d.ts` with the main entry points eliminates most "Cannot find name" noise and gives you autocomplete on the critical APIs.

## 5. Understand the sandbox

Before building anything complex, probe what the host blocks. These are the common walls:

| Capability           | Probe                                                 |
| -------------------- | ----------------------------------------------------- |
| File system read     | Try reading a known file path                         |
| File system write    | Try writing to a temp directory                       |
| Network (fetch/HTTP) | `fetch('https://httpbin.org/get')` / `XMLHttpRequest` |
| Timers               | `setTimeout`, `setInterval`                           |
| Spawning processes   | `child_process.exec` / `subprocess.run`               |
| DOM access           | `document.createElement('div')`                       |
| Clipboard            | `navigator.clipboard.writeText('test')`               |
| Persistent storage   | `localStorage`, host-specific settings API            |

Gotcha: some hosts allow network but only to allowlisted domains.

## 6. Identify state and lifecycle

| Question | Why it matters |
|---|---|
| Does your script run once per invocation, or persist? | Determines if you can cache, use module-level state |
| Is there an `onLoad` / `onUnload` lifecycle? | Needed for cleanup (event listeners, intervals) |
| Are multiple instances possible? | Race conditions, duplicate listeners |
| What triggers execution? | User action, schedule, event, app startup |

Run a counter probe: set a module-level variable, increment it each run, print the value. If it always prints `1`, your state is ephemeral.

## 7. Dependencies and imports

| Host type                               | How to add deps                                                |
| --------------------------------------- | -------------------------------------------------------------- |
| Node-based (Obsidian, VS Code)          | `npm install` + bundler (esbuild, rollup)                      |
| Browser-based (extensions)              | Bundle into a single file, or use `importScripts`              |
| Paste-and-run (Tasker, QuickAdd macros) | Inline everything — no module system                           |
| Apps Script                             | Built-in libraries only, or copy-paste modules                 |
| Python-embedded                         | `pip install` if the host uses system Python; otherwise inline |

For paste-and-run hosts without imports: vendor the specific functions you need by copying them into your script. An AI agent can extract and inline a single function from a library.

## 8. Error handling and debugging

| Technique | When to use |
|---|---|
| `try/catch` wrapping `main()` | Always — ensures you see errors instead of silent failure |
| Structured error logging with context | `catch (e) { log({ fn: 'main', error: e.message, stack: e.stack })` |
| Breakpoint debugging (DevTools) | Electron-based hosts; set `debugger;` statement in code |
| Step-through not available | Fall back to binary-search commenting: comment out half the code, narrow to the failing half |

Gotcha: many plugin hosts catch and swallow errors from plugin code. Wrap your entry point in `try/catch` and route errors to the output stream you found in step 2.

## 9. Testing without the host

The fastest feedback loop runs outside the host entirely.

**Mock-and-run pattern:**
1. Create a `mock.js` (or `mock.py`) that stubs the host's global objects with no-ops or simple returns
2. `require('./mock')` then `require('./your-script')` in Node/Python
3. Add a few inline assertions at the bottom gated by `if (typeof process !== 'undefined')` (or equivalent check that you're in dev)

This lets you iterate on logic in a real debugger with real stacktraces, reserving the host for final integration testing.

For complex APIs: record real responses from the host (`JSON.stringify` objects during a real run), then replay them in your mock.

To mitigate more risk, having a full E2E test would be helpful, but might need specialized support from the host.

## 10. Deployment and distribution

| Model                   | Steps                                                                              |
| ----------------------- | ---------------------------------------------------------------------------------- |
| Symlink into plugin dir | One-time setup, edits are live. Best DX.                                           |
| CLI push tool           | Apps Script `clasp push`, Obsidian `obsidian plugin:reload`                        |
| Manual paste            | Copy from editor, paste into host UI. Automate with clipboard watcher if frequent. |
| Package + publish       | `npm publish`, submit to marketplace/registry. Only for distribution, not dev.     |

Gotcha: some hosts cache aggressively. If changes aren't appearing: force-quit the host app, clear its cache directory, or look for a "reload plugins" command.

## Platform-specific cheatsheets

Once you've worked through this checklist for a specific host, capture the answers in a dedicated file (e.g. `obsidian.plugin.dev.md`). The checklist above produces the raw material; the cheatsheet is the finished reference.
