https://docs.obsidian.md/Plugins/Getting+started/Build+a+plugin
https://docs.obsidian.md/Plugins/Getting+started/Anatomy+of+a+plugin

Don't try to make an [editor extension](https://docs.obsidian.md/Plugins/Editor/Editor+extensions).

- [ ] copy relevant details from [Contributing / Development](https://sytone.dev/obsidian-queryallthethings/contributing/development)

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
## Testing
- [ ] summarize this
i.e. https://github.com/search?q=repo%3Asytone%2Fobsidian-queryallthethings%20path%3Atest&type=code has tests
Some [code](https://github.com/sytone/obsidian-queryallthethings/blob/d780219798f7687441f4568298aa2a07803419d1/tests/ParseTask.test.ts) imports `Note` which imports a lot from `'obsidian'`
[Here](https://github.com/sytone/obsidian-queryallthethings/commit/7c21ecc9aa49b6143953467bf5ff55477caccd12) switched from `jest` to node test runner
- [ ] Does that mean node testing can import `obsidian` packages?

- [ ] read from https://github.com/platers/obsidian-linter/blob/master/__tests__/examples.test.ts
- [ ] integration tests too: https://github.com/platers/obsidian-linter/blob/master/__integration__/yaml-rule.test.ts
## Logging
- [ ] summarize https://github.com/search?q=repo%3Asytone%2Fobsidian-queryallthethings%20logging&type=code
## Ophidian: Build & Publish System for plugins
https://github.com/ophidian-lib/build has a build script example:
```js
new Builder("src/pane-relief.ts") // <-- the path of your main module
.withSass()      // Could be omitted
.withInstall()   // Optional: publish to OBSIDIAN_TEST_VAULT on build
.build();
```

https://github.com/ophidian-lib/core is a framework for loading your services

## Light scripting
See [[obsidian.scripting]].
