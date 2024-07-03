https://docs.obsidian.md/Plugins/Getting+started/Build+a+plugin
https://docs.obsidian.md/Plugins/Getting+started/Anatomy+of+a+plugin

Don't try to make an [editor extension](https://docs.obsidian.md/Plugins/Editor/Editor+extensions).

## Dev workflow
1. Create a dummy vault
2. Set up `.obsidian/plugins/your-plugin-dir`
    1. Either `git clone` into `plugins/`
    2. OR, make a symlink / junction to an existing project
3. `npm run dev`
4. Reload plugin:
    1. Either manually unload/load
    2. OR, Hot Reload by [cloning this](https://github.com/pjeby/hot-reload) then Community plugins > enable
    