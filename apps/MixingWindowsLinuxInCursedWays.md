#literature 
*found from [2024 mid-year link clearance - The Old New Thing](https://devblogs.microsoft.com/oldnewthing/?p=109945#:~:text=Taking%20the%20deepest,it%20and%20weep)*

[taking the deepest possible breath](https://web.archive.org/web/20250109162723/https://cohost.org/cathoderaydude/post/1228730-taking-the-deepest-p)
- Three different dual-OS solutions:
	1. Dual-boot linux/windows
	2. Virtualize both linux/windows, and switch between (but, just imagine a Windows VM on a netbook!)
	3. ...use BISO sleep as a "hypervisor"
- Windows OS tells the BIOS, via ACP, enters S3 sleep, then OSM custom BIOS takes over
- Swapping between the OS:
	- Split RAM: 1.5GB for Windows, and 0.5GB for Hyperspace Linux
		- Swap which RAM was addressable to the active OS
	- Linux can write to Window's NTFS drive *while it is asleep*
		- NTFS changes are instead written to a journal file
		- When Windows resumes, a custom driver replays edits from journal file

[Hell Never Ends On x86: The Hyperspace Story, Continued, Sort Of](https://web.archive.org/web/20250109160318/https://cohost.org/cathoderaydude/post/1311259-hell-never-ends-on-x)
- UEFI app: not running on Linux "baremetal UI library"
- firmware app running while windows boots, using HP's System Management Mode: 
	- SMM firmware runs higher than ring 0
	- Updates VGA framebuffer to show progress bar updates while also showing user calendar details
