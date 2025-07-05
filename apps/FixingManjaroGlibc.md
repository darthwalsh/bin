## Managed to break my WSL VM with a normal system upgrade!

```
$ ls
/usr/sbin/ls: /usr/lib/libc.so.6: version `GLIBC_ABI_DT_RELR' not found (required by /usr/sbin/ls)
/usr/sbin/ls: /usr/lib/libc.so.6: version `GLIBC_2.38' not found (required by /usr/sbin/ls)
/usr/sbin/ls: /usr/lib/libc.so.6: version `GLIBC_2.34' not found (required by /usr/sbin/ls)
```

It looks like the cause was a partial upgrade holding back glibc:
> warning: glibc: ignoring package upgrade (2.33-4 => 2.39-2)

## Partial upgrades are unsupported
This is not supported: https://wiki.archlinux.org/title/system_maintenance#Partial_upgrades_are_unsupported

In `/etc/pacman.conf` I found the line: 

```
IgnorePkg = glibc
```

It seems this happened to somebody else too: https://forum.manjaro.org/t/can-i-upgrade-to-glibc-2-36/118417/4

Possibly related: https://github.com/makotom/glibc-wsl?tab=readme-ov-file#how-to
But, I'm using WSL 2 with Manjaro so it seems like this shouldn't have been needed?

Possibly related: https://github.com/microsoft/WSL/issues/4898#issuecomment-660181416
## How I installed Manjaro

This was from https://github.com/sileshn/ManjaroWSL which has been renamed to https://github.com/sileshn/ManjaroWSL2
```pwsh
$ ./Manjaro.exe --version
wsldl2, version 21082800  (amd64)
https://git.io/wsldl
```

The output includes wsldl which is from https://github.com/yuk7/wsldl which does the job of unpackaging the repo

Then ran these commands:

```
.\Manjaro.exe
./Manjaro.exe config --default-user carl
./Manjaro.exe config 
./Manjaro.exe help
./Manjaro.exe config --default-term
./Manjaro.exe config --default-term wt
```

## Getting a working pacman-static without glibc
Downloaded from https://aur.archlinux.org/packages/pacman-static and used Linux share in File Explorer to copy it to WSL

Just need to set the **executable permission** on the file... when all I have is one pwsh shell process still running.

Linux options that won't work:
- Can't use `chmod` because no glibc
- Can't use `cp --preserve` because no glibc
- Can't use umask feature, that's only in POSIX shells...

Can't use https://learn.microsoft.com/en-us/dotnet/api/system.io.filesysteminfo.unixfilemode
- Not in .NET 5
- But .NET 5 docs for https://learn.microsoft.com/en-us/dotnet/api/system.io.fileinfo?view=net-5.0 seem to indicate that UnixFileMode did exist?

What ended up working was doing the same logic as `cp --preserve` but in powershell:
```
$ ./homework/teacher/app
/home/carl/homework/teacher/app: /usr/lib/libc.so.6: version `GLIBC_2.38' not found (required by /usr/lib/libstdc++.so.6)
/home/carl/homework/teacher/app: /usr/lib/libc.so.6: version `GLIBC_2.36' not found (required by /usr/lib/libstdc++.so.6)
/home/carl/homework/teacher/app: /usr/lib/libc.so.6: version `GLIBC_2.34' not found (required by /usr/lib/libstdc++.so.6)
/home/carl/homework/teacher/app: /usr/lib/libc.so.6: version `GLIBC_2.35' not found (required by /usr/lib/libgcc_s.so.1)
/home/carl/homework/teacher/app: /usr/lib/libc.so.6: version `GLIBC_2.34' not found (required by /usr/lib/libgcc_s.so.1)

$ copy-item ./homework/teacher/app .

$ $b = [System.IO.File]::ReadAllBytes("pacman-static")
$ [System.IO.File]::WriteAllBytes("app", $b)
$ ./app
warning: config file /etc/pacman.conf, line 20: directive 'SyncFirst' in section 'options' not recognized.
error: no operation specified (use -h for help)

$ remove-item ./pacman-static
$ copy-item app ./pacman-static
```

Executing from Windows
```
$ wsl  /home/carl/pacman-static --version
/usr/bin/pwsh: /usr/lib/libc.so.6: version `GLIBC_2.38' not found (required by /usr/lib/libstdc++.so.6)
/usr/bin/pwsh: /usr/lib/libc.so.6: version `GLIBC_2.36' not found (required by /usr/lib/libstdc++.so.6)
/usr/bin/pwsh: /usr/lib/libc.so.6: version `GLIBC_2.34' not found (required by /usr/lib/libstdc++.so.6)
/usr/bin/pwsh: /usr/lib/libc.so.6: version `GLIBC_2.35' not found (required by /usr/lib/libgcc_s.so.1)
/usr/bin/pwsh: /usr/lib/libc.so.6: version `GLIBC_2.34' not found (required by /usr/lib/libgcc_s.so.1)
NativeCommandExitException: Program "wsl.exe" ended with non-zero exit code: 1.
$ wsl --exec /home/carl/pacman-static --version

 .--.                  Pacman v6.0.1 - libalpm v13.0.1
/ _.-' .-.  .-.  .-.   Copyright (C) 2006-2021 Pacman Development Team
\  '-. '-'  '-'  '-'   Copyright (C) 2002-2006 Judd Vinet
 '--'
                       This program may be freely redistributed under
                       the terms of the GNU General Public License.
```

## Executing as root without sudo
IIRC `sudo` wouldn't run without glibc? But I can use `wsl.exe` for that!

```
$ wsl --exec /home/carl/pacman-static -Syu
error: you cannot perform this operation unless you are root.
NativeCommandExitException: Program "wsl.exe" ended with non-zero exit code: 1.

$ wsl --user root --exec /home/carl/pacman-static -Syu
warning: config file /etc/pacman.conf, line 20: directive 'SyncFirst' in section 'options' not recognized.
:: Synchronizing package databases...
 core is up to date
 extra                                                                                              8.6 MiB  7.63 MiB/s 00:01 [############################################################################] 100% community is up to date
 multilib is up to date
:: Starting full system upgrade...
warning: glibc: ignoring package upgrade (2.33-4 => 2.39-2)
 there is nothing to do

 $ wsl --user root --exec /home/carl/pacman-static -yy -S glibc
warning: config file /etc/pacman.conf, line 20: directive 'SyncFirst' in section 'options' not recognized.
:: Synchronizing package databases...
 core                                                                                             146.1 KiB   105 KiB/s 00:01 [############################################################################] 100% extra                                                                                              8.6 MiB  11.7 MiB/s 00:01 [############################################################################] 100% community                                                                                         29.0   B  87.0   B/s 00:00 [############################################################################] 100% multilib                                                                                         144.4 KiB  1031 KiB/s 00:00 [############################################################################] 100%:: glibc is in IgnorePkg/IgnoreGroup. Install anyway? [Y/n]
resolving dependencies...
looking for conflicting packages...

Packages (1) glibc-2.39-2

Total Download Size:    9.82 MiB
Total Installed Size:  47.27 MiB
Net Upgrade Size:       1.23 MiB

:: Proceed with installation? [Y/n]
:: Retrieving packages...
 glibc-2.39-2-x86_64                                                                                9.8 MiB  7.38 MiB/s 00:01 [############################################################################] 100%(1/1) checking keys in keyring                                                                                                [############################################################################] 100%
error: GPGME error: Invalid crypto engine
(1/1) checking package integrity                                                                                              [############################################################################] 100%
error: GPGME error: Invalid crypto engine
error: glibc: missing required signature
:: File /var/cache/pacman/pkg/glibc-2.39-2-x86_64.pkg.tar.zst is corrupted (invalid or corrupted package (PGP signature)).
Do you want to delete it? [Y/n]
error: failed to commit transaction (invalid or corrupted package (PGP signature))
Errors occurred, no packages were upgraded.
NativeCommandExitException: Program "wsl.exe" ended with non-zero exit code: 1.
```
## Getting past GPG errors
All the forum posts say to use `pacman-key` to refresh keys but that crashes on glibc errors...

Instead, just disable the signature checks: https://archlinux.org/pacman/pacman.conf.5.html#SC
Didn't find a CLI option for this, and can't edit the root config file, so make a copy...

```
~ copy-item /etc/pacman.conf .

# Append these lines to ./pacman.conf 

# IgnorePkg = glibc
SigLevel    = Never
# LocalFileSigLevel = Optional


$ wsl --user root --exec /home/carl/pacman-static -yy -S glibc --config /home/carl/pacman.conf
warning: config file /home/carl/pacman.conf, line 20: directive 'SyncFirst' in section 'options' not recognized.
:: Synchronizing package databases...
 core                                                                                             146.1 KiB   200 KiB/s 00:01 [############################################################################] 100% extra                                                                                              8.6 MiB  12.0 MiB/s 00:01 [############################################################################] 100% community                                                                                         29.0   B   223   B/s 00:00 [############################################################################] 100% multilib                                                                                         144.4 KiB   963 KiB/s 00:00 [############################################################################] 100%resolving dependencies...
looking for conflicting packages...

Packages (1) glibc-2.39-2

Total Download Size:    9.82 MiB
Total Installed Size:  47.27 MiB
Net Upgrade Size:       1.23 MiB

:: Proceed with installation? [Y/n]
:: Retrieving packages...
 glibc-2.39-2-x86_64                                                                                9.8 MiB  19.3 MiB/s 00:01 [############################################################################] 100%(1/1) checking keys in keyring                                                                                                [############################################################################] 100%
(1/1) checking package integrity                                                                                              [############################################################################] 100%
(1/1) loading package files                                                                                                   [############################################################################] 100%
(1/1) checking for file conflicts                                                                                             [############################################################################] 100%
:: Processing package changes...
(1/1) upgrading glibc                                                                                                         [############################################################################] 100%
Generating locales...
Generation complete.
New optional dependencies for glibc
    perl: for mtrace [installed]
:: Running post-transaction hooks...
(1/4) Reloading system manager configuration...
  Skipped: Current root is not booted.
(2/4) Arming ConditionNeedsUpdate...
(3/4) Cleaning up package cache...
(4/4) Updating the info directory file...

$ wsl bash --version
GNU bash, version 5.2.26(1)-release (x86_64-pc-linux-gnu)
Copyright (C) 2022 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>

This is free software; you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
```

## Victory!
In summary this was definitely slower than just reinstalling the Manjaro distro (or switching to Arch).
But you can learn a ton by trying to fix an error in-place!

