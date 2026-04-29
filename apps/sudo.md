# sudo: privilege elevation
On both Linux and macOS, `sudo` changes the security identity (UID/GID/capabilities) of a process.
Separate from the CPU's *execution mode* (user vs [[kernel-mode]]). 
## sudo on Linux
[`sudo`](https://www.sudo.ws/) authenticates against sudoers rules (or [PAM](https://www.chiark.greenend.org.uk/doc/libpam-doc/html/adg-introduction-description.html)), then execs the target command **as a different UID**.

Privilege granularity options on Linux (coarsest → finest):
- **Full root via `sudo`** — setuid-root binary, authenticates, execs as UID 0
- **`su <user>`** — switch to any user (requires that user's password by default)
- **`setuid`/`setgid` binaries** — file-level capability grant; any user who executes the binary gets its owner's UID for that invocation (e.g., `passwd`, `ping`)
- **[Linux capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html)** — split "root powers" into discrete units; grant only `CAP_NET_ADMIN` or `CAP_SYS_MODULE` without full root. Assigned per-file (`setcap`) or per-process at exec.
- **[polkit](https://github.com/polkit-org/polkit)** (formerly PolicyKit) — desktop-friendly authorization daemon; apps request specific actions, user gets a GUI prompt. Used by NetworkManager, PackageKit, etc.

## sudo on macOS
macOS ships the same `sudo` binary (BSD-heritage, configured via `/etc/sudoers`). The behavior is identical.

macOS-specific additions:
- **[Authorization Services](https://developer.apple.com/documentation/security/authorization-services)** — the macOS analogue of polkit. Sandboxed apps and GUI helpers request named rights (e.g., `system.install.apple-software`); `authd` presents the authentication dialog.
- **[[mac.sip|System Integrity Protection (SIP)]]** — even root cannot modify `/System`, `/usr`, or kernel extensions without disabling SIP at boot. This is enforced by the kernel regardless of UID. It is not a user-mode privilege level — it is a boot-time policy that limits what root can do.

## Cross-OS analogy

| Concept                        | Linux                   | macOS                               | Windows                                      |
| ------------------------------ | ----------------------- | ----------------------------------- | -------------------------------------------- |
| Elevated identity              | UID 0 (root)            | UID 0 (root)                        | Full admin token (UAC) — see [[windows.uac]] |
| Standard identity              | Regular UID             | Regular UID                         | Filtered token                               |
| Interactive elevation prompt   | PAM/terminal password   | Authorization Services dialog       | UAC consent/credential prompt                |
| Fine-grained without full root | Capabilities (`setcap`) | Entitlements + Authorization rights | Privileges in access token                   |
| Policy above root              | —                       | SIP (boot-enforced)                 | —                                            |
| Switching to arbitrary user    | `su <user>`             | `su <user>`                         | `runas /user:<user>`                         |
