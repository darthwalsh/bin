"""Update vscode settings.json python.defaultInterpreterPath with uv or hatch.

Workaround for https://github.com/microsoft/vscode-python/issues/24916
Need to have executed the script once with `uv run` so that the interpreter was created.
For hatch projects, use "hatch" as the argument to find the test environment.
"""

import json
import os
import subprocess
import sys
from pathlib import Path


def update_vscode_settings(py_interpreter: str, settings_file: Path) -> None:
  """Update the VSCode settings.json file to use the specified Python interpreter.

  Uses jsonc-cli to properly handle JSON with comments (JSONC/JSON5).
  See https://github.com/nicholaschiang/jsonc-cli which wraps VS Code's jsonc-parser.

  Considered pasting the value to clipboard, then starting vscode://settings/python.defaultInterpreterPath but that defaults to user view, doesn't allow setting the value.
  Docs: https://code.visualstudio.com/docs/configure/command-line#_opening-vs-code-with-urls
  Implementation: https://github.com/microsoft/vscode/blob/a9feb6c2f9a784544fcdfc53bc507e163a0db0f8/src/vs/workbench/services/preferences/browser/preferencesService.ts#L644
  It feels like the vscode:\\ scheme should allow POST/PUT requests, but that is not supported by the OS: https://stackoverflow.com/a/9945682/771768

  Args:
    py_interpreter: Path to the Python interpreter
    settings_file: Path to settings.json file (defaults to .vscode/settings.json in cwd)
  """
  content = settings_file.read_text(encoding="utf-8").strip()

  json_path = json.dumps(["python.defaultInterpreterPath"])
  js_value = json.dumps(py_interpreter)

  try:
    subprocess.run(
      ["jsonc", "modify", "--JSONPath", json_path, "--value", js_value, "--file", str(settings_file)],
      input=content,
      text=True,
      check=True,
    )
  except FileNotFoundError as e:
    raise FileNotFoundError("jsonc not found. Install with: npm install --global jsonc-cli") from e


def find_hatch_test_interpreter(envs_json: str):
  """Find the Python interpreter for hatch's test environment."""
  current_version = f"{sys.version_info.major}.{sys.version_info.minor}"

  envs = json.loads(envs_json)

  test_envs = [name for name in envs.keys() if name.startswith("hatch-test.py")]

  if not test_envs:
    raise RuntimeError("No hatch test environments found")

  target_env = None
  for env_name in test_envs:
    if f"py{current_version}" in env_name:
      target_env = env_name
      break

  if not target_env:

    def extract_version(env_name):
      parts = env_name.replace("hatch-test.py", "").split(".")
      return tuple(int(p) for p in parts)

    test_envs.sort(key=extract_version, reverse=True)
    target_env = test_envs[0]

  env_path = subprocess.check_output(["hatch", "env", "find", target_env], text=True).strip()
  env_path = Path(env_path)

  if os.name == "nt":
    py_interpreter = env_path / "Scripts" / "python.exe"
  else:
    py_interpreter = env_path / "bin" / "python"

  if not py_interpreter.exists():
    raise RuntimeError(f"Hatch test environment Python interpreter not found at {py_interpreter}")

  return str(py_interpreter)


if __name__ == "__main__":
  arg = sys.argv[1]

  if arg == "hatch":
    envs_json = subprocess.check_output(["hatch", "env", "show", "--json"], text=True).strip()
    py_interpreter = find_hatch_test_interpreter(envs_json)
  elif arg.endswith(".py"):
    # Don't parse `uv run -v $PyScript` because that would actually *run* the script
    py_interpreter = subprocess.check_output(["uv", "python", "find", "--script", arg], text=True).strip()
  else:
    raise ValueError(f"Argument must be 'hatch' or end with '.py', got: {arg}")

  py_interpreter = py_interpreter.replace("\\", "/")
  print(f"Using {py_interpreter}")

  settings_file = Path.cwd() / ".vscode" / "settings.json"
  update_vscode_settings(py_interpreter, settings_file)
