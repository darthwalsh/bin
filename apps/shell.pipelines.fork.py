#! /usr/bin/env python3
"""
PoC: mirror the bash pipeline that mixes process substitution, a built-in, and
fd 5 redirection using a fork/exec pipeline model. See shell.pipelines.md

TODO: seems to work from cursor, but not from terminal. Getting error about fd 5
"""

from __future__ import annotations

import io
import os
import sys
from typing import Callable, Iterable, List, Sequence, Tuple

PIPE_OUT = object()


class Command:
    """Base command with optional child-fd to parent-fd remapping."""

    def __init__(self, fd_map: Iterable[tuple[int, int]] | None = None) -> None:
        self.fd_map = list(fd_map or [])


class BuiltinCommand(Command):
    """Runs a Python callable in a forked child with stdio already wired."""

    def __init__(self, fn: Callable[[], None], fd_map: Iterable[tuple[int, int]] | None = None) -> None:
        super().__init__(fd_map)
        self.fn = fn


class ExecCommand(Command):
    """Executes an external program via execv using an absolute path."""

    def __init__(
        self, path: str, argv: Sequence[str], fd_map: Iterable[tuple[int, int]] | None = None
    ) -> None:
        if not os.path.isabs(path):
            raise ValueError("exec path must be absolute for execv")
        super().__init__(fd_map)
        self.path = path
        self.argv = list(argv)


def _rebind_standard_streams() -> None:
    """Recreate text buffers so print()/input() use the freshly duped fds."""
    sys.stdin = io.TextIOWrapper(os.fdopen(0, "rb", closefd=False), encoding="utf-8", errors="replace")
    sys.stdout = io.TextIOWrapper(
        os.fdopen(1, "wb", closefd=False), encoding="utf-8", errors="replace", line_buffering=True
    )
    sys.stderr = io.TextIOWrapper(
        os.fdopen(2, "wb", closefd=False), encoding="utf-8", errors="replace", line_buffering=True
    )


def _wait_all(pids: List[int]) -> List[Tuple[int, int]]:
    statuses: List[Tuple[int, int]] = []
    for pid in pids:
        try:
            pid_ret, status = os.waitpid(pid, 0)
            if os.WIFEXITED(status):
                code = os.WEXITSTATUS(status)
            elif os.WIFSIGNALED(status):
                code = -os.WTERMSIG(status)
            else:
                code = status
            statuses.append((pid_ret, code))
        except ChildProcessError:
            statuses.append((pid, -1))
    return statuses


def run_pipeline(*cmds: Command) -> List[Tuple[int, int]]:
    """Wire commands left-to-right using os.pipe + fork + execv/run."""
    default_stdin = os.dup(0)
    default_stdout = os.dup(1)
    pids: List[int] = []
    prev_read: int | None = None

    for idx, cmd in enumerate(cmds):
        is_last = idx == len(cmds) - 1
        pipe_read: int | None = None
        pipe_write: int | None = None
        devnull_fd: int | None = None

        next_overrides_stdin = False
        if not is_last:
            next_cmd = cmds[idx + 1]
            next_overrides_stdin = any(
                child_fd == 0 and parent_fd not in (None, PIPE_OUT) for child_fd, parent_fd in next_cmd.fd_map
            )

        needs_pipe = any(parent_fd is PIPE_OUT for _, parent_fd in cmd.fd_map)

        if not is_last and (needs_pipe or not next_overrides_stdin):
            pipe_read, pipe_write = os.pipe()

        resolved_map: list[tuple[int, int | None]] = []
        for child_fd, parent_fd in cmd.fd_map:
            actual_parent = pipe_write if parent_fd is PIPE_OUT else parent_fd
            if actual_parent is PIPE_OUT:
                raise RuntimeError("PIPE_OUT requires a downstream pipe")
            resolved_map.append((child_fd, actual_parent))

        fd_overrides = {child_fd: parent_fd for child_fd, parent_fd in resolved_map if child_fd in (0, 1)}
        in_source = fd_overrides.get(0, prev_read if prev_read is not None else default_stdin)
        if pipe_write is None and not is_last and not fd_overrides.get(1):
            devnull_fd = os.open(os.devnull, os.O_WRONLY)
        out_source = fd_overrides.get(1, default_stdout if is_last else pipe_write or devnull_fd)

        if in_source is None or out_source is None:
            raise RuntimeError("stdin/stdout sources must be set before forking")

        in_fd = os.dup(in_source)
        out_fd = os.dup(out_source)

        # Ensure fds we intend to survive exec stay inheritable.
        for fd in (in_fd, out_fd):
            try:
                os.set_inheritable(fd, True)
            except OSError:
                pass
        for _, parent_fd in resolved_map:
            if parent_fd is None:
                continue
            try:
                os.set_inheritable(parent_fd, True)
            except OSError:
                pass

        pid = os.fork()
        if pid == 0:
            try:
                # Child: wire stdio
                os.dup2(in_fd, 0)
                os.dup2(out_fd, 1)

                for child_fd, parent_fd in resolved_map:
                    if child_fd in (0, 1) or parent_fd is None:
                        continue
                    os.dup2(parent_fd, child_fd)

                # Close extra fds we inherited or duplicated.
                close_candidates = {
                    in_fd,
                    out_fd,
                    prev_read,
                    pipe_read,
                    pipe_write,
                    devnull_fd,
                    default_stdin,
                    default_stdout,
                }
                close_candidates.update(
                    {
                        parent_fd
                        for child_fd, parent_fd in resolved_map
                        if parent_fd is not None and parent_fd != child_fd
                    }
                )
                for fd in close_candidates:
                    if fd is None:
                        continue
                    try:
                        os.close(fd)
                    except OSError:
                        pass

                if isinstance(cmd, BuiltinCommand):
                    _rebind_standard_streams()
                    try:
                        cmd.fn()
                        os._exit(0)
                    except SystemExit as se:
                        code = se.code if isinstance(se.code, int) else 1
                        os._exit(code)
                    except Exception:
                        import traceback

                        traceback.print_exc(file=sys.stderr)
                        os._exit(1)
                elif isinstance(cmd, ExecCommand):
                    os.execv(cmd.path, cmd.argv)
                    os._exit(127)
                else:
                    os._exit(99)
            except Exception:
                import traceback

                traceback.print_exc(file=sys.stderr)
                os._exit(1)
        else:
            pids.append(pid)
            for fd in (in_fd, out_fd):
                try:
                    os.close(fd)
                except OSError:
                    pass
            if prev_read is not None:
                try:
                    os.close(prev_read)
                except OSError:
                    pass
            if pipe_write is not None:
                try:
                    os.close(pipe_write)
                except OSError:
                    pass
            if devnull_fd is not None:
                try:
                    os.close(devnull_fd)
                except OSError:
                    pass
            prev_read = pipe_read

    if prev_read is not None:
        try:
            os.close(prev_read)
        except OSError:
            pass

    try:
        os.close(default_stdin)
    except OSError:
        pass
    try:
        os.close(default_stdout)
    except OSError:
        pass

    return _wait_all(pids)


def stage_1_ignore() -> None:
    """Produce text that will be ignored downstream."""
    try:
        sys.stdout.write("#1 ignored\n")
        sys.stdout.flush()
    except BrokenPipeError:
        # Downstream intentionally ignored this producer.
        pass


def stage_3_replace() -> None:
    """Replace 'proc sub' with uppercase variant."""
    for line in sys.stdin:
        sys.stdout.write(line.replace("proc sub", "PROCESS SUBSTITUTION"))
    sys.stdout.flush()


def main_proc_sub() -> List[Tuple[int, int]]:
    """Replicate the bash pipeline including fd 5 redirection."""
    tmp_fd = os.open("/tmp/_proc_py", os.O_RDWR | os.O_CREAT | os.O_TRUNC, 0o600)
    os.write(tmp_fd, b"#2 proc sub\n")
    os.lseek(tmp_fd, 0, os.SEEK_SET)

    statuses = run_pipeline(
        BuiltinCommand(stage_1_ignore),
        ExecCommand("/bin/bash", ["/bin/bash", "-c", "cat >&3"], fd_map=[(0, tmp_fd), (3, PIPE_OUT)]),
        BuiltinCommand(stage_3_replace),
        ExecCommand("/bin/cat", ["/bin/cat"], fd_map=[(1, 5)]),
    )
    try:
        os.close(tmp_fd)
    except OSError:
        pass
    return statuses


def main_cat_passthrough() -> List[Tuple[int, int]]:
    """Simple cat | cat pipeline sanity check."""
    return run_pipeline(
        ExecCommand("/bin/cat", ["/bin/cat"]),
        ExecCommand("/bin/cat", ["/bin/cat"]),
    )


def _usage() -> str:
    return "Usage: shell.pipelines.fork.py [5|cat]"


if __name__ == "__main__":
    if len(sys.argv) < 2:
        raise SystemExit(_usage())
    mode = sys.argv[1]
    if mode == "5":
        main_proc_sub()
    elif mode == "cat":
        main_cat_passthrough()
    else:
        raise SystemExit(_usage())
