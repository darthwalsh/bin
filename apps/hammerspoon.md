https://www.hammerspoon.org/go/
- [ ] Try [[WindowManagement#Hammerspoon]]
- [ ] Try [[#cron]]
- [ ] Can activate a function by using a URL listener, if no easier, CLI 
- [ ] keyboard shortcut to enter [[yubikey]] PIN?
- [ ] can automate watching for application closed, good for a meeting bar app crashing? 

## cron
#ai-slop  can check https://chatgpt.com/c/688d9da8-2d3c-8011-9e4a-7368d37fd523
- [ ] verify this
`~/.hammerspoon/init.lua`

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
- [ ] Figure out error handling with [[fail-log.ps1]] 
- If your script does anything GUI-related (e.g. controlling apps), ensure **Hammerspoon is allowed** under **System Settings → Privacy & Security → Accessibility** and **Full Disk Access** if needed.
- Unlike `cron`, timers in Hammerspoon **only run when you're logged in** and Hammerspoon is running.