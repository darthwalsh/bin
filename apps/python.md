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
## Logging
https://www.dash0.com/guides/logging-in-python
[Modern Python logging - mCoding - YouTube](https://www.youtube.com/watch?v=9L77QExPmI0)

## Performance
If a script is too low, consider running [Mypyc](https://mypyc.readthedocs.io/en/latest/) -- documented in blog: [Deciphering Glyph :: You Should Compile Your Python And Here’s Why](https://blog.glyph.im/2022/04/you-should-compile-your-python-and-heres-why.html?utm_source=pocket_shared)

## Not sure how to ban use of API
https://chatgpt.com/share/68507ea6-56ec-8011-b0fe-ac37e4276a7e

#ai-slop 
Can prevent imports:
```toml
[tool.ruff]
select = ["TID", ...]  # TID is for tidy-imports

[tool.ruff.flake8-tidy-imports.banned-api]
"PyQt5.QtWidgets.QMessageBox.information" = "Use a custom dialog instead of QMessageBox.information"
```

Then for
```python
from PyQt5.QtWidgets import QMessageBox

QMessageBox.information(None, "Title", "Message")
```
would get warning
>TID252: Use a custom dialog instead of QMessageBox.information

- [ ] But ChatGPT says this couldn't be prevented??

```python
import PyQt5

PyQt5.QtWidgets.QMessageBox.information(None, "Title", "Message")
```
