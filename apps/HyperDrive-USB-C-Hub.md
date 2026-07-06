---
aliases:
  - ethernet
---
Bought https://www.amazon.com/dp/B09NBS9DS6
HyperDrive 
- 4K Dual HDMI 
- USB C Hub 
- Gigabit Ethernet, 
- USB-A, 
- USB-C 100W Power Delivery, 
- MicroSD/SD, 
- Headphone Jack
- for
	- MacBook Pro/Air(M1),
	- Windows PC
	- Chromebook

## Uses InstantView tool
>DP Alt Mode requires the “USB-C” port on your computer to support this feature - DP Alt Mode.SMI’s InstantView requires the USB-C port on the host computer to support USB data transfer.

Combines ports
- [x] USB-C Power passthrough
- [x] USB-A data
- [x] HDMI cable
- [ ] Didn't get 2nd monitor USB-C DP working: try another HDMI
- [ ] NEXT, check if InstantView can be  configured to support USB-C DP
## Wake-on-LAN isn't working
Enable Wake for Network Access:
Using System Settings: Go to System Settings > Battery (or Energy Saver) > Options > Wake for network access. 

Getting machine IP Address / Mac Address
- [ ] Need to check if it's `en6` or `en8`, etc.
```
$ ipconfig getifaddr en6
192.168.86.37

$ networksetup -getmacaddress en6
Ethernet Address: DE:AD:BE:EF:12:34 (Device: en6)
```

#ai-slop summary 
>Wake-on-LAN (WoL) for MacBooks in that kind of setup—Ethernet → USB-C hub → MacBook—is tricky and usually does not work reliably, and here’s why:
>USB-C to Ethernet via a generic hub usually doesn't support WoL, because USB Ethernet adapters often get fully powered down during sleep.
>The MacBook’s logic board needs to support waking from sleep via an external USB network device, which Apple does not typically support.
>
> 🛠️ Workarounds (if you really want to try)
> Use a Thunderbolt Ethernet adapter (not USB-C): Thunderbolt has better integration and might stay powered in sleep mode.
> Enable WoL in macOS settings:
> System Settings → Battery (or Energy Saver) → Enable “Wake for network access”.
> Test while asleep (not powered off): macOS only supports WoL from sleep, not from full shutdown.
- [ ] Next try a Thunderbolt Ethernet adapter?

## Debugging Ethernet Link Down
#ai-slop 
Problem: Ethernet adapter shows `status: inactive` even though hub is detected and driver loaded. Interface name may change (en6, en8, etc.) when hub is replugged.

Quick check if Ethernet is working:
```bash
# Find current interface name
networksetup -listallhardwareports | grep -A 2 "USB 10/100/1000 LAN"

# Check link status (should show "active" not "inactive")
ifconfig en8 | grep status
```

### Debugging Steps

Verify hardware detection:
```bash
# Check if USB device is detected (should show Realtek 0bda:8153)
# TODO system_profiler doesn't work?
# system_profiler SPUSBDataType | grep -A 10 "USB 10/100/1000 LAN"

# Check if driver is loaded
kextstat | grep realtek
```

Check interface configuration:
```bash
# Full interface details
ifconfig en8

# Network service settings
networksetup -getinfo "USB 10/100/1000 LAN"

# Current routing (should see en8 if Ethernet is active)
netstat -rn | grep default
```

Force interface restart:
```bash
sudo ifconfig en8 down && sudo ifconfig en8 up
sleep 2
ifconfig en8 | grep status
```

Monitor link changes in real-time:
```bash
watch -n 1 'ifconfig en8 | grep status; date'
```

Check system logs for errors:
```bash
# Network subsystem logs (all traffic should use en0 if Ethernet down)
log show --last 5m --predicate 'subsystem == "com.apple.network"' | grep en8

# USB/hardware logs
log show --last 5m --predicate 'subsystem == "com.apple.iokit.IOUSBHostFamily"' | grep -i ethernet
```

### Troubleshooting Results

Tested 2026-02-02:
- [x] Hub detected as Realtek RTL8153 at Location ID 0x02231000
- [x] Driver loaded: com.apple.driver.usb.realtek8153patcher
- [x] Interface en8 exists with autoselect mode
- [x] Link status remains inactive after:
	- Multiple cable reseats
	- Interface down/up cycle
	- Network infrastructure power cycle
- [ ] Next: Reboot MacBook to reset USB stack
- [ ] If still failing: Test cable with another device
- [ ] If still failing: Try different router port or cable

### 2026-05-20 morning
`system_profiler SPUSBDataType | grep -A 10 "USB 10/100/1000 LAN"` failed

```
$ system_profiler SPUSBDataType | grep -A 10 "USB 10/100/1000 LAN"
NativeCommandExitException: Program "grep" ended with non-zero exit code: 1.
$ system_profiler SPUSBDataType | grep -A 10 "usb"
NativeCommandExitException: Program "grep" ended with non-zero exit code: 1.

$ log show --last 5m --predicate 'subsystem == "com.apple.network"' | grep en8
2026-05-20 09:14:17.507764-0700 0x1154ff5  Default     0x0                  765    0    symptomsd: (Network) [com.apple.network:listener] nw_listener_reconcile_inboxes_on_queue_block_invoke_2 [L1] cancelling retired inbox: flow: 9181A457-DEBF-41BB-9CCD-E0A63FB52097 interface: en8, assigned, local: <private>, scope: 23, protocol: 6
2026-05-20 09:14:17.511015-0700 0x1154ff5  Default     0x0                  765    0    symptomsd: (Network) [com.apple.network:listener] nw_listener_reconcile_inboxes_on_queue_block_invoke [L1] Started inbox flow: 546F69D7-237D-4C0A-95F5-2B107E91656A interface: en8, assigned, local: <private>, scope: 23, protocol: 6 with parameters tcp, local: ::.0, definite, attribution: developer, server, attach protocol listener, don't always open listener socket
2026-05-20 09:18:25.280213-0700 0x115c1fc  Default     0x0                  765    0    symptomsd: (Network) [com.apple.network:listener] nw_listener_reconcile_inboxes_on_queue_block_invoke_2 [L1] cancelling retired inbox: flow: 546F69D7-237D-4C0A-95F5-2B107E91656A interface: en8, assigned, local: <private>, scope: 23, protocol: 6
2026-05-20 09:18:25.281134-0700 0x115c1fc  Default     0x0                  765    0    symptomsd: (Network) [com.apple.network:listener] nw_listener_reconcile_inboxes_on_queue_block_invoke [L1] Started inbox flow: E865CF32-FC9D-417C-BCFD-2E51F66FD211 interface: en8, assigned, local: <private>, scope: 23, protocol: 6 with parameters tcp, local: ::.0, definite, attribution: developer, server, attach protocol listener, don't always open listener socket

$ log show --last 5m --predicate 'subsystem == "com.apple.iokit.IOUSBHostFamily"' | grep -i ethernet
NativeCommandExitException: Program "grep" ended with non-zero exit code: 1.

# Got wot it working!

$ system_profiler SPUSBDataType | rg 'lan|usb'
NativeCommandExitException: Program "rg" ended with non-zero exit code: 1.
```

1. Tried just unplugging ethernet at either end
2. Tried power cycling the network switch

***Worked***: unplug Hyper hub from macbook / power / ethernet and wait for a minute, it cooled down
Testing mitigation: aluminum 1/4 baking sheet as heat sink? doesn't make flush contact with metal case though...
- [ ] Instant read kitchen thermometer to see how effective this is
- [ ] thermal compound or something squishy?

AI-Generated temp guidelines:
> Rough guide for the **outside surface**:
> - **<45°C / 113°F**: warm, probably fine.
> - **45–55°C / 113–131°F**: hot to touch, plausible for a compact hub under PD + monitor + Ethernet.
> - **55–60°C / 131–140°F**: getting concerning for a user-touchable device.
> - **>60°C / 140°F**, burning smell, discoloration, disconnects, or “too hot to touch for more than a moment”: I’d stop using that load/setup.


| date       | °F  |
| ---------- | --- |
| 2026-05-21 | 124 |

## 2026-05-20 9PM
Not working again...!
Gave up and enabled wifi, which got onto VPN immediately...
