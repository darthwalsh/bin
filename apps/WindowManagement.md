- [ ] Look into https://github.com/hoppfrosch/WindowPadX as an option on Windows
## Workspace MultiWindow Management

Currently using hotkeys to move windows around, but would like to try a tool to move known windows to known locations.

### Rectangle
*Currently using this on macOS*
Pro version https://rectanglepro.app/ has feature:
>Arrange an entire workspace of apps with just one shortcut.
Activate when displays are connected or disconnected.

Funnily, if you focus chrome Cmd+F find dialog, Rectangle will move it around...
- [ ] Document current Rectangle configuration and [[keybindings|hotkeys]]? #macbook ⏫ 
- [ ] Try RectanglePro trial 🔽 

### Raycast
[Window Management](https://manual.raycast.com/window-management) is built-in; snapshot-based **Window Layouts** (save current positions → re-apply later) require [Raycast Pro](https://www.raycast.com/pro).

Raycast can place windows on specific monitors and resize to halves/quarters, but **cannot** react to events (app launch, screen unlock). For "run on unlock", use Hammerspoon below.

**Setup: apply a saved layout at screen unlock**

1. Position windows manually (Raycast → `Move Window to Next Display`, `Top Half`, etc.)
2. Raycast → `Create Window Layout`, name it
3. Raycast → `Window Layouts` → select layout → Actions → `Copy Deeplink`
   - Deeplink looks like: `raycast://extensions/raycast/window-management/apply-layout?id=XXXXXXXX`
4. Pass the deeplink to Hammerspoon's `screensDidUnlock` (see below), or run it via `open -g <deeplink>` in a shell script

> First-run note: Raycast may prompt "Always Open Command" the first time a deeplink fires.

### Hammerspoon
*See: [[hammerspoon]]*

[Hammerspoon](https://www.hammerspoon.org/) is a macOS scripting framework in Lua. Unlike Raycast, it can react to events: app launch, screen unlock, monitor changes.

- [ ] Try it to see if it works https://chatgpt.com/c/67bebedb-1314-8011-9f1e-5b20bcf222da
**Apply layout on screen unlock** — add to `~/.hammerspoon/init.lua`:

```lua
local screen2 = hs.screen.find("DELL U2720Q")  -- replace with your monitor name

local function place(appName, unit)
  local app = hs.appfinder.appFromName(appName)
  if not app then return end
  local win = app:mainWindow()
  if not win then return end
  win:moveToScreen(screen2)
  win:moveToUnit(unit)
end

hs.caffeinate.watcher.new(function(event)
  if event == hs.caffeinate.watcher.screensDidUnlock then
    hs.timer.doAfter(0.5, function()
      place("Slack",    hs.layout.top50)
      place("Obsidian", hs.layout.bottom50)
    end)
  end
end):start()
```

To find your monitor name: run `hs.screen.allScreens()` in the Hammerspoon console.

Add **Hammerspoon to Login Items** (System Settings → General → Login Items) so the watcher is always running.

Also spoon plugin: [miro-windows-manager](https://github.com/miromannino/miro-windows-manager) — move windows with arrows, resize by thirds/quarters.

### Display Maid
>https://funk-isoft.com/display-maid.html allows you to save and restore window locations based on your display configuration or user created profiles.
- [ ] Try it #macbook  🔼 

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
## Divvy
Costs $13.99, available on mac and windows: https://mizage.com/divvy/
