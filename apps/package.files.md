#ai-slop
# What an Installed App Leaves on Disk

Scope: the *result* of installation — the files, registry keys, and drivers that exist on disk afterward, and which manifest declares what. For *how* the bytes get copied (xcopy vs scripted installer vs boot-and-configure) see [[package.install]].

## Two halves: file payload + system registration

Installing a desktop app does two separate things: (1) drop a **payload** of files somewhere, and (2) **register** those files so the OS knows the app exists. Platforms differ in how they split these:

- **macOS** folds both into one artifact: a self-describing `.app` bundle in a known location. The manifest inside is the registration.
- **Windows** splits them: files go to `Program Files`, but the registration lives in the [[registry]], written separately by the installer.
- **Linux** uses a small `.desktop` file as the registration, separate from the payload.

## Desktop Environment in userspace

The kernel only exposes a filesystem and `exec`; it has no concept of an "installed application." Whether a directory shows as a plain folder or a single clickable app icon is decided by **userspace** — the file manager and desktop environment (Finder, Explorer, GNOME). So "is this an app?" is answered by a userspace *convention* (a `.app` extension, a registry entry, a `.desktop` file), never by the kernel.

## macOS: the .app bundle is just a directory

A `.app` is an ordinary directory; Finder renders it as one app icon only because the name ends in `.app`. From a shell it behaves like a folder — you can `cd` into it, and `exec`-ing it fails (it points at a directory, not a binary). `open Foo.app` works because `open` reads the manifest to find the real executable, then launches that.

### Bundle layout: MacOS/, Resources/, Frameworks/

Inside the bundle, everything lives under `Contents/`:

- `Contents/MacOS/` — the actual executable(s)
- `Contents/Resources/` — icons (`.icns`), images, and localizations (`.lproj` folders)
- `Contents/Frameworks/` — bundled dylibs and frameworks (**this is where your libraries belong**)
- `Contents/PlugIns/`, `Contents/Helpers/` — optional components
- `Contents/Info.plist` — the manifest (below)

### Info.plist declares executable, icon, file types, version

[`Info.plist`](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/AboutInformationPropertyListFiles.html) (XML or binary plist) is the single file the OS reads to understand the app. Packager-relevant keys:

- `CFBundleExecutable` — which file in `MacOS/` to run
- `CFBundleIconFile` — the `.icns` in `Resources/` Finder shows
- `CFBundleIdentifier`, `CFBundleShortVersionString` / `CFBundleVersion`
- `CFBundleDocumentTypes` — file types the app opens (file associations)

Permissions/capabilities are **not** in `Info.plist` — they live in [entitlements](https://developer.apple.com/documentation/bundleresources/entitlements) embedded in the code signature. See [[app-signing]].

### Bundles must live in /Applications or ~/Applications

macOS only scans a few known directories for discoverability (Launchpad, Spotlight) rather than crawling the whole disk: `/Applications` (all users) and `~/Applications` (per user). Unlike Windows, you can't freely relocate an app and expect the system to track it.

### Mac App Store: sandboxed .app + _MASReceipt

A Mac App Store app is the same `.app` dragged into `/Applications`, with two additions: it is mandatorily [sandboxed](https://developer.apple.com/documentation/security/app-sandbox) (via entitlement), and it carries `Contents/_MASReceipt/receipt` — a signed purchase receipt the app validates at launch. No separate installer; the App Store app places the bundle.

### Drivers/anticheat: System Extensions + DriverKit (kexts deprecated)

Kernel extensions (`.kext`) are [deprecated since Big Sur](https://developer.apple.com/support/kernel-extensions/) and won't load by default. The modern result of installing a driver/anticheat/AV is a [System Extension or DriverKit](https://developer.apple.com/system-extensions/) component that runs in **userspace**, plus the [`EndpointSecurity`](https://developer.apple.com/documentation/endpointsecurity) API for monitoring. It ships inside the app bundle, is *activated* by the app, and the system installs the approved copy under `/Library/SystemExtensions`. Requires an Apple-granted entitlement. This is the opposite of the Windows kernel-driver model below.

## Windows: files in Program Files, state in the registry

Windows has no bundle concept — `Program Files` and `Program Files (x86)` (32-bit on 64-bit) just hold plain folders. Installing means: copy files into a per-app folder, write registration into the **registry**, and create shortcuts. That registry step is why Windows apps need installers in the first place.

### The EXE embeds its own icon + version metadata

The icon, version info, and other metadata are stored as [resources inside the `.exe`/`.dll`](https://learn.microsoft.com/en-us/windows/win32/menurc/resource-types) (`RT_GROUP_ICON`, `VERSIONINFO`). Explorer reads the embedded icon, so it travels with the file no matter where it's copied — no external manifest needed just to show an icon.

### Registry holds uninstall info, file associations, shortcuts, app paths

System integration lives in the registry rather than a per-app manifest file:

- **Uninstall** entry under `HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\<id>`
- **File associations / default programs** under `HKCR` (= `HKLM\Software\Classes`)
- **App Paths** under `...\CurrentVersion\App Paths\app.exe` (lets `app.exe` be found without a full path)
- **COM class registration by UUID**: a COM server (DLL/EXE) registers each class under `HKCR\CLSID\{GUID}`, with `InprocServer32` pointing at the DLL. The `{GUID}` is the stable identity — clients resolve a class by UUID, and the registry maps that UUID to the file on disk.

Start Menu / Desktop shortcuts are `.lnk` *files*, not registry entries.

### Kernel-mode drivers (.sys) registered as services (anticheat)

Anticheat (EAC, BattlEye, Vanguard) and similar low-level software install a kernel-mode driver `.sys` into `System32\drivers`, registered as a **service** under `HKLM\SYSTEM\CurrentControlSet\Services\<name>` and loaded by the Service Control Manager. The driver must be signed (WHQL/EV). This is the kernel-level model macOS deliberately moved away from.

### MSIX runs from a read-only container, not a normal unpack

An [MSIX](https://learn.microsoft.com/en-us/windows/msix/overview) install lays files into `C:\Program Files\WindowsApps\<PackageFullName>`, an ACL-protected **read-only** location — not a user-chosen folder. What lands there:

- `AppxManifest.xml` — declares package identity, entry point, visual elements/logo (the icon), capabilities, and file-type associations (the manifest does the job the registry does for classic apps)
- a `VFS\` folder — holds files that classic apps would have written to `Program Files`/`System32`
- a `registry.dat` hive — the package's registry keys, shipped as a file inside the package

Uninstall = delete the package directory. MSIX is [required for Microsoft Store](https://learn.microsoft.com/en-us/windows/apps/package-and-deploy/choose-packaging-model) distribution.

## Linux: the XDG desktop entry (.desktop) — concepts only

A Linux distro is one kernel plus a chosen userspace, so "installed app" is purely a userspace convention. Most desktops share the freedesktop.org [[xdg]] XDG desktop entry spec: a small `.desktop` file (in `/usr/share/applications` or `~/.local/share/applications`) declares `Name`, `Exec`, `Icon`, `MimeType`, and `Categories` — the Linux analog of `Info.plist`/registry for menu integration.

- [ ] PLACEHOLDER — Flatpak, Snap, AppImage, Docker and the broader distribution-format mess are deferred until the follow-up video. Only the desktop-entry concept above comes from this video.

## Cheat sheet: where libraries and icons belong per platform

| Platform            | Manifest          | Entry point                       | Icon                                  | Libraries                       | File associations         |
| ------------------- | ----------------- | --------------------------------- | ------------------------------------- | ------------------------------- | ------------------------- |
| **macOS**           | `Info.plist`      | `Contents/MacOS/` via `CFBundleExecutable` | `.icns` in `Resources/` (`CFBundleIconFile`) | `Contents/Frameworks/`          | `CFBundleDocumentTypes`   |
| **Windows classic** | none — registry   | `.exe` in `Program Files`         | embedded in `.exe` (`RT_GROUP_ICON`)  | DLLs beside `.exe` or `System32` | registry `HKCR\Classes`   |
| **Windows MSIX**    | `AppxManifest.xml`| declared in manifest              | logo asset referenced in manifest     | in package + `VFS\`             | manifest extension        |
| **Linux**           | `.desktop` entry  | `Exec=`                           | `Icon=` (theme dir)                   | system libs (`/usr/lib`)        | `MimeType=`               |
