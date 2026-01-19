#! /usr/bin/env python3
"""
Question: can we mirror the bash example (process substitution + string replace + fd 5)
           using a mix of in-process stages and subprocess cat, runnable as `./a.py 5>&1`?
"""

import os
import subprocess
import sys
import threading
from typing import Callable, List, Union

PIPE_OUT = object()


def stage_3_replace(stdin, stdout):
    """String replacement: proc sub -> PROCESS SUBSTITUTION."""
    for line in stdin:
        stdout.write(line.replace("proc sub", "PROCESS SUBSTITUTION"))
    stdout.flush()


def stage_1_ignore(_stdin, stdout):
    """Upstream stage whose output is ignored by downstream (mirrors `echo "#1 ignored"`)."""
    stdout.write("#1 ignored\n")
    stdout.flush()
    # Thought it would raise BrokenPipeError, but for some reason it didn't

class Command:
    def __init__(self, fd_map: List[tuple[int, int]] | None = None):
        """
        fd_map: list of (child_fd, parent_fd) to dup2 before exec/run.
        Common use: [(0, tmp_fd), (3, 1), (1, 5)].
        """
        self.fd_map = fd_map or []

    def start(self, stdin_fd: int, stdout_fd: int) -> Callable[[], None]:
        raise NotImplementedError


class SubprocessCommand(Command):
    def __init__(self, argv: List[str], fd_map: List[tuple[int, int]] | None = None):
        super().__init__(fd_map)
        self.argv = argv

    def start(self, stdin_fd: int, stdout_fd: int) -> Callable[[], None]:
        preexec = None
        pass_fds = ()
        duped = ()
        if self.fd_map:
            # dup sources so we own them
            duped = [(t, os.dup(s)) for (t, s) in self.fd_map]

            def _dup_all():
                for target, src in duped:
                    os.dup2(src, target)

            preexec = _dup_all
            pass_fds = tuple(src for _, src in duped) + tuple(t for t, _ in duped)

        proc = subprocess.Popen(
            self.argv,
            stdin=stdin_fd,
            stdout=stdout_fd,
            pass_fds=pass_fds,
            preexec_fn=preexec,
            close_fds=True,
        )
        os.close(stdin_fd)
        os.close(stdout_fd)
        # Close our duped sources so downstream sees EOF when child exits.
        for _, src in duped:
            try:
                os.close(src)
            except OSError:
                pass
        return proc.wait


class ThreadCommand(Command):
    def __init__(self, fn: Callable, fd_map: List[tuple[int, int]] | None = None):
        super().__init__(fd_map)
        self.fn = fn

    def start(self, stdin_fd: int, stdout_fd: int) -> Callable[[], None]:
        def runner():
            with os.fdopen(stdin_fd, "r", closefd=True) as r, os.fdopen(
                stdout_fd, "w", closefd=True
            ) as w:
                self.fn(r, w)

        t = threading.Thread(target=runner, daemon=True)
        t.start()
        return t.join


def run_pipeline(*cmds: Command) -> None:
    """Wire cmds left-to-right with pipes; defaults to parent stdin/stdout."""
    default_stdin_fd = os.dup(0)
    default_stdout_fd = os.dup(1)

    waiters: List[Callable[[], None]] = []
    prev_read: Union[int, None] = None

    for i, cmd in enumerate(cmds):
        is_last = i == len(cmds) - 1
        if not is_last:
            read_fd, write_fd = os.pipe()
        else:
            read_fd, write_fd = None, None

        # Resolve fd_map, allowing PIPE_OUT to refer to this stage's pipe write end.
        resolved_map = []
        for child_fd, parent_fd in cmd.fd_map:
            actual_parent = write_fd if parent_fd is PIPE_OUT else parent_fd
            resolved_map.append((child_fd, actual_parent))

        # Check fd_map overrides for 0/1; fallback to pipeline defaults.
        fd_overrides = {c: p for (c, p) in resolved_map if c in (0, 1) and p is not None}
        if 0 in fd_overrides:
            in_fd = os.dup(fd_overrides[0])
        else:
            in_fd = os.dup(prev_read) if prev_read is not None else os.dup(default_stdin_fd)

        if 1 in fd_overrides:
            out_fd = os.dup(fd_overrides[1])
        else:
            out_fd = os.dup(default_stdout_fd) if is_last else os.dup(write_fd)

        # Temporarily use resolved_map for this start.
        orig_map = cmd.fd_map
        cmd.fd_map = resolved_map
        waiters.append(cmd.start(in_fd, out_fd))
        cmd.fd_map = orig_map

        if prev_read is not None:
            os.close(prev_read)
        if not is_last and write_fd is not None:
            os.close(write_fd)
        prev_read = read_fd if not is_last else None

    for wait in waiters:
        wait()

    # Close defaults we duped
    os.close(default_stdin_fd)
    os.close(default_stdout_fd)


def main_5():
    # Temp file producer (echo ... > /tmp/_proc equivalent)
    tmp_fd = os.open("/tmp/_proc_py", os.O_RDWR | os.O_CREAT | os.O_TRUNC, 0o600)
    os.write(tmp_fd, b"#2 proc sub\n")
    os.lseek(tmp_fd, 0, os.SEEK_SET)

    run_pipeline(
        ThreadCommand(stage_1_ignore),
        SubprocessCommand(["bash", "-c", "cat >&3"], fd_map=[(0, tmp_fd), (3, PIPE_OUT)]),
        ThreadCommand(stage_3_replace),
        SubprocessCommand(["cat"], fd_map=[(1, 5)]),
    )
    try:
        os.close(tmp_fd)
    except OSError:
        pass


def main_cat():
    """Runs pipeline `cat | cat` to ensure pipeline stdin/stdout default is correct"""
    run_pipeline(
        SubprocessCommand(["cat"]),
        SubprocessCommand(["cat"]),
    )

if __name__ == "__main__":
    if sys.argv[1] == "5":
        main_5()
    elif sys.argv[1] == "cat":
        main_cat()
    else:
        raise ValueError(f"Invalid argument: {sys.argv[1]}")
