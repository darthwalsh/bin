## Setup
Install [hatch](https://hatch.pypa.io/1.12/install/)

To create a new CLI project in a subfolder, run `hatch new "Your Project" --cli`
### Testing
https://hatch.pypa.io/1.12/tutorials/testing/overview/
Defaults to use pytest.
Will forward CLI args to pytest

Has built-in support for retrying/parallel/randomized test execution
Can do test-matrix with different python versions

Also includes code coverage integration.
In order to see in vscode [Coverage Cutters](https://github.com/ryanluker/vscode-coverage-gutters), can run
```bash
hatch run hatch-test.py3.12:coverage xml
```

### Formatting
https://hatch.pypa.io/1.12/config/internal/static-analysis/
Formats code with [[ruff]]
Use https://hatch.pypa.io/1.12/config/internal/static-analysis/#persistent-config option to write hatch's ruff config to a file, if you use ruff directly in IDE integration.
Hatch's format also sorts imports, which is [not included](https://docs.astral.sh/ruff/formatter/#sorting-imports) in `ruff format`.

Can set [ruff formatting config](https://docs.astral.sh/ruff/settings/) like setting in `pyproject.toml`
```toml
[tool.ruff]
indent-width = 2
```

Doesn't have deep integration with a type checker, but the default template sets up `mypy` checking.

## VSCode integration
According to [release notes](https://github.com/microsoft/vscode-python/releases/tag/v2024.4.0), supposed to work based on https://code.visualstudio.com/updates/v1_88#_hatch-environment-discovery
Might want [this workaround](https://stackoverflow.com/q/76457139/771768) if you often use VS Code's Quick Fix with `CTRL+.` to add imports, but Ruff's "disable warning" on this line shows up first

## Tried workaround, but this wasn't needed
Tried to manually set the python interpreter path, but it seemed not to accept that with space?

- [ ] Try this all again after closing down vscode
- [ ] NEXT, maybe there's a logic bug in `env show` not including pytest?? https://github.com/microsoft/vscode-python/pull/22779/files#diff-76daf942b320b0da5598b92d5a1cd7413e8c4ad6ee4a5842238ad18ea8e0004dR73

Did workaround
```pwsh
cd ~/Library
new-item -ItemType SymbolicLink -Path 'ApplicationSupport' -Target "./Application Support/"                  
```

Then it worked to manually set `/Users/walshca/Library/ApplicationSupport/hatch/env/virtual/hatch/lEciBZRC/hatch-test.py3.12/bin/python3`

## Contributing
Install stable hatch normally
Clone https://github.com/pypa/hatch
`hatch run hatch --version` to run the app from src
Test: `hatch test ./tests/cli/new/ -k test_projects_urls_space_in_label`

Be aware the docs at i.e. https://hatch.pypa.io/1.12/community/contributing/ are for the stable version, but things may have changed in the master branch, so prefer https://hatch.pypa.io/dev/community/contributing/