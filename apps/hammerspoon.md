#ai-slop

https://www.hammerspoon.org/go/

Hammerspoon is a macOS automation bridge between the operating system and Lua scripting. It's the power-user's alternative to complicated Swift listeners + launchd plists.

- [ ] Try [[WindowManagement#Hammerspoon]]
- [ ] Try [[#cron]]
- [ ] Can activate a function by using a URL listener, if no easier, CLI 
- [ ] keyboard shortcut to enter [[yubikey]] PIN?
- [ ] can automate watching for application closed, good for a meeting bar app crashing? 

## Why Hammerspoon vs launchd/plist

macOS's builtin `launchd` (`.plist` files) can trigger tasks on login, on schedule, or when folders change, but it **cannot** trigger on **screen unlock** or monitor changes. On Windows, [[TaskScheduler]] has direct hooks into Winlogon events. On macOS, you need a background process that listens to system notifications. It uses event-driven architecture for efficiency.

## Run scripts on screen unlock

Use `hs.caffeinate.watcher` to observe power/screen events and trigger scripts.

### POC: Run window management on unlock

Edit `~/.hammerspoon/init.lua`:
```lua
local unlockWatcher = hs.caffeinate.watcher.new(function(event)
    if event == hs.caffeinate.watcher.screensDidUnlock then
        -- Run your window management script
        hs.execute("/opt/homebrew/bin/pwsh ~/bin/arrange-windows.ps1")
        
        -- Or inline Lua window management
        -- local laptop = hs.screen.primaryScreen()
        -- hs.application.launchOrFocus("iTerm")
        -- local iterm = hs.application.get("iTerm")
        -- if iterm then
        --     local win = iterm:mainWindow()
        --     if win then win:moveToScreen(laptop) end
        -- end
    end
end)
unlockWatcher:start()
```

Reload config: `Cmd + Ctrl + R` or click Hammerspoon menu bar icon → "Reload Config"

Available caffeinate events: https://www.hammerspoon.org/docs/hs.caffeinate.watcher.html
**Unlock vs Wake**: `screensDidUnlock` waits until you've typed your password. `screensDidWake` fires when the display powers on (before password entry if lock is enabled).

### Prevent double-execution (cooldown)

Sometimes macOS fires unlock events twice (e.g., Apple Watch unlock). Add a cooldown:

```lua
local lastUnlockTime = 0
local cooldownSeconds = 3

local unlockWatcher = hs.caffeinate.watcher.new(function(event)
    if event == hs.caffeinate.watcher.screensDidUnlock then
        local now = os.time()
        if now - lastUnlockTime < cooldownSeconds then
            return  -- Skip this duplicate event
        end
        lastUnlockTime = now
        
        hs.execute("/opt/homebrew/bin/pwsh ~/bin/arrange-windows.ps1")
    end
end)
unlockWatcher:start()
```

### Alternatives to Hammerspoon
- **SleepWatcher**: CLI tool that hooks into IOKit power management. Listens to hardware wake events (not specifically "unlock"). Creates `~/.wakeup` script that runs on display wake.
- **Native Swift + launchd**: Create a Swift script that listens to `com.apple.screenIsUnlocked` via `DistributedNotificationCenter`, then use a plist to keep it running. More code, more files to manage:
	```bash
	# Swift one-liner (run via launchd plist)
	swift -e 'import Foundation; DistributedNotificationCenter.default().addObserver(forName: NSNotification.Name("com.apple.screenIsUnlocked"), object: nil, queue: .main) { _ in _ = Process.launchedProcess(launchPath: "/bin/bash", arguments: ["/path/to/script.sh"]) }; RunLoop.main.run()'
	```


### Run scripts on monitor changes

Use `hs.screen.watcher` to detect when monitors are connected/disconnected or when screen configuration changes.

POC: Rearrange windows when monitors change:
```lua
local screenWatcher = hs.screen.watcher.new(function()
    hs.alert.show("Monitor configuration changed")
    hs.execute("/opt/homebrew/bin/pwsh ~/bin/arrange-windows.ps1")
end)
screenWatcher:start()
```


> [!NOTE] The name `caffeinate` is confusing! 
> Both used for sleeping: `hs.caffeinate.set()`, and running events on sleep-related functionality

## Scheduled tasks (cron alternative)

Run tasks periodically while logged in. See [[TaskScheduler]] for Windows equivalent.

Edit `~/.hammerspoon/init.lua`:

```lua
-- Define the task you want to run
function hourlyTask()
  hs.notify.new({title="Hourly Job", informativeText="This job just ran!"}):send()
  -- Or call an external script
  -- hs.execute("/opt/homebrew/bin/pwsh /Users/yourname/myscript.ps1", true)
end

-- Create a timer that runs every 3600 seconds (1 hour)
hourlyTimer = hs.timer.doEvery(3600, hourlyTask)

-- Optional: Run the task immediately on load
-- hourlyTask()
```

Then reload Hammerspoon (from the menu bar icon or with the shortcut: `Cmd + Ctrl + R`).

**Note**: Unlike `cron`, Hammerspoon timers **only run when you're logged in** and Hammerspoon is running.

## Permissions and troubleshooting

- [ ] Add error handling with [[fail-log.ps1]]
- Check Hammerspoon console for errors: Click menu bar icon → "Console"
- Test script execution manually: `hs.execute("/path/to/script.sh")` in the console
- If your script does anything GUI-related (e.g. controlling apps, moving windows), ensure **Hammerspoon is allowed** under **System Settings → Privacy & Security → Accessibility** and **Full Disk Access** if needed.
- Hammerspoon **cannot** move windows or interact with applications while the screen is locked. The OS restricts GUI automation when the session is locked for security.
```
