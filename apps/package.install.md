# Package Installation: Executable Code at Install Time
[A](https://socket.dev/blog/trivy-under-attack-again-github-actions-compromise) [new](https://www.sonatype.com/blog/compromised-litellm-pypi-package-delivers-multi-stage-credential-stealer) [supply](https://thehackernews.com/2026/03/axios-supply-chain-attack-pushes-cross.html) [chain](https://www.infosecurity-magazine.com/news/teampcp-targets-telnyx-pypi-package/) [attack](https://www.sysdig.com/blog/teampcp-expands-supply-chain-compromise-spreads-from-trivy-to-checkmarx-github-actions) [hits](https://thehackernews.com/2025/08/malicious-pypi-and-npm-packages.html) [every](https://blog.pypi.org/posts/2024-12-11-ultralytics-attack-analysis/) [week.](https://cloud.google.com/blog/topics/threat-intelligence/north-korea-threat-actor-targets-axios-npm-package)
One central question to any packaging format: **does it run code during installation, or just unpack files?**

Formats range from pure-data artifacts (copy bytes, done) to full installers that execute arbitrary logic, detect hardware, and mutate system state. Understanding where a format falls on this spectrum explains most of the friction, security trade-offs, and tooling differences.


> [!QUESTION] Does Install-Time Code Execution Actually Matter?
>  Suppose you have passwordless `sudo` and you're about to run the newly installed binary anyway. Does running a `postinstall` malicious script vs running a malicious binary represent meaningfully different risk?
>
> **Mostly no.** The scope of damage is the same either way. Once you've run untrusted code, the attacker is in. But it is simpler to inject malicious scripts outside the main binary.

## The Spectrum

| Model                    | Install logic                                   | Examples                                                                  |
| ------------------------ | ----------------------------------------------- | ------------------------------------------------------------------------- |
| **Xcopy / image deploy** | None — copy files, done                         | Go binary, .app bundle, Pi OS image, Factorio mod, Chrome extension, WASM |
| **Declarative unpack**   | Manifest-driven file placement + metadata       | Python wheel, npm package, MSIX/APPX, AAB, RPM/DEB (file payload only)    |
| **Scripted unpack**      | Declarative payload + optional shell scripts    | DEB (`postinst`), RPM (`%post`), Arch PKGBUILD, Gentoo ebuild              |
| **Scripted installer**   | Arbitrary code runs at install time             | MSI (custom actions), legacy `setup.py`, PKG (macOS), EXE installers      |
| **Boot-and-configure**   | Requires booting into a separate OS environment | Linux distro ISO, Windows Setup, recovery images                          |

## Why Linux Distro Installation Needs to Boot

This was my biggest surprise. A Linux ISO is not a tarball of the final OS — it's a live OS containing an installer program. The installer boots a temporary Linux kernel + initramfs, then uses standard Linux tools (`mkfs`, `mount`, `grub-install`) to:

- Partition and format disks (ext4/btrfs/xfs)
- Copy a compressed squashfs image → writable root filesystem
- Generate machine-specific config (`/etc/fstab`, initramfs, hostname, EFI boot entries)
- Install and configure the bootloader (GRUB/systemd-boot)

**Why can't a Windows/macOS app just "extract" a Linux ISO onto a partition?**
Three blockers:
1. **Filesystem**: the host OS can't natively create ext4/btrfs. Pi imagers sidestep this by writing raw disk images byte-for-byte (block-level `dd`-style copy, not filesystem-level); then first boot does minimal config (resize partition, generate host keys).
2. **Bootloader**: EFI/NVRAM entries, initramfs generation, and GRUB config all require running on the target hardware or at least a Linux environment.
3. **Machine-specific assembly**: unlike a Pi image (one board model, known hardware), a PC installer must probe hardware and make decisions about drivers, encryption, swap, etc.

**Comparison to [Windows Setup](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-setup-installation-process?view=windows-11)**: Windows `setup.exe` can launch from a running Windows because it does a staged handoff — copies installer files, registers a reboot-phase entry, then reboots into a setup environment. It's still "boot-and-configure," just with a smoother on-ramp from the running OS.

**VM-as-staging**: You can boot a Linux ISO inside a VM with [raw disk access](https://www.virtualbox.org/manual/ch09.html) to a second physical SSD, use the installer normally, then try to boot bare metal. But that doesn't guarantee bare-metal boot!

---

## Reference: Packaging Formats by Platform
#ai-slop 

### Operating Systems

| Format            | Code at install? | Install logic       | Notes                                         |
| ----------------- | ---------------- | ------------------- | --------------------------------------------- |
| **Linux ISO**     | Yes (full OS)    | Boot-and-configure  | squashfs live env → installer → target disk   |
| **Pi OS image**   | No               | Block-level copy    | `.img.xz` → raw write to SD/SSD               |
| **Windows Setup** | Yes              | Staged boot handoff | `setup.exe` from running Windows, or boot USB |

### Windows App Packages

| Format                     | Install logic                | Code at install?                              | Store?                                                                                                               | Best for                             |
| -------------------------- | ---------------------------- | --------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- | ------------------------------------ |
| **EXE** (NSIS, Inno, etc.) | Arbitrary installer code     | Yes — anything goes                           | No                                                                                                                   | Legacy, full system access           |
| **MSI**                    | Declarative + custom actions | Yes (custom actions can run DLLs/scripts)     | No                                                                                                                   | Enterprise/GPO deployment            |
| **MSIX**                   | Declarative, sandboxed       | No — file placement + registry virtualization | Yes ([required](https://learn.microsoft.com/en-us/windows/apps/package-and-deploy/choose-packaging-model) for Store) | Modern apps, clean install/uninstall |
| **Portable / xcopy**       | None                         | No                                            | No ([[scoop]]/[[winget]] can wrap)                                                                                   | CLI tools, single-binary utils       |
Some WinRT APIs require **[package identity](https://learn.microsoft.com/en-us/windows/apps/package-and-deploy/packaging/)**, from MSIX packaging or [packaging with external location (sparse packaging)](https://learn.microsoft.com/en-us/windows/apps/package-and-deploy/packaging/#packaging-with-external-location-sparse-packaging) which doesn't require restructuring the install.

### macOS App Packages

| Format                              | Install logic                                    | Code at install?                                      | Best for                                             |
| ----------------------------------- | ------------------------------------------------ | ----------------------------------------------------- | ---------------------------------------------------- |
| **`.app` bundle** (in DMG or ZIP)   | Drag-and-drop to `/Applications`                 | No                                                    | Simple apps, Homebrew casks                          |
| **`.pkg`**                          | Guided installer wizard                          | Yes (pre/post-install scripts, admin privileges)      | System extensions, drivers, multi-component installs |
| **DMG**                             | Mountable disk image containing `.app` or `.pkg` | No (just a container)                                 | Distribution wrapper                                 |
| **[[brew\|Homebrew]] formula/cask** | Declarative Ruby DSL                             | Build-from-source (formula) or download binary (cask) | CLI tools and desktop apps                           |

### Linux Distro Packages

See [[linux#Families with packaging]] for the full distro family tree.

| Format                 | Distro                                 | File payload                                       | Install-time scripts?                                                                                                                                       | Notes                                                                                                                                    |
| ---------------------- | -------------------------------------- | -------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| **DEB** (`.deb`)       | Debian, Ubuntu, Mint, Kali, Termux     | Declarative file archive                           | Yes — `preinst`/`postinst`/`prerm`/`postrm` shell scripts run as root ([Debian Policy](https://www.debian.org/doc/debian-policy/ch-maintainerscripts.html)) | `apt install` = download + unpack + run scripts                                                                                          |
| **RPM** (`.rpm`)       | RHEL, Fedora, CentOS, openSUSE, Oracle | Declarative file archive                           | Yes — `%pre`/`%post`/`%preun`/`%postun` scriptlets run as root                                                                                              | `dnf install` = same pattern                                                                                                             |
| **PKGBUILD**           | Arch, Manjaro, AUR                     | Shell script that builds from source               | Yes — `package()` runs arbitrary shell; `install` file has hook scripts                                                                                     | Build runs in `makepkg` without a sandbox; `yay`/`paru` build as user                                                                    |
| **ebuild**             | Gentoo                                 | Shell script (Portage DSL)                         | Yes — `src_compile`/`src_install`/`pkg_postinst` run arbitrary code                                                                                         | Runs at install time; no network sandbox by default                                                                                      |
| **XBPS** (`.xbps`)     | Void Linux                             | Binary archive                                     | Yes — `INSTALL`/`REMOVE` hook scripts                                                                                                                       | `xbps-install` = same pattern                                                                                                            |
| **Slackware package**  | Slackware                              | `tgz`/`txz` archive + `install/doinst.sh`          | Yes — `doinst.sh` shell script runs as root                                                                                                                 | Minimal tooling; very explicit                                                                                                           |
| **[[Nix]] derivation** | NixOS + any Linux/macOS                | Declarative recipe, content-addressed `/nix/store` | Build-time only; **sandboxed** — no network access, no host filesystem                                                                                      | Build is isolated (network blocked by default), where `builder` script runs arbitrary code within the sandbox. Analogous to Docker `RUN` |
### Mobile

| Format            | Install logic                                      | Code at install?                                                                                                           | Store?                            | Notes                                           |
| ----------------- | -------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- | --------------------------------- | ----------------------------------------------- |
| **APK** (Android) | Single archive, all device configs                 | No (but has [manifest-declared](https://developer.android.com/guide/topics/manifest/manifest-intro) receivers/permissions) | Sideload or third-party stores    | Self-contained; includes all ABIs/densities     |
| **AAB** (Android) | Publishing format → Play generates per-device APKs | No                                                                                                                         | Google Play (required since 2021) | Smaller downloads; Google holds signing key     |
| **IPA** (iOS)     | Signed app bundle                                  | No                                                                                                                         | App Store (required)              | Code signing + App Review gatekeep distribution |

### Language Package Managers

| Format                        | Ecosystem  | Code at install?                                                                   | OS-specific binaries?                                                                                                                                                                                                                                                                         |
| ----------------------------- | ---------- | ---------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **wheel** (`.whl`)            | Python/pip | No — [unpack + metadata + entry-point scripts](https://peps.python.org/pep-0427/)  | Yes: [filename encodes](https://packaging.python.org/en/latest/specifications/binary-distribution-format/) `{python}-{abi}-{platform}` per wheel. pip picks the right one.                                                                                                                    |
| **sdist** / legacy `setup.py` | Python/pip | Yes — `setup.py install` runs arbitrary code                                       | Built locally from source                                                                                                                                                                                                                                                                     |
| **npm package** (tarball)     | Node/npm   | `preinstall`/`postinstall` scripts *can* run code, but `--ignore-scripts` disables | Via [`optionalDependencies` + `os`/`cpu` fields](https://github.com/evanw/esbuild/pull/1621): main package lists per-platform packages (e.g. `@esbuild/darwin-arm64`), npm installs only the matching one. Legacy packages used `postinstall` to download/compile native binaries (node-gyp). |
| **Go module**                 | Go         | No — build from source, produces static binary                                     | Cross-compile at build time (`GOOS`/`GOARCH`); distribute single binary per platform                                                                                                                                                                                                          |
| **NuGet** (`.nupkg`)          | .NET       | No — unpack DLL + MSBuild integration                                              | [Runtime identifier (RID)](https://learn.microsoft.com/en-us/dotnet/core/rid-catalog) selects platform-specific assets                                                                                                                                                                        |
| **Cargo crate**               | Rust       | `build.rs` can run code at build time                                              | Build from source; cross-compile or use [`cross`](https://github.com/cross-rs/cross)                                                                                                                                                                                                          |

### CLI Tool Version Managers

These don't define a *package format* — they manage downloading and switching pre-built binaries per project.
See [[package manager#Per-Project tool managers]] for full comparison.

### Plugins and Mods

| Host                       | Format                                                      | Install logic                                   | Notes                                                                                                                                                              |
| -------------------------- | ----------------------------------------------------------- | ----------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Chrome extensions**      | ZIP with `manifest.json` (MV3) → `.crx` (signed ZIP)        | No — declarative manifest, file placement       | Chrome Web Store signs and wraps; sideloading via `chrome://extensions` developer mode. See [[browser.plugin.dev]].                                                |
| **VS Code extensions**     | `.vsix` (ZIP with `package.json` + `extension.js`)          | No — file placement + activation events         | Marketplace or `code --install-extension`.                                                                                                                         |
| **Obsidian plugins**       | JS bundle + `manifest.json` in plugin folder                | No — loaded at runtime by Obsidian              | Community plugins via Obsidian's plugin browser. See [[obsidian.plugins]].                                                                                         |
| **Factorio mods**          | ZIP named `{name}_{version}` with `info.json` + Lua scripts | No — Lua scripts run in Factorio's sandbox      | [Mod portal](https://mods.factorio.com/) or manual drop in `mods/` folder.                                                                                         |
| **Fiddler Classic**        | .NET DLL in plugin folder                                   | No — DLL loaded via reflection                  | Must implement [Fiddler interfaces](https://www.telerik.com/fiddler/fiddler-classic/documentation/extend-fiddler/interfaces) (`IFiddlerExtension`, `IAutoTamper`). |
| **Power Query connectors** | `.mez` file (ZIP with section document `.pq` files)         | No — M language evaluated by Power Query engine | [Power Query SDK](https://learn.microsoft.com/en-us/power-query/install-sdk) for development; load via gateway or Power BI Desktop.                                |

See [[lang.plugin]] for the underlying mechanisms (embedded runtime, dynamic loading, IPC, executable prefix) and [[lang.plugin.dev]] for the dev loop.

### Container and VM Images

| Format | Install logic | Code at install? | Notes |
|---|---|---|---|
| **OCI / Docker image** | Layer-based filesystem overlay | Dockerfile `RUN` executes at *build* time, not install time | `docker pull` is pure download; `docker run` is launch |
| **VM image** (AMI, VMDK, qcow2) | Block-level disk image | No — boot it | Cloud providers snapshot running VMs → images |

### Xcopy / Single-Binary Distribution

No installer, no package manager — just copy a file and run it.

| Tool/Language                   | How it works                                                                                                     |
| ------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| **Go**                          | `CGO_ENABLED=0 go build` → static binary, zero dependencies.                                                     |
| **Rust**                        | `cargo build --release` → static binary (with musl).                                                             |
| **Deno**                        | [`deno compile`](https://deno.land/manual/tools/compiler) → single binary embedding V8 + script.                 |
| **Python (PyInstaller/Nuitka)** | Bundles interpreter + deps into one executable. Large, but xcopy-deployable.                                     |

---

## Key Patterns

**Build-time vs install-time code execution** is the Python packaging story in miniature: legacy `setup.py` ran arbitrary code at install time; modern wheels move all logic to build time ([PEP 517](https://peps.python.org/pep-0517/) build backends), and install is just "unpack + place files." The same shift appears across platforms — MSIX over MSI, AAB over raw APK assembly, Docker images over shell-script installers.

**OS-specific binary distribution** has three main strategies:
1. **Filename convention** — pip wheels encode `{python}-{abi}-{platform}` in the filename; the installer picks the right one
2. **Optional sub-packages** — npm `optionalDependencies` with `os`/`cpu` fields; the package manager installs only the matching variant
3. **Cross-compilation at build time** — Go/Rust produce one binary per target; distribute via GitHub releases or package managers
	1. [ ] not sure this is really a strategy like the others

**Plugin formats almost never run install-time code.** The host app defines the sandbox; the plugin is data (code + manifest) loaded at runtime. Security comes from the host's sandbox, not from the install process. The main exception is legacy npm `postinstall` scripts, which modern tools actively avoid.
