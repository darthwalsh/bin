#ai-slop

How major packaging ecosystems encode [[build-artifact-testing]] guarantees (separate build/install/test roots, explicit runtime vs. build deps, and staging before packaging).

## Linux (Deb/RPM)

Build and package in isolated roots:
- `DESTDIR` staging: build into one root, install into `DESTDIR`, package from that staged tree.
- `Build-Depends` vs `Depends` (Debian) / `BuildRequires` vs `Requires` (RPM): runtime and build deps are declared separately; the final package only carries runtime deps.
- Out-of-tree builds are normal (`cmake -B build`); the source tree is never the install tree.
- [Reproducible Builds](https://reproducible-builds.org/) project: control environment, timestamps, locale, and tool versions to minimize ambient inputs.

## macOS (app bundles)

The shipping unit is a `.app` bundle or `.pkg`. Good practice:
- Assemble the bundle in a staging directory, sign it, then smoke-test launching the *signed bundle*.
- All dynamic libs must be inside the bundle or explicitly referenced; codesigning and notarization surface missing deps naturally.
- `otool -L` to inspect dynamic deps; bundle validation catches the "works only on dev box" case.

## Windows (MSI/MSIX)

The installed product is the truth. Good pipelines:
- Build binaries → build installer → install into a clean VM/container snapshot → run smoke/integration tests against the installed result.
- Dependency analysis tools scan for unexpected runtime deps; a clean-machine install+run is the definitive test.

## Python (wheel/sdist)

```bash
# Build
python -m build --wheel --sdist

# Tier B: artifact test
python -m venv .venv_artifact
. .venv_artifact/bin/activate
pip install dist/*.whl
pip install -r requirements-test.txt
cd /tmp/artifact_test_run    # NOT the repo root
PYTHONPATH= pytest /path/to/tests

# Tier C: minimal runtime smoke (no pytest)
python -m venv .venv_runtime
. .venv_runtime/bin/activate
pip install dist/*.whl        # only runtime deps, transitively
python -c "import yourpkg; print(yourpkg.__version__)"
```

Key guardrail: run Tier B tests from outside the repo root with `PYTHONPATH=` unset, so there's no path for imports to fall back to the working tree. The [src layout](https://packaging.python.org/en/latest/discussions/src-layout-vs-flat-layout/) helps but is not sufficient on its own — testing the installed wheel is the real fix.

See also [[python.build]] for wheel build backends and CI versioning.
