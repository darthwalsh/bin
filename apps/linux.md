## Families with packaging
#ai-slop I [asked](https://g.co/gemini/share/92383638423e) Gemini "... linux distros ... likely to be incompatible? top 40: what are families?"
Here I include the top distros I recognize, along with [[package manager]]:
- Debian uses `.deb` packages and `apt`
	- Ubuntu is derived from it
		-  Mint, Pop!, Kali derived from it
- Red Hat Enterprise Linux (RHEL) uses `.rpm` packages and `dnf` (previously `yum`)
	- Fedora, CentOS Stream are bleeding-edge upstream
	- Rocky, Alma, CentOS-Legacy are community-supported rebuilds
	- Oracle Linux is enterprise rebuild, with custom kernal
- openSUSE uses `.rpm` packages and `zypper` 
- Arch has both official repo and AUR/PKGBUILD scripts with `pacman` (`yay` is an unofficial AUR helper)
	- Manjaro and EndeavourOS try to be more use-friendly (but I've run into incompatibilities)
- Gentoo uses Portage packages with `emerge`
	- ChromeOS is heavily-modified, and can use `chromebrew`
- Slackware uses "Slackware packages"(?) with `pkgtool` or `slackpkg`
- Android uses APK packages with `pm` tool, or app stores like Google Play Store
	- Termux uses `.deb` packages, with `pkg` (not a distro, but a Linux Environment running in Android user-space that ships binaries linked to Android's Bionic libc instead of GNU glibc)
- [[nix|NixOS]] uses `.nix` expressions to create packages with `nix`
- Void Linux uses `.xbps` packages with `xbps-install`
