
## Time-travel / reversible debugging

See [[snapshots#Debugger record/replay]] for the full comparison. Quick reference:

- **Linux/WSL2**: [`rr`](https://rr-project.org/) — record once, replay deterministically with gdb (reverse-continue, reverse-step). Best for C/C++ native code.
- **Browser JS**: [replay.io](https://www.replay.io/#devtools) — records browser execution for replay
    - [ ] try it
- **Windows**: [WinDbg TTD](https://learn.microsoft.com/en-us/windows-hardware/drivers/debuggercmds/time-travel-debugging-overview) — `.run` trace files, forward/backward stepping. Ships with WinDbg Preview.
- **Azure VMs (.NET)**: Visual Studio Enterprise [Time Travel Debugging](https://learn.microsoft.com/en-us/visualstudio/debugger/debug-live-azure-virtual-machines-time-travel-debugging) and [Snapshot Debugger](https://learn.microsoft.com/en-us/visualstudio/debugger/debug-live-azure-virtual-machines) for live ASP.NET apps
- **Visual Studio (local .NET)**: [IntelliTrace](https://learn.microsoft.com/en-us/visualstudio/debugger/view-snapshots-with-intellitrace) step-back snapshots at each breakpoint/step
