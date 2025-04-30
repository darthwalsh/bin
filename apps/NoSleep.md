Each OS has different strategies to prevent sleep, and to query which processes are preventing sleep.
## Windows
Find what caused system to wake up:
```
powercfg /lastwake
```
Find which process is preventing sleep:
```
powercfg /requests
```
Can keep PC awake with [PowerToys Awake](https://learn.microsoft.com/en-us/windows/powertoys/awake)
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
