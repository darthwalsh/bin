## Tools to try:
- [ ] Deep inspection of Python objects https://igrek51.github.io/wat/
## Installation
System package manager should install python that is easy to upgrade.
### mise shim for each project
[[mise]] respects CWD `.python-version` / `.mise.toml` when used.
### Install global python using uv
Ok if no system fallback, but [doesn't create](https://github.com/astral-sh/uv/issues/6265) a dynamic shim using CWD `.python-version`.

```bash
uv python install --default --preview
```
[Respects](https://docs.astral.sh/uv/concepts/python-versions/#python-version-files) the *local* `.python-version` when setting *global* `python3`.

Need `~/.local/bin` on `PATH`.
Has the advantage that `pip install` fails with `error: externally-managed-environment` unlike pyenv
## Logging
https://www.dash0.com/guides/logging-in-python
[Modern Python logging - mCoding - YouTube](https://www.youtube.com/watch?v=9L77QExPmI0)

## Performance
If a script is too low, consider running [Mypyc](https://mypyc.readthedocs.io/en/latest/) -- documented in blog: [Deciphering Glyph :: You Should Compile Your Python And Here’s Why](https://blog.glyph.im/2022/04/you-should-compile-your-python-and-heres-why.html?utm_source=pocket_shared)
