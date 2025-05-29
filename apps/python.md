## Tools to try:
- [ ] Deep inspection of Python objects https://igrek51.github.io/wat/
## Installation
System package manager should install python that is easy to upgrade.
### pyenv shim for each project
Respects CWD `.python-version` when used.

On macOS: `brew install pyenv`
On Windows, use [pyenv-win fork](https://github.com/pyenv-win/pyenv-win) : `scoop install pyenv`
### Install global python using uv
Ok if no system fallback, but [doesn't create](https://github.com/astral-sh/uv/issues/6265) a dynamic shim using CWD `.python-version`.

```bash
uv python install --default --preview
```
[Respects](https://docs.astral.sh/uv/concepts/python-versions/#python-version-files) the *local* `.python-version` when setting *global* `python3`.

Need `~/.local/bin` on `PATH`.
Has the advantage that `pip install` fails with `error: externally-managed-environment` unlike pyenv

## Performance
If a script is too low, consider running [Mypyc](https://mypyc.readthedocs.io/en/latest/) -- documented in blog: [Deciphering Glyph :: You Should Compile Your Python And Here’s Why](https://blog.glyph.im/2022/04/you-should-compile-your-python-and-heres-why.html?utm_source=pocket_shared)