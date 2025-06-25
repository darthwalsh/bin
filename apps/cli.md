## Interested to try
[pvolok/mprocs: Run multiple commands in parallel](https://github.com/pvolok/mprocs) TUI can either run ad-hoc, or create config:
```yaml
procs:
  nvim:
    cmd: ["nvim"]
  server:
    shell: "nodemon server.js"
  webpack: "webpack serve"
  tests:
    shell: "jest -w"
    env:
      NODE_ENV: test
```

[dandavison/delta: A syntax-highlighting pager for git, diff, grep, and blame output](https://github.com/dandavison/delta)
>A syntax-highlighting pager for git, diff, grep, and blame output

[uutils/coreutils: Cross-platform Rust rewrite of the GNU coreutils](https://github.com/uutils/coreutils)
- [ ] Try installing on #windows because GOW is not ideal
### Task runner
Pipenv pipfile does not work great: [[pipenv.scripts#Other tools]] 

- [ ] First try [just](https://github.com/casey/just)
- [ ] Then try [jacobdeichert/mask: 🎭 A CLI task runner defined by a simple markdown file](https://github.com/jacobdeichert/mask): A `maskfile.md` is both a **human-readable document** and a **command definition**




