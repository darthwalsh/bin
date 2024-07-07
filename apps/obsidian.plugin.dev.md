https://docs.obsidian.md/Plugins/Getting+started/Build+a+plugin
https://docs.obsidian.md/Plugins/Getting+started/Anatomy+of+a+plugin

Don't try to make an [editor extension](https://docs.obsidian.md/Plugins/Editor/Editor+extensions).

## Dev workflow
1. Create a dummy vault
2. Set up `.obsidian/plugins/your-plugin-dir`
    1. Either `git clone` into `plugins/`
    2. OR, make a symlink / junction:  `new-item -itemtype symboliclink -path ~/code/vault-obsidian-importer/.obsidian/plugins/your-plugin-dir -Target ~/code/your-plugin-dir`/`
3. `npm run dev`
4. After compilation, need to reload plugin:
    1. Either manually unload/load
    2. OR, Hot Reload by [cloning this](https://github.com/pjeby/hot-reload) then Community plugins > enable
5. Obsidian: Toggle Developer Tools
6. Chromium DevTools > Sources > Add folder to workspace
	1. Now saving a .TS file in DevTools
	2. ...so DevTools changes filesystem file
	3. ...so npm recompiles plugin
	4. ...so Hot Reload plugin
