#!/usr/bin/env uv run
"""Trace PATH env var through parent process chain for a given PID #ai-slop"""

import ctypes
import ctypes.util
import struct
import sys
import psutil

# /// script
# dependencies = [
#     "psutil",
# ]
# ///

CTL_KERN = 1
KERN_PROCARGS2 = 49


def _macos_proc_env(pid: int) -> dict[str, str]:
    """Read process environment via KERN_PROCARGS2 sysctl (macOS only)."""
    libc = ctypes.CDLL(ctypes.util.find_library("c"), use_errno=True)

    # First call: get required buffer size
    size = ctypes.c_size_t(0)
    mib = (ctypes.c_int * 3)(CTL_KERN, KERN_PROCARGS2, pid)
    ret = libc.sysctl(mib, 3, None, ctypes.byref(size), None, 0)
    if ret != 0:
        return {}

    buf = ctypes.create_string_buffer(size.value)
    ret = libc.sysctl(mib, 3, buf, ctypes.byref(size), None, 0)
    if ret != 0:
        return {}

    data = buf.raw[: size.value]
    # Layout: int argc, exec_path\0[padding], argv[0..argc-1], envp...
    argc = struct.unpack_from("<i", data, 0)[0]
    pos = 4
    # Skip exec_path (null-terminated)
    pos = data.index(b"\x00", pos) + 1
    # Skip null padding between exec_path and argv
    while pos < len(data) and data[pos] == 0:
        pos += 1
    # Skip argv strings
    for _ in range(argc):
        end = data.find(b"\x00", pos)
        if end == -1:
            break
        pos = end + 1
    # Parse env KEY=VALUE\0 pairs
    env: dict[str, str] = {}
    while pos < len(data):
        end = data.find(b"\x00", pos)
        if end == -1 or end == pos:
            break
        entry = data[pos:end].decode("utf-8", errors="replace")
        if "=" in entry:
            k, v = entry.split("=", 1)
            env[k] = v
        pos = end + 1
    return env


def truncate(s, n=200):
    return s if len(s) <= n else s[:n] + "..."


def get_env(proc: psutil.Process) -> tuple[dict[str, str], str]:
    """Return (env_dict, source) where source indicates how it was read."""
    try:
        env = proc.environ()
        if env:
            return env, "psutil"
    except (psutil.AccessDenied, psutil.ZombieProcess) as e:
        print("ignoring known", e)
        pass
    except Exception as e:
        print("unknown", e)
        pass

    if sys.platform == "darwin":
        env = _macos_proc_env(proc.pid)
        if env:
            return env, "sysctl"
        else:
            print("_macos_proc_env returned empty")

    return {}, "unavailable"


def trace_path(pid: int):
    try:
        proc = psutil.Process(pid)
    except psutil.NoSuchProcess:
        print(f"No process with PID {pid}", file=sys.stderr)
        sys.exit(1)

    chain = []
    while proc is not None:
        env, source = get_env(proc)
        if env:
            path = env.get("PATH", "<not set>")
        else:
            path = "<unavailable>"

        try:
            name = proc.name()
            cmdline = " ".join(proc.cmdline())
        except (psutil.AccessDenied, psutil.ZombieProcess):
            name = "<access denied>"
            cmdline = ""

        chain.append((proc.pid, name, cmdline, path))

        try:
            parent = proc.parent()
        except (psutil.AccessDenied, psutil.NoSuchProcess):
            break
        proc = parent

    # Print from root (oldest ancestor) down to target
    chain.reverse()
    prev_path = None
    for pid, name, cmdline, path in chain:
        changed = path != prev_path
        marker = "* CHANGED" if (changed and prev_path is not None) else ""
        print(f"\nPID {pid}  [{name}]  {marker}")
        if cmdline:
            print(f"  cmd: {truncate(cmdline)}")
        if changed:
            print(f"  PATH: {truncate(path)}")
        else:
            print(f"  PATH: (same as parent)")
        prev_path = path


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <pid>")
        sys.exit(1)
    trace_path(int(sys.argv[1]))
