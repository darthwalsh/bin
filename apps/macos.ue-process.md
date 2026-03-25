#ai-slop

# Process stuck in UE state: why `kill -9` doesn't work

A process in `UE` state has already received `SIGKILL` — it **wants** to die, but the kernel won't let it finish exiting. Signals are only delivered when a thread returns from kernel-space; if the thread is stuck waiting on a kernel resource, the signal is pending indefinitely.

```
U = uninterruptible sleep (waiting in kernel)
E = exiting flag set
```

The `E` flag means `kill -9` already worked — the process is marked for death. The `U` flag is why it hasn't died yet.
There is no user-space command that can forcibly free a process from kernel uninterruptible sleep. The kernel owns that wait.

## Find all stuck processes

```bash
ps -axo pid,ppid,state,etime,command | awk '$3 ~ /U/ && $3 ~ /E/'
```

## Causes (with minimal diagnostic)

### 1. dyld startup crash (library mismatch)

The process aborted during dynamic linker setup — before `main()` ran. Can be caused by a broken Homebrew reinstall leaving mismatched `.dylib` versions.

**Diagnostic:** `sample <pid> 1 1 -mayDie` — look for `dyld4::prepare`, `dyld4::halt`, `abort_with_payload` in the stack. Also check `lsof -p <pid>` for mismatched library paths (e.g. `rust/1.92.0.reinstall` loading `llvm/22.1.1.reinstall`).

**Fix:** Nothing to do for the stuck PID — it's already dead. Fix the underlying binary (`brew reinstall <formula>`). The ghost process clears on reboot.

### 2. exec-time security assessment stall (`syspolicyd` / `amfid`)

macOS runs every new exec through a security assessment chain (`amfid` → `syspolicyd` → trust services). If `syspolicyd` gets wedged, every new process launch hangs at the kernel's `mac_vnode_check_exec` hook — before any user code runs.

**Diagnostic:** `sample <pid> 1 1 -mayDie` — look for `mac_vnode_check_exec`, `vnode`, `kauth`, `ubc` in the stack. Also check `syspolicyd` CPU time: `ps -p 701 -o pid,etime,pcpu,command` — high CPU time (25+ minutes) is a red flag.

**Fix:**
```bash
sudo killall syspolicyd          # macOS auto-restarts it
```

### 3. Endpoint security extension blocking exec (CyberArk / CrowdStrike / Defender)

Endpoint security extensions hook `execve` at the kernel level. If one stalls (policy lookup timeout, backend unreachable), every exec on the machine hangs waiting for the extension to respond.

**Diagnostic:** Check active extensions: `systemextensionsctl list | grep -i 'cyberark\|crowdstrike\|defender'`. Check extension CPU time: `ps aux | grep -i 'cyberark\|falcon\|wdav'`. Watch live: `log stream --predicate 'eventMessage CONTAINS[c] "CyberArk"' --info`.

**Note:** `CyberArkEPM -fileInfo /path/to/binary` shows what EPM sees (hashes, publisher, TeamID). It does **not** show `com.apple.provenance` — that's a filesystem xattr, not part of file contents or hash.

**Fix:** Contact your security team. You can't unload system extensions without admin rights. Restarting `syspolicyd` sometimes unblocks it; reboot is the guaranteed fix.

### 4. `com.apple.provenance` / `com.apple.quarantine` xattr
`com.apple.provenance` vs `com.apple.quarantine`: provenance is filesystem metadata.

macOS attaches these xattrs to files downloaded from external sources. They trigger extra assessment during exec. A stuck `syspolicyd` + provenance xattr = process never exits the assessment path.


**Diagnostic:**
```bash
xattr -l /path/to/binary
```

**Fix (only if you trust the binary):**
```bash
sudo xattr -d com.apple.provenance /path/to/binary
sudo xattr -d com.apple.quarantine /path/to/binary
```

**Gotcha:** `spctl --assess --type execute` is a poor diagnostic for CLI tools. It rejects Homebrew binaries (`brew`, `npm`, `timeout`) even though they run fine — because `spctl` is designed for notarized `.app` bundles, not ad-hoc signed executables. A `rejected` result from `spctl` on a bare binary is **normal**, not evidence of a problem.

### 5. Filesystem / network mount stall

Process is waiting on I/O from a hung NFS/SMB/sshfs/WebDAV mount.

**Diagnostic:** `lsof -p <pid>` — look for `/Volumes/`, `nfs`, `smb`, `afp`, `sshfs` in the NAME column. `df <cwd>` to check if the working directory is on a remote mount.

**Fix:** Unmount the stale volume (`diskutil unmount force /Volumes/...`), or disconnect/reconnect the network share.

### 6. Zombie (state `Z`, not `UE`)

The process is already fully dead — it's just waiting for its parent to call `wait()` to reap it. Not the same as `UE`, but often confused with it.

**Diagnostic:** `ps -o pid,ppid,state,command -p <pid>` — state `Z` confirms zombie.

**Fix:** Kill or restart the parent process (shown in `ppid`).

## What actually clears UE processes

| Option | Notes |
|---|---|
| Wait | Sometimes the kernel reaps it eventually |
| `sudo killall syspolicyd` | Frees processes stuck in exec assessment |
| Fix the underlying binary | Prevents new instances from getting stuck |
| Reboot | Guaranteed — clears all kernel waits |

