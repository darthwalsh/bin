"""Update vscode settings.json python.defaultInterpreterPath with uv or hatch.

Workaround for https://github.com/microsoft/vscode-python/issues/24916
Need to have executed the script once with `uv run` so that the interpreter was created.
For hatch projects, use "hatch" as the argument to find the test environment.
"""

import json
import os
import re
import subprocess
import sys
from pathlib import Path


def update_vscode_settings(py_interpreter):
  """Update the VSCode settings.json file to use the specified Python interpreter.

  No great way to automatically edit the settings.json file...

  Considered pasting the value to clipboard, then starting vscode://settings/python.defaultInterpreterPath but that defaults to user view, doesn't allow setting the value.
  Docs: https://code.visualstudio.com/docs/configure/command-line#_opening-vs-code-with-urls
  Implementation: https://github.com/microsoft/vscode/blob/a9feb6c2f9a784544fcdfc53bc507e163a0db0f8/src/vs/workbench/services/preferences/browser/preferencesService.ts#L644
  It feels like the vscode:\\ scheme should allow POST/PUT requests, but that is not supported by the OS: https://stackoverflow.com/a/9945682/771768

  Just reading/writing JSON won't work, it needs to be JSON5 (with comments).
  MAYBE find a low-level parser in order to get the byte offset of the string value we want to replace without impacting any formatting.
  """

  vscode_settings_file = Path.cwd() / ".vscode" / "settings.json"
  settings_content = vscode_settings_file.read_text(encoding="utf-8")

  replacement = f'"python.defaultInterpreterPath": {json.dumps(py_interpreter)}'
  updated_content = re.sub(r'("python\.defaultInterpreterPath":)\s*"[^"]+"', replacement, settings_content)
  if updated_content == settings_content:
    raise RuntimeError("Must manually add the python.defaultInterpreterPath in .vscode/settings.json file")

  vscode_settings_file.write_text(updated_content, encoding="utf-8")


def find_hatch_test_interpreter():
  """Find the Python interpreter for hatch's test environment."""
  current_version = f"{sys.version_info.major}.{sys.version_info.minor}"
  
  envs_json = subprocess.check_output(["hatch", "env", "show", "--json"], text=True).strip()
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
    py_interpreter = find_hatch_test_interpreter()
  elif arg.endswith(".py"):
    # Don't parse `uv run -v $PyScript` because that would actually *run* the script
    py_interpreter = subprocess.check_output(["uv", "python", "find", "--script", arg], text=True).strip()
  else:
    raise ValueError(f"Argument must be 'hatch' or end with '.py', got: {arg}")

  py_interpreter = py_interpreter.replace("\\", "/")
  print(f"Using {py_interpreter}")

  update_vscode_settings(py_interpreter)
