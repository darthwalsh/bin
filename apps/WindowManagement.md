- [ ] Look into https://github.com/hoppfrosch/WindowPadX as an option on Windows
## Workspace MultiWindow Management

Currently using hotkeys to move windows around, but would like to try a tool to move known windows to known locations.
### Display Maid
>https://funk-isoft.com/display-maid.html allows you to save and restore window locations based on your display configuration or user created profiles.
- [ ] Try it #macbook  🔼 
### Rectangle
*Currently using this on macOS*
Pro version https://rectanglepro.app/ has feature:
>Arrange an entire workspace of apps with just one shortcut.
Activate when displays are connected or disconnected.

Funnily, if you focus chrome Cmd+F find dialog, Rectangle will move it around...
- [ ] Document current Rectangle configuration and [[keybindings|hotkeys]]? #macbook ⏫ 
- [ ] Try RectanglePro trial 🔽 
### Raycast
Has basic windows management
- [ ] not sure about "Custom Window Management" only in [pro subscription](https://www.raycast.com/pro)?
### Hammerspoon
https://www.hammerspoon.org/ is a scripting framework for macOS in lua
Can move windows to common locations, i.e.:
https://github.com/anandpiyer/.dotfiles/blob/master/.hammerspoon/init.lua#L291
Can find a window by name, and find its screen max dimensions, and resized
- [ ] Try it https://chatgpt.com/c/67bebedb-1314-8011-9f1e-5b20bcf222da

```lua
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
    local slack = hs.appfinder.appFromName("Slack")
    if slack then
        local win = slack:mainWindow()
        if win then
            local screen = win:screen()
            local max = screen:frame()
            win:setFrame(hs.geometry.rect(max.w / 2, max.y, max.w / 2, max.h))
        end
    end
end)
```

Also spoon plugin: [miromannino/miro-windows-manager: Intuitive and clever mechanism for moving windows using only arrows, even resizing windows by thirds or quarters! For OSX](https://github.com/miromannino/miro-windows-manager)
### MacsyZones
[MacsyZones, FancyZones for macOS](https://macsyzones.com/)
- Tried it, and seems to work like FancyZones but not sure exactly how to get working
- Doesn't seem to support moving known windows to specific zones
### Applescript
https://unix.stackexchange.com/questions/39900/move-position-of-an-application-window-from-the-command-line-on-osx
```bash
$ osascript \
    -e 'tell application "Terminal"' \
    -e 'set position of front window to {1, 1}' \
    -e 'end tell'
```

# Windows
#### [[PowerToys]] FancyZones
*Currently using this on Windows*
https://learn.microsoft.com/en-us/windows/powertoys/fancyzones
Can set up zones like in Rectangle.
