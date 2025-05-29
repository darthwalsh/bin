My requirements:
- Quick to call scripts, i.e. < 50ms
- Cross platform (not just WSL)
- Not complicated to compose `if` and `for`
- Simple to call other programs
- Able to copy-paste program snippets into terminal


| tool       | Win hello (ms) | macOS hello                                   |
| ---------- | -------------- | --------------------------------------------- |
| bash       | ❌              | 10                                            |
| python     |                | 45<br>(45 uv)<br>(60 homebrew)<br>(75 system) |
| node       |                | 58                                            |
| bun        |                | 56                                            |
| pwsh spawn |                | 120                                           |
| pwsh func  |                | 0.001                                         |
- [ ] profile hello world startup time #windows 
## bash
- [ ] document how to create with chmod +x
## python
- [ ] document how to create with [[python.RelativePathShebang]] and alias
## JS
- [ ] https://bun.sh/docs/runtime/shell
