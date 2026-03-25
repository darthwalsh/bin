#ai-slop

# UAC & Administrator Protection

## UAC is defense-in-depth, not a security boundary

[User Account Control](https://learn.microsoft.com/en-us/windows/security/application-security/application-control/user-account-control/architecture) separates a logged-in admin's session into two tokens: a standard-user token (used by default) and a full admin token (used only when elevated). The goal is to reduce the blast radius of running as admin all the time.

Key design facts:
- Microsoft [explicitly stated](https://techcommunity.microsoft.com/blog/microsoft-security-blog/evolving-the-windows-user-model-%E2%80%93-a-look-to-the-past/4369642) UAC is "a security feature but not a security boundary" — UAC bypass reports were not treated as boundary violations
- UAC prompts can appear on the **secure desktop** (default) or the interactive desktop (configurable via policy); only the secure desktop version is tamper-resistant
- [Policy knobs](https://learn.microsoft.com/en-us/windows/security/application-security/application-control/user-account-control/settings-and-configuration): consent vs credential prompts, secure desktop on/off, "run all admins in Admin Approval Mode"

## The split-token model and how elevation works

When an admin logs in under classic UAC, Windows creates two tokens for the same user account:

- **Filtered token** (standard user) — used for the shell and most processes
- **Full admin token** — held in reserve; granted when the user approves a UAC prompt

Requesting elevation via [`ShellExecute(..., "runas", ...)`](https://learn.microsoft.com/en-us/windows/win32/api/shellapi/nf-shellapi-shellexecutea) triggers a UAC consent/credential prompt, then launches the new process with the full admin token. The elevated and unelevated processes share the same `%USERPROFILE%` and `HKCU` registry hive.

## Classic UAC sharp edges

Windows 7 introduced **auto-elevation** for OS-signed binaries with an `autoElevate` manifest flag. This created well-known bypass classes:

- **DLL/PATH hijacking**: trick an auto-elevating system binary into loading an attacker-controlled DLL (first on PATH), which runs elevated without any prompt
- **COM interface abuse**: auto-elevating COM interfaces (e.g., `IFileOperation`) could be called from a medium-integrity process to perform privileged file operations silently
- **Registry/env-var manipulation**: shared `HKCU` and user-writable environment variables (e.g., the `SilentCleanup` scheduled task bypass) let a medium-integrity process influence what an elevated process loads or executes

These worked because the elevated process shared per-user state with the unelevated process, and some elevation paths required no user interaction.

## Administrator Protection: UAC re-architected as a real boundary

[Administrator Protection](https://learn.microsoft.com/en-us/windows/security/application-security/application-control/administrator-protection/) (Windows 11, in preview as of early 2026) is explicitly positioned as a **security boundary** — meaning Microsoft will service reported bypasses. The architecture changes:

- **No auto-elevation**: every admin operation requires explicit interactive authorization (Windows Hello or credential prompt)
- **Just-in-time (JIT) admin token**: created only for the elevated process, discarded afterward — not a persistent split token
- **Profile separation via SMAA** (System-Managed Admin Account): the elevated process runs under a separate hidden account with a different SID, different `%USERPROFILE%`, and a different `HKCU` hive

This directly breaks the classic bypass classes: there's no shared per-user state to manipulate, and no silent elevation paths.

> Rollout note: As of Jan 2026, AP was [disabled in retail and Insider channels](https://blogs.windows.com/windowsdeveloper/2025/05/19/enhance-your-application-security-with-administrator-protection/) due to a reliability issue. The design is documented; the shipping date is not stable.

## Developer implications: what breaks under AP

If an app uses `ShellExecute("runas")` or `requireAdministrator` manifest:

- `%USERPROFILE%`, user libraries, and `HKCU` for the elevated process map to the **SMAA profile**, not the real user's profile — files saved there won't be visible to the unelevated process
- Per-user app config (themes, settings) may diverge between elevated and unelevated runs
- Any design that writes state from an elevated process and expects the unelevated process to read it (or vice versa) breaks

Recommended pattern — **two-process with IPC**:
1. Keep an unelevated "launcher" process running as the real user
2. Spawn an elevated helper only when needed; pass results back via IPC
3. Exit the helper when done — don't try to "de-elevate" the running process

De-elevation (dropping privileges in-process) has no clean Windows primitive. [`CreateRestrictedToken`](https://learn.microsoft.com/en-us/windows/win32/api/securitybaseapi/nf-securitybaseapi-createrestrictedtoken) can create a less-privileged child, but under AP the elevated process is already running as SMAA — restricting that token keeps you as SMAA, not the original user.

## What AP does not fix: admin → SYSTEM

AP changes how you *get* admin (JIT token, explicit auth, profile separation). It does not reduce what an approved elevated process can do. Admin can still:
- Install services, scheduled tasks, drivers
- Modify security settings
- Typically escalate to SYSTEM via service/task tricks

The meaningful improvement is that **a medium-integrity foothold can no longer silently self-elevate** via UAC quirks. If the user approves elevation for malware, or an attacker already controls an elevated process, the system is still compromised.

## Task Scheduler and sudo under AP

**Task Scheduler**: Microsoft [guidance](https://learn.microsoft.com/en-us/windows/security/application-security/application-control/administrator-protection/) says to stop depending on an "always-available" admin token for scheduled tasks — use SYSTEM or a dedicated service account instead. AP's profile separation also mitigates classic Task Scheduler UAC bypasses (e.g., `SilentCleanup`) that relied on user-writable registry/env-var state.

**[sudo for Windows](https://learn.microsoft.com/en-us/windows/sudo/)** ([source](https://github.com/microsoft/sudo)): runs a single command elevated from an unelevated console session. Under AP, that elevated command would likely run in the SMAA context (different profile/hive) — this specific interaction is not stated verbatim in the sudo docs, so treat it as an implementation-consistent inference.

**RDP**: AP explicitly [excludes remote logon from scope](https://learn.microsoft.com/en-us/windows/security/application-security/application-control/administrator-protection/). Behavior of elevated Explorer.exe over RDP under AP is undocumented.
