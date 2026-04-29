#rant

Apple made [Force Touch](https://support.apple.com/en-us/102309?utm_source=chatgpt.com) for trackpads, but my 2005 Microsoft mouse managed to "recreate" it *as a hardware failure mode.*
Or, how I burned a bunch of time debugging a "software" bug that turned out to be a dying mouse.

On my MacBook in clamshell mode, a mouse left-click was ignored most of the time across Finder, Chrome, and basically everything else. A double-click usually worked. I started with the usual software suspicions:
1. I turned on "Ignore built-in trackpad when mouse or wireless trackpad is present." That seemed to improve things, but only partly.
2. I ran [`hidutil list`](https://developer.apple.com/documentation/corehid/discoveringhiddevicesfromterminal) and confirmed macOS could see both the internal trackpad and my `Microsoft 3-Button Mouse with IntelliEye(TM)`. 
3. I upgraded macOS to latest our IT has approved, which served as a nice forced reboot.
4. I configured [Karabiner-Elements](https://karabiner-elements.pqrs.org/) to not filter events from my mouse
5. I quit Karabiner-Elements (it seems that it *does* filter HID events?)
6. I ran [Karabiner-EventViewer](https://karabiner-elements.pqrs.org/docs/manual/operation/eventviewer/) to watch click events. Then I noticed: on quick, light clicks, no event showed up at all. On longer presses, clicks would work again for a few seconds. ...That sent me down a timing rabbit hole: "100ms clicks work" and "after a 1-second press it behaves for about 5 seconds"

The real variable was just how **firmly** I was clicking.
I plugged in a different mouse. Force Touch went away. Problem fixed.
