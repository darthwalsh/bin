Running `python -m build` invokes whichever `[build-system] build-backend` is set in `pyproject.toml`:

| tool     | build backend         |
| :------- | :--------------------- |
| Poetry   | poetry-core only       |
| PDM      | pdm-backend preferred  |
| uv       | uv_build preferred     |
| Hatch    | hatchling preferred    |
| Flit     | flit_core only         |
| setup.py | setuptools only        |
| pyenv    | n/a                    |
| pipx     | n/a                    |
| Pipenv   | n/a                    |

For testing the built wheel (not source), see [[build-artifact-testing]].

## CI Build Number, no File Mutation
Single-source `major.minor` in the repo, append the build number from an env var at build time. Hatchling's [`code` version source](https://hatch.pypa.io/1.0/plugins/version-source/) evaluates a Python expression from a file at build time:

```toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
dynamic = ["version"]

[tool.hatch.version]
source = "code"
path = "src/my_pkg/__about__.py"  # `expression` defaults to __version__
```

```python
# src/my_pkg/__about__.py
import os

_BASE = "0.1"  # single source of major.minor
__version__ = f"{_BASE}.{os.environ.get('BUILD_NUMBER', '0')}"
```

In dev build with `BUILD_NUMBER` unset, `uv build` yields `0.1.0`.

Within a package, to read the version at runtime: `from my_pkg.__about__ import __version__`
For a package consumer, use [`importlib.metadata.version("my-pkg")`](https://docs.python.org/3/library/importlib.metadata.html) to read version built into the wheel.

hatchling's other built-in, the [`env` source](https://hatch.pypa.io/1.13/plugins/version-source/env/), only takes a `variable` name and uses its *entire* value as the versionL no `pattern` or multi-var composition. Use `code` instead whenever the base version should stay in the repo.

setuptools can't do this without mutating a file: `dynamic = {version = {attr = ...}}` is documented to fall back to importing the module for computed values, but that's [disputed in practice](https://github.com/pypa/setuptools/discussions/3630): "only works when `__version__` is a simple string." The only working setuptools option is writing the file pre-build:

```bash
# ⚠️ OOPS! Mutates a git-tracked file on the build machine. Avoid this!
echo "__version__ = \"0.1.${BUILD_NUMBER}\"" > src/my_pkg/__about__.py
```

## Branch Name in Local Label and Not SemVer -PreRelease
Version scheme is defined by [Version specifiers](https://packaging.python.org/en/latest/specifications/version-specifiers/), which supersedes [PEP 440](https://peps.python.org/pep-0440/). Interesting to me:
- Release segment: `N(.N)*`
- Pre-release segment: `{a|b|rc}N`
- Development release segment: `.devN`

Python version are not [[SemVer]]. `0.1.5-mybranch` (hyphen prerelease) [isn't permitted](https://packaging.python.org/en/latest/specifications/version-specifiers/#semantic-versioning) but maps to `0.1.5.dev0+mybranch`.
NuGet-style [behavior](https://packaging.python.org/en/latest/specifications/version-specifiers/#handling-of-pre-releases) "prerelease excluded by default" maps to **dev** releases: requiring `--pre`, or exact pin.

Branch names go in the [local version label](https://packaging.python.org/en/latest/specifications/version-specifiers/#local-version-identifiers), but *public PyPI rejects any `+label` upload.* (Interestingly, Artifactory PyPI *does* allow local versions.)
Local labels are [ignored during version matching](https://packaging.python.org/en/latest/specifications/version-specifiers/#version-matching), so keep `.dev0`.

Recommended scheme:
```python
import os

_BASE = "0.1"
_build = os.environ.get("BUILD_NUMBER", "0")
_branch = os.environ.get("BRANCH_NAME", "")
if _branch in ("", "develop", "main", "master"):
    __version__ = f"{_BASE}.{_build}"
else:
    _label = "".join(c if c.isalnum() else "." for c in _branch).strip(".")
    __version__ = f"{_BASE}.{_build}.dev0+{_label}"
```

### Gotcha: hatchling sdist rejects external symlinks
`uv build` (sdist + wheel) failed with `symlink path ... is absolute, but external symlinks are not allowed` because a tracked file was a symlink pointing outside the repo (e.g. shared [[ai.skills]] ).
Either `uv build --wheel` skips the sdist, or stop tracking the symlink.
