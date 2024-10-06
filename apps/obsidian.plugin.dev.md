https://docs.obsidian.md/Plugins/Getting+started/Build+a+plugin
https://docs.obsidian.md/Plugins/Getting+started/Anatomy+of+a+plugin

Don't try to make an [editor extension](https://docs.obsidian.md/Plugins/Editor/Editor+extensions).

## Dev Workflow
### Installation
1. Ensure you have `git` and `nodejs` installed
2. Create a dummy vault
3. Set up `.obsidian/plugins/your-plugin-dir`
    1. Either `git clone` into `plugins/`
    2. OR, make a symlink / junction:  `new-item -itemtype symboliclink -path ~/code/vault-obsidian-importer/.obsidian/plugins/your-plugin-dir -Target ~/code/your-plugin-dir/`
4. cd `your-plugin-dir`
5. `npm install`
6. `npm build`
7. Reload Obsidian. Settings > Community Plugins > Scroll down > click button to Enable
8. Should work to use your plugin
### Next Compile
1. `npm run dev` will run the compiler whenever files change
2. After compilation, need to reload plugin:
    1. Either manually disable/enable
    2. OR, Hot Reload by [cloning this](https://github.com/pjeby/hot-reload) then Community plugins > enable
3. To see console log or errors, open Obsidian: Toggle Developer Tools
4. Fix changing file in dev tools not copying back to the git repo: Chromium DevTools > Sources > Add folder to workspace
	1. Now saving a .TS file in DevTools 
	2. ...causes DevTools to change filesystem file
	3. ...so `npm` recompiles plugin
	4. ...so Hot Reload will reload plugin

## Light scripting
Maybe we don't need to develop a full plugin to automate small things...
See https://quickadd.obsidian.guide/docs/Examples/Macro_MoveNotesWithATagToAFolder which lets you loop over `app.metadataCache.getCachedFiles()` and invoke `await app.fileManager.renameFile()`