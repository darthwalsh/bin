https://forum.cursor.com/t/bug-cursor-cli-script-fails-to-handle-arguments-with-spaces-and-special-characters-correctly-due-to-unsafe-eval-usage/146263

Fix: in `/opt/homebrew/bin/cursor`
>Replace `eval "$CURSOR_CLI" "$@"` with direct command execution:
`ELECTRON_RUN_AS_NODE=1 "$ELECTRON" "$CLI" "$@"`

And, you'll need to re-apply this fix each time you update cursor