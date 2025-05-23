Each OS has different strategies to prevent sleep, and to query which processes are preventing sleep.
## Windows
Find what caused system to wake up, need to run elevated:
```
sudo powercfg /lastwake
```
Find which process is preventing sleep:
```
sudo powercfg /requests
```
Can probably *prevent* a process from requesting sleep with `powercfg /requestsoverride process MoUsoCoreWorker.exe execution` (then reboot) but haven't tested this.

Can keep PC awake with [PowerToys Awake](https://learn.microsoft.com/en-us/windows/powertoys/awake)

### App idea with nice UX
#app-idea 
Constantly needing to run an elevated shell is a bad experience.
My old PC has terrible problems with Windows Update running [MoUsoCoreWorker would keep the PC awake forever](https://answers.microsoft.com/en-us/windows/forum/windows_10-power/mouso-core-worker-process-mousocoreworkerexe/86a8656b-d4f7-4b5b-bd5c-286bffa02c4d?auth=1&page=15) (see also 306 replies effectively all saying "+1").

I used to run a scheduled task every thirty minutes like
```
pwsh.exe -c "Get-Date >> ~\wakereason.txt; powercfg -requests >> ~\wakereason.txt"
```
which gave me both history, and I didn't have to elevate all the time.

Instead, it would be great to have a little notification-area-app, what you could click and query for which process is keeping awake. There'd be some elevated Windows Service in the background that just answers these queries.

Some v1 app ideas:
- option to (nicely) close that app/service
- local database and view for when different apps are causing awake
- maybe have allow-list like "I don't care if spotify is keeping PC awake, that's expected"
- add hook so when manually sleeping PC, if an app is causing awake, beep and immediately awaken and notify the user about the bad app. (Better now than at 2AM.)
## macOS
Use tool `pmset` to find out which process is preventing sleep:
```
$ pmset -g assertions | egrep '(PreventUserIdleSystemSleep|PreventUserIdleDisplaySleep)'
   PreventUserIdleDisplaySleep    0
   PreventUserIdleSystemSleep     1
   pid 31733(caffeinate): [0x000fa7bf00018505] 00:00:01 PreventUserIdleSystemSleep named: "caffeinate command-line tool"
   pid 340(powerd): [0x000fa39c000183dc] 00:17:39 PreventUserIdleSystemSleep named: "Powerd - Prevent sleep while display is on"
```
- `caffeinate` is keeping machine on
- Also "Prevent sleep while display is on"

Use `caffeinate <cmd> <arg>` to keep system awake while running a long command. Display might sleep, but network connections stay open.
