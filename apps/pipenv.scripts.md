Pipfile can contain tasks, see https://pipenv.pypa.io/en/latest/scripts.html

```toml
[scripts]
test = "python -m unittest"
check = "pyright"

ci = "bash -c 'pipenv run test && pipenv run check'"
```

Composing tasks in an OS-neutral way is a problem, similar to [[npm]] package.json scripts.
Using a shell works, but invoking another script seems to need another `pipenv` invocation
### Extracting the script contents
How to dump the scripts from a Pipfile: 

```
$ cat Pipfile | python -c "import tomllib, sys, json; o = tomllib.load(sys.stdin.buffer); print(*o['scripts'].values(), sep='\n')"
python -m unittest
bash -c 'coverage run -m unittest && coverage xml && coverage report --fail-under 100 --show-missing --skip-covered'
bash -c 'ruff check --fix && ruff format'
pyright
```

## Other tools
[[uv]] has an open issue https://github.com/astral-sh/uv/issues/5903 for a task runner.

- [ ] Next, try [just](https://github.com/casey/just)