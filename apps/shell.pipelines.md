#ai-slop

# Shell-style pipelines: two execution models (Linux)

Scope
- Linux/POSIX only; focuses on high-level pipeline composition.
- Goal: preserve streaming (no full buffering) while keeping fd semantics predictable.
- Implement a POSIX shell with pipelines from a higher-level language like [[python]].
  - I'm in control of the whole implementation, so I can pick one solution and stick with it.

Shell built-in runs in a forked child process?
- In [POSIX spec](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_09_02) it's implementation-specific whether the last command in a pipeline runs in a forked child process.
- In bash, can set `shopt -s lastpipe` then the last command runs in the same shell process (assuming job control is not active).

Mental model
- Shell can invoke executable binaries, or call built-in functions that modify the shell environment (`cd` or `export`).
- Every stage has stdin/stdout wired by OS pipes.
  - Not just buffering output of first command, then after passing to next command, etc -- need real pipes.
  - Ensures *backpressure* from slow readers; a full pipe buffer naturally stalls writers.
- Need to handle each stage of pipeline [[python.FileDescriptorRedirection|redirecting]] stdin/stdout.
- Choose per stage: forked isolation (preserve `print/input` semantics) or cooperative threads (pass explicit streams).
- Simple model for `cmd | some-builtin` is to run `some-builtin` in-process; this rule generalizes to non-pipeline commands.

Cooperative thread stages (in-process)
- Run built-ins in threads when they accept `(stdin, stdout)` file-like parameters, as each thread can't change process-wide stdio (e.g., `for line in stdin: stdout.write(...)`).
  - Gotcha: legacy `print()/input()` stay bound to process-global stdio
- Wire stages with `os.pipe()`, wrap fds using `io.TextIOWrapper`, flush writes.
- Arbitrary fd targets (e.g., `5>file.txt`):
  - ✅ Open file in parent, `os.dup2(fd, 5, inheritable=True)`, then `subprocess.Popen(..., close_fds=False, pass_fds=(5,)); os.close(5)`
  - ⚠️ Avoid: `preexec_fn` that calls `os.dup2(fd, 5)` in a threaded app, as `preexec_fn` not safe with threads risking deadlock.
- Extra redirection per stage: open files for redirect targets, pass into the callable or `subprocess.Popen(command, stdin=..., stdout=..., stderr=...)`.
- Pro: cross-platform within POSIX scope, no fork/exec for callables, lightweight.

Forked stages (process-isolated)
- For each callable stage: `fork()`, `dup2()` pipe ends onto fd 0/1, rebind stdio in the child, run callable or `execv(argv[0], argv)`, _exit`.
- Extra redirection per stage: before `exec` or running the callable, `dup2` any opened redirection targets onto fd 0/1/2 (e.g., `stdout` → file, `stderr` → file or `2>&1`) and close originals to avoid leaks.
- Parent keeps the read end of the final pipe to stream chunks; waits on child PIDs for exit codes.
- Gotchas: POSIX-only; parent memory is copy-on-write; add signal forwarding/timeouts in production.

## Example pipeline

In bash, here is a small demo that shows:

1. First pipeline stage whose input is ignored later
2. Second pipeline stage redirects its stdin from a process substitution
3. Shell logic does string replacement
4. Last stage writes to fd `5` 

```bash
echo "#2 proc sub" > /tmp/_proc ; (
  echo "#1 ignored" |
  < /tmp/_proc bash -c "cat >&3" 3>&1 | 
  (my_var=$(cat); echo "${my_var/proc sub/PROCESS SUBSTITUTION}") |
  cat >&5
) 5>&1

# outputs
# #2 PROCESS SUBSTITUTION
```

## Pipeline skeletons (Python, Linux)
These can be run with `bash python script.py 5>&1`


Cooperative thread model implementation in [[shell.pipelines.thread.py]]
- [ ] Fix bugs in fork model implementation in [[shell.pipelines.fork.py]]

Exec choice rationale: `execv` as the path is pre-resolved 

Extensions to consider
- Add stderr pipes per stage and multiplex in parent.
- Add timeouts and signal propagation (SIGINT/SIGTERM) to children.
- Provide a Windows fallback via cooperative threads or `multiprocessing` with `spawn` if needed later.
