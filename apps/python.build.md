#ai-slop
Running `python -m build` runs the `pyproject.toml` > `build-system` > `build-backend` tool. Different python tools have different build backends:

| tool   | build backend         |
| :----- | :-------------------- |
| Poetry | poetry-core only      |
| PDM    | pdm-backend preferred |
| uv     | uv_build preferred    |
| Hatch  | hatchling preferred   |
| Flit   | flit_core only        |
| setup.py | setuptools only      |
| pyenv  | ❌ n/a                 |
| pipx   | ❌ n/a                 |
| Pipenv | ❌ n/a                 |

## Automatic build version in CI

Generic solution is a pre-build script that sets the version in the `__init__.py` file or `pyproject.toml` before running `python -m build`:

```bash
# CI sets this environment variable
export BUILD_NUMBER="1234"

echo "__version__ = \"3.5.${BUILD_NUMBER}\"" > src/my_project/__init__.py
```

Getting version at runtime:

**Method 1** (internal): `from my_app import __version__`
**Method 2** (external/reliable): `importlib.metadata.version("my-app")`

### Hatching
Built-in support via `[tool.hatch.version]`:
```toml
[project]
dynamic = ["version"]

[tool.hatch.version]
source = "env"
env-vars = ["BUILD_NUMBER"]
pattern = "3.5.{BUILD_NUMBER}"
```




