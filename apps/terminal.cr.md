# Line Wrapping CR
`\r` (CR `0x0D`) moves the cursor to **column 0** of the current **physical row**: not the start of the visual output.

When a string wraps across two rows:

```
Row 1: Loading... step 4 of 10: doing the th
Row 2: ing                                   ← cursor here
```

The next `\r` resets to col 0 of row 2 only. Row 1 is left as garbage.

Workaround: truncate to terminal width `tput cols` before printing? But truncated text is annoying if you expand the width later! Not sure if there's any good compromise, where a TUI app output looks good when resized after app exits.
