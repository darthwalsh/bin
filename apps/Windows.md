- [ ] merge in from OneNote Dev/Windows
- [ ] merge in from [[Discovery Rebuild]]

- [ ] Try https://learn.microsoft.com/en-us/windows/dev-home/ on Windows 11

## Window Management
[[WindowManagement#Windows]]
Fix the cursor jumping problem:
>Windows 11 Settings > System > Displays, open the Multi-Displays menu and uncheck the 'Move cursor between displays easily' checkbox
## Dev Drive
https://learn.microsoft.com/en-us/windows/dev-drive/

>Dev Drive builds on [ReFS](https://learn.microsoft.com/en-us/windows-server/storage/refs/refs-overview) technology to employ targeted file system optimizations and provide more control over storage volume settings and security, including trust designation, antivirus configuration, and administrative control over what filters are attached.
> 
> The Dev Drive is intended for:
> - Source code repositories and project files
> - Package caches
> - Build output and intermediate files

Created drive E as new NVMe disk partition with 54.6 GB file system, mapped to `C:\code`
- [ ] Try setting up npm/python/nuget cache https://learn.microsoft.com/en-us/windows/dev-drive/#storing-package-cache-on-dev-drive #windows 🔼 
## sudo for Windows
https://superuser.com/a/1829512/282374
>official Sudo for Windows 11

[Sudo for Windows](https://learn.microsoft.com/en-us/windows/sudo/?wt.mc_id=windows_inproduct_sudo)
https://github.com/microsoft/sudo
## Finding which process creates CMD windows
Often a black window flashes up on Windows, which is caused by an EXE-compiled-as-console-app being launched.
It's [possible](https://www.reddit.com/r/Windows10/comments/1lqs45h/comment/n17c52q/?context=3) to set group policy settings: **Audit Process Creation** and **Include command line in process creation events**.
- [ ] [ChatGPT says](https://chatgpt.com/share/686c82d7-3108-8011-847f-78b41c5d2c98) it's possible to set this on Windows 11 Home SKU.
## Windows Hello Camera
- Downloaded "C:\Users\darth\Downloads\MouseWindowsHelloWebcamCm01Driver.zip" from https://www2.mouse-jp.co.jp/ssl/user_support2/cm01/driver.asp
    - https://www.manualslib.com/uploads/?type=link for https://download1.mouse-jp.co.jp/user_support/CM01-A%20QSG.PDF
    - Now renamed to [eMeet Facial Recognition Camera for Windows Hello CM01-A : Electronics](https://www.amazon.com/gp/product/B01MSEJPJP/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1)
- after install, Windows Device Manager sees new Biometric device: Facial Recognition
- Windows Hello setup failed to see the device for a couple days, but then it just started working?
- Ran recognition with and without glasses
## Audio
Set to mono because I often use headphones with one ear

