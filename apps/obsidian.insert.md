#ai-slop

# Moving selected text to a target file at a marker

Obsidian has no native "insert at marker" system, but two plugins get close, and QuickAdd with a JS script is the most flexible.

## Native options (limited)

**[Note Composer](https://help.obsidian.md/Plugins/Note+composer)** (core plugin, Settings > Core plugins):
- Extract/merge content into another file
- Positioning: Enter = append to bottom, Shift+Enter = prepend to top
- No arbitrary marker support

**[Text Transporter](https://github.com/TfTHacker/obsidian42-text-transporter)** (community):
- "Push selection to another file" via Command Palette
- Can target a specific **heading** or **block** within the destination file
- Block IDs (`^target-here`) act as stable markers

## QuickAdd script: move selection to marker

Save as `_scripts/MoveToTarget.js` in your vault (Git-tracked):

```js
module.exports = async (params) => {
    const {quickAddApi, app} = params;

    const TARGET_FILE_NAME = "My Inbox"; // Change to your file name
    const MARKER = "%% INSERT HERE %%";  // Marker line in that file

    const activeView = app.workspace.getActiveViewOfType(quickAddApi.obsidian.MarkdownView);
    if (!activeView) return;

    const selection = activeView.editor.getSelection();
    if (!selection) { new Notice("No text selected!"); return; }

    const targetFile = app.metadataCache.getFirstLinkpathDest(TARGET_FILE_NAME, "");
    if (!targetFile) { new Notice(`Target file "${TARGET_FILE_NAME}" not found!`); return; }

    await app.vault.process(targetFile, (data) => {
        if (!data.includes(MARKER)) {
            new Notice("Marker not found — appending to end instead.");
            return data + "\n" + selection;
        }
        return data.replace(MARKER, `${MARKER}\n${selection}`);
    });

    activeView.editor.replaceSelection(""); // delete from source = "move"
    new Notice("Content moved to target!");
};
```

Setup in QuickAdd: Settings > Manage Macros > Add Macro > Configure > User Scripts > select file > Add. Then add a Choice of type Macro and link it. Bind via Settings > Hotkeys.

### Multi-target variant with fuzzy picker

Presents a `suggester` dropdown — type `q`, `r`, etc. to filter:

```js
module.exports = async (params) => {
    const {quickAddApi, app} = params;

    const targets = [
        { name: "(q) Quotations", path: "Quotations.md" },
        { name: "(r) Research",   path: "Research.md" },
        { name: "(i) Inbox",      path: "Inbox.md" },
        { name: "(p) Projects",   path: "Projects.md" },
        { name: "(t) Tasks",      path: "Tasks.md" },
    ];
    const MARKER = "%% INSERT HERE %%";

    const activeView = app.workspace.getActiveViewOfType(quickAddApi.obsidian.MarkdownView);
    if (!activeView) return;
    const selection = activeView.editor.getSelection();
    if (!selection) { new Notice("No text selected!"); return; }

    const choice = await quickAddApi.suggester(targets.map(t => t.name), targets);
    if (!choice) return;

    const targetFile = app.metadataCache.getFirstLinkpathDest(choice.path, "");
    if (!targetFile) { new Notice("File not found!"); return; }

    await app.vault.process(targetFile, (data) => {
        return data.includes(MARKER)
            ? data.replace(MARKER, `${MARKER}\n${selection}`)
            : data + "\n" + selection;
    });

    activeView.editor.replaceSelection("");
    new Notice(`Moved to ${choice.name}`);
};
```

`vault.process()` is the safest write API — reads and writes atomically, preventing data loss from concurrent edits.

## JS Engine version

[JS Engine](https://www.moritzjung.dev/obsidian-js-engine-plugin-docs/) uses `engine.app` instead of the QuickAdd `params` object. The logic is identical; the API surface differs slightly:

```js
const obsidian = engine.getObsidianModule(); // needed to access MarkdownView
const TARGET_FILE_NAME = "My Inbox.md";
const MARKER = "%% INSERT HERE %%";

const activeView = engine.app.workspace.getActiveViewOfType(obsidian.MarkdownView);
if (!activeView) return "Error: No active Markdown editor.";

const selection = activeView.editor.getSelection();
if (!selection?.trim()) return "Error: Please select some text first.";

const targetFile = engine.app.metadataCache.getFirstLinkpathDest(TARGET_FILE_NAME, "");
if (!targetFile) return `Error: Target file "${TARGET_FILE_NAME}" not found.`;

try {
    await engine.app.vault.process(targetFile, (data) => {
        return data.includes(MARKER)
            ? data.replace(MARKER, `${MARKER}\n${selection}`)
            : data + "\n\n" + selection;
    });
    activeView.editor.replaceSelection("");
    return `Successfully moved content to ${TARGET_FILE_NAME}`;
} catch (e) {
    return `Error: ${e.message}`;
}
```

JS Engine doesn't have a built-in `suggester` — you'd need to build a `SuggestModal` subclass or borrow QuickAdd's API (`engine.app.plugins.plugins.quickadd.api`). For the multi-target picker, QuickAdd is simpler.

See [[obsidian.scripting]] for plugin setup and hotkey binding patterns.
