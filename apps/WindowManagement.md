## Workspace MultiWindow Management

Currently using hotkeys to move windows around, but would like to try a tool to move known windows to known locations.
### Display Maid
>https://funk-isoft.com/display-maid.html allows you to save and restore window locations based on your display configuration or user created profiles.
- [ ] Try it 🔼 
#### Rectangle
*Currently using this on macOS*
https://rectanglepro.app/ has feature:
>Arrange an entire workspace of apps with just one shortcut.
Activate when displays are connected or disconnected.
- [ ] Try it RectanglePro trial 🔽 
#### [[PowerToys]] FancyZones
*Currently using this on Windows*
https://learn.microsoft.com/en-us/windows/powertoys/fancyzones
Can set up zones like in Rectangle.
#### Hammerspoon
https://www.hammerspoon.org/ is a scripting framework for macOS in lua
Can move windows to common locations, i.e.:
https://github.com/anandpiyer/.dotfiles/blob/master/.hammerspoon/init.lua#L291
#### Applescript
https://unix.stackexchange.com/questions/39900/move-position-of-an-application-window-from-the-command-line-on-osx
```bash
$ osascript \
    -e 'tell application "Terminal"' \
    -e 'set position of front window to {1, 1}' \
    -e 'end tell'
```
