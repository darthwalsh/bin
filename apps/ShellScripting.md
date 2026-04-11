My requirements:
- Quick to call scripts, i.e. < 50ms
- Cross platform (not just WSL)
- Not complicated to compose `if` and `for`
- Simple to call other programs
- Able to copy-paste program snippets into terminal

*For a more comprehensive table, see https://github.com/bdrung/startup-time*

| tool           | Win hello (ms) | macOS hello                                                     |
| -------------- | -------------- | --------------------------------------------------------------- |
| bash           | ❌              | 10                                                              |
| python no-deps |                | 20 mise/uv<br>34 brew<br>44 macOS system                        |
| python deps    |                | 157 uv run --script<br>158 venv pre-built<br>172 uv run project |
| node           |                | 58                                                              |
| bun            |                | 56                                                              |
| pwsh spawn     |                | 120                                                             |
| pwsh func      |                | 0.001                                                           |
- [ ] profile hello world startup time #windows
## pwsh
Create new scripts with `newps1 Get-CommandName`
## bash
Create new scripts with `newsh command-name`
## Python
- [ ] document how to create with [[python.RelativePathShebang]] and alias

### Python startup (warm, macOS Apple Silicon)
Full benchmark methodology and results: [[benchmarking/README.md]]

- **No deps** — mise/uv-managed direct binary (~20ms; use `-S` to skip site module on no-dep scripts) → brew (~34ms) → system 3.9 (~44ms) → `uv run --no-project` (~63ms) → pyenv shim (~460ms, 23×)
- **With deps** — `uv run --script` (~157ms) ≈ venv pre-built (~159ms) ≈ `uv run` project (~172ms) → hatch (~514ms) → pipenv (~656ms) → pdm (~909ms) → poetry (~1011ms)

`uv run --offline script.py || uv run script.py` — fast-first fallback when cache may be stale after long breaks.

## JS
- [ ] https://bun.sh/docs/runtime/shell
### Amber transpiles JS to Bash
[Amber](https://amber-lang.com/) is basically [[javascript]] but it transpiles to Bash, and has easy syntax for executing system commands
```javascript
sudo $ systemctl restart nginx $ failed(code) {
    echo "Exited with code {code}."
}
```
See [this presentation slides](https://mte90.tech/Talk-Amber/#/) for a good intro.

