---
aliases:
  - vscode extensions
---

See [[PluginPhilosophy]] for evaluation criteria.

## ✅ Currently Using

- [ ] Explain why they are used
- [ ] Group which are disabled by default, and enabled per workspace
```
$ cursor --list-extensions
4ops.packer
adpyke.vscode-sql-formatter
anysphere.cpptools
anysphere.csharp
anysphere.cursorpyright
arthurwang.vsc-prolog
charliermarsh.ruff
chrmarti.network-proxy-test
cschlosser.doxdocgen
dart-code.dart-code
darthwalsh.vscode-bnf
denco.confluence-markup
dnicolson.binary-plist
dotjoshjohnson.xml
eamodio.gitlens
esbenp.prettier-vscode
fabianlauer.vs-code-xml-format
formulahendry.dotnet-test-explorer
github.copilot
github.copilot-chat
github.vscode-pull-request-github
golang.go
gruntfuggly.todo-tree
hashicorp.terraform
hbenl.vscode-test-explorer
humao.rest-client
idleberg.applescript
iliazeus.vscode-ansi
jebbs.markdown-extended
jebbs.plantuml
jeff-hykin.better-cpp-syntax
justusadam.language-haskell
littlefoxteam.vscode-python-test-adapter
llvm-vs-code-extensions.lldb-dap
llvm-vs-code-extensions.vscode-clangd
maarti.jenkins-doc
mermaidchart.vscode-mermaid-chart
mrmlnc.vscode-json5
ms-azuretools.vscode-azureresourcegroups
ms-dotnettools.vscode-dotnet-runtime
ms-mssql.data-workspace-vscode
ms-mssql.mssql
ms-mssql.sql-bindings-vscode
ms-mssql.sql-database-projects-vscode
ms-python.black-formatter
ms-python.debugpy
ms-python.flake8
ms-python.python
ms-toolsai.jupyter-keymap
ms-vscode-remote.remote-containers
ms-vscode-remote.remote-ssh
ms-vscode-remote.remote-ssh-edit
ms-vscode-remote.remote-wsl
ms-vscode.anycode-kotlin
ms-vscode.cmake-tools
ms-vscode.cpptools-extension-pack
ms-vscode.cpptools-themes
ms-vscode.hexeditor
ms-vscode.live-server
ms-vscode.powershell
ms-vscode.remote-explorer
ms-vscode.test-adapter-converter
ms-vsliveshare.vsliveshare
nemesv.copy-file-name
nicoespeon.abracadabra
nidu.copy-json-path
pkief.markdown-checkbox
pspester.pester-test
redhat.ansible
redhat.java
redhat.vscode-yaml
ritwickdey.liveserver
rust-lang.rust-analyzer
ryanluker.vscode-coverage-gutters
snyk-security.snyk-vulnerability-scanner
soltys.vscode-il
stkb.rewrap
streetsidesoftware.code-spell-checker
swiftlang.swift-vscode
tamasfe.even-better-toml
tintoy.msbuild-project-tools
usernamehw.autolink
vadimcn.vscode-lldb
visualstudioexptteam.vscodeintellicode
```

## 🔍 Considering / Someday-Maybe

- [curlconverter](https://marketplace.visualstudio.com/items?itemName=curlconverter.curlconverter)
- theme that makes comments extra bold and colorful: [Your syntax highlighter is wrong](https://jameshfisher.com/2014/05/11/your-syntax-highlighter-is-wrong/)
- [A VSCode Extension to Clarify Operator Precedence in JS](https://jordaneldredge.com/blog/a-vs-code-extension-to-combat-js-precedence-confusion/)
    - i.e. the code `a + b ?? c` would render with faint parens `(a + b) ?? c`
- [[vim]] mode

## ❌ Tried / Stopped Using

(none yet)

## Notes

### Sync disabled status to Cursor

This script syncs the disabled status of extensions from VS Code to Cursor.

Find global state path from:
- https://stackoverflow.com/a/67827303/771768

```bash
get-process cursor | stop-process -PassThru

# Export disabled extensions from VS Code
sqlite3 "$HOME/Library/Application Support/Code/User/globalStorage/state.vscdb" "SELECT value FROM ItemTable WHERE key = 'extensionsIdentifiers/disabled';" > disabled.json
# Don't use | jq -r '.[].id' 

# Backup any existing disabled extensions in Cursor
sqlite3 "$HOME/Library/Application Support/Cursor/User/globalStorage/state.vscdb" "SELECT value FROM ItemTable WHERE key = 'extensionsIdentifiers/disabled';"

# Import disabled extensions into Cursor
sqlite3 "$HOME/Library/Application Support/Cursor/User/globalStorage/state.vscdb" <<EOF
DELETE FROM ItemTable WHERE key = 'extensionsIdentifiers/disabled';
INSERT INTO ItemTable (key, value) VALUES ('extensionsIdentifiers/disabled', '$(cat disabled.json)');
EOF
```
Then you might need to close-open cursor a few times(?) to get this working.
