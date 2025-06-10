---
aliases:
  - vscode extensions
---
## Current plugins
- [ ] import current list from vscode

## Sync disabled status to Cursor
Find global state path from
- https://stackoverflow.com/a/67827303/771768
- https://stackoverflow.com/a/69707546/771768
```bash
get-process cursor | stop-process -PassThru

sqlite3 "$HOME/Library/Application Support/Code/User/globalStorage/state.vscdb" "SELECT value FROM ItemTable WHERE key = 'extensionsIdentifiers/disabled';" > disabled.json
# Don't use | jq -r '.[].id' 

# Backup any existing
sqlite3 "$HOME/Library/Application Support/Cursor/User/globalStorage/state.vscdb" "SELECT value FROM ItemTable WHERE key = 'extensionsIdentifiers/disabled';"

sqlite3 "$HOME/Library/Application Support/Cursor/User/globalStorage/state.vscdb" <<EOF
DELETE FROM ItemTable WHERE key = 'extensionsIdentifiers/disabled';
INSERT INTO ItemTable (key, value) VALUES ('extensionsIdentifiers/disabled', '$(cat disabled.json)');
EOF
```
Then you might need to close-open cursor a few times(?) to get this working

## Interested in Extensions
https://marketplace.visualstudio.com/items?itemName=curlconverter.curlconverter

Try a VS code theme that makes comments extra bold and colorful: [Your syntax highlighter is wrong](https://jameshfisher.com/2014/05/11/your-syntax-highlighter-is-wrong/)

[A VSCode Extension to Clarify Operator Precedence in JS / Jordan Eldredge](https://jordaneldredge.com/blog/a-vs-code-extension-to-combat-js-precedence-confusion/)
i.e. the code `a + b ?? c` would render with faint parens `(a + b) ?? c`

Try vim mode?