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