Maybe don't need to [[obsidian.plugin.dev|develop a full plugin]] to automate small things — custom hotkey runs a JS script.

Not possible without a plugin! (can open in [[vscode]] or use CLI scripts to edit a markdown file, but that's missing the Obsidian API context)
- [ ] Consider if `obsidian` CLI lets you `eval()` JS snippets

## Git-tracked scripts
Both QuickAdd and [JS Engine](https://www.moritzjung.dev/obsidian-js-engine-plugin-docs/) store a **file path reference** to `.js` files in your vault — not the code itself inside `.obsidian/`. Keep scripts in a `_scripts/` folder tracked by Git and hot-reloaded on save.

Only the macro name and path live in `.obsidian/plugins/quickadd/data.json`. 

## Fuzzy Search dropdown
**QuickAdd wins for hotkey + UI workflows**: its built-in `quickAddApi.suggester` handles fuzzy-search dropdowns natively. JS Engine requires building a `SuggestModal` subclass or borrowing QuickAdd's API. Every QuickAdd macro is automatically exposed as an Obsidian command, so hotkey binding is just Settings > Hotkeys.

See [[obsidian.insert]] for a worked example (move selection to a target file at a marker).

## Tasks
- [ ] Automate Canceling a Task ⏫ 
	- [ ] ELSE use https://github.com/thingnotok/obsidian-toggle-list
- [ ] Automate dataviewjs dashboard of [[INBOX zero notes#Automation]]
## Repo stats 2025-04-01

For querying Obsidian Tasks from a CLI script (without reimplementing the parsing), see [[mcp#Obsidian Tasks MCP]].
```pwsh
$ rg '\[github\]\((.+)\)' obsidian.scripting.md -or '$1' | % { repo-stats $_ }
🌟1709 🍴148 🔓327 👀1709 🔖master 📦false 👥32 📌699 chhoumann/quickadd
🌟343 🍴22 🔓1 👀343 🔖master 📦false 👥10 📌60 samlewis0602/obsidian-custom-js
🌟3696 🍴220 🔓189 👀3696 🔖master 📦false 👥55 📌681 SilentVoid13/Templater
🌟7621 🍴447 🔓600 👀7621 🔖master 📦false 👥112 📌802 blacksmithgu/obsidian-dataview
```
## Generated Code Samples
#ai-slop https://chatgpt.com/share/67ecbb35-e65c-8011-9def-c30b499da586
>In Obsidian desktop markdown notes app, I want to press a custom hotkey and invoke some JS script. The script might open a file, or edit the current file. I'm imagining if the JS can register a obsidian command, then I can set up a hotkey for that command.
>What is the best-supported, most-popular, simplest plugin that supports this? Or, is it possible without a plugin?
## QuickAdd
[github](https://github.com/chhoumann/quickadd)
```js
module.exports = async (params) => {
  const { app } = params;
  const activeLeaf = app.workspace.activeLeaf;
  if (!activeLeaf || !activeLeaf.view || !activeLeaf.view.editor) {
    new Notice("No active editor.");
    return;
  }

  const editor = activeLeaf.view.editor;
  const cursor = editor.getCursor();
  const line = cursor.line;
  const lineContents = editor.getLine(line);
  const taskDescription = lineContents.trim();

  // Format the current date as YYYY-MM-DD
  const currentDate = new Date();
  const formattedDate = currentDate.toISOString().split('T')[0];

  // Replace line with scheduled task
  editor.replaceRange(
    `- [ ] ${taskDescription} 📅 ${formattedDate}`,
    { line: line, ch: 0 },
    { line: line, ch: lineContents.length }
  );

  new Notice("Line converted to to-do with due date.");
};
```
1. Configure the Macro in the QuickAdd settings > Macros:​
    - Click on the newly created macro ("Convert Line to Todo").​
    - Select **Add Choice** and choose **Capture**.​
    - Configure the capture to **Run a JavaScript function**.​
    - Specify the path to your script (e.g., `scripts/convertLineToTodo.js`).​
2. Settings > Hotkeys > add `QuickAdd: ...`

### Moving files
Also, see https://quickadd.obsidian.guide/docs/Examples/Macro_MoveNotesWithATagToAFolder which lets you loop over `app.metadataCache.getCachedFiles()` and invoke `await app.fileManager.renameFile()`
## CustomJS
[github](https://github.com/samlewis0602/obsidian-custom-js)

```js
class ConvertLineToTodo {
  async invoke() {
    const activeLeaf = app.workspace.activeLeaf;
    if (!activeLeaf || !activeLeaf.view || !activeLeaf.view.editor) {
      new Notice("No active editor.");
      return;
    }

    const editor = activeLeaf.view.editor;
    const cursor = editor.getCursor();
    const line = cursor.line;
    const lineContents = editor.getLine(line);
    const taskDescription = lineContents.trim();

    // Format the current date as YYYY-MM-DD
    const currentDate = new Date();
    const formattedDate = currentDate.toISOString().split('T')[0];

    // Replace line with scheduled task
    editor.replaceRange(
      `- [ ] ${taskDescription} 📅 ${formattedDate}`,
      { line: line, ch: 0 },
      { line: line, ch: lineContents.length }
    );

    new Notice("Line converted to to-do with due date.");
  }
}

```
1. In the **CustomJS** settings under **Registered invocable scripts**, add the class name (`ConvertLineToTodo`).​
2. Settings > Hotkeys > add for `CustomJS: ...
## Templater
[github](https://github.com/SilentVoid13/Templater)

Solution described [here](https://www.reddit.com/r/ObsidianMD/comments/uf4t82/templater_script_to_convert_current_line_to_a/?utm_source=chatgpt.com)
```js
let cmEditorAct = this.app.workspace.activeLeaf.view.editor;

// line under cursor
let currentCursor = cmEditorAct.getCursor();
let currentLine = currentCursor.line;
let lineContents = cmEditorAct.getLine(currentLine);
let taskDescription = lineContents;

// Replace line with scheduled task
cmEditorAct.replaceRange(
  "- [ ] " + taskDescription + " 📅 " + tp.date.now(),
  { line: currentLine, ch: 0 },
  { line: currentLine, ch: lineContents.length }
);
```
Then create hotkey: https://www.thoughtasylum.com/2021/07/24/the-basics-of-templater-for-obsidian/?utm_source=chatgpt.com#:~:text=use%20a%20keyboard%20shortcut
## Commands not supported: Dataview
[github](https://github.com/blacksmithgu/obsidian-dataview)

https://blacksmithgu.github.io/obsidian-dataview/queries/dql-js-inline/#inline-dataview-js
- Doesn't support custom commands?
- Could integrate with Templater or QuickAdd

