"""Update vscode settings.json python.defaultInterpreterPath with uv.

Workaround for https://github.com/microsoft/vscode-python/issues/24916
Need to have executed the script once with `uv run` so that the interpreter was created.
"""

import json
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

  script_dir = Path(__file__).resolve().parent
  vscode_settings_file = script_dir / ".vscode" / "settings.json"
  settings_content = vscode_settings_file.read_text(encoding="utf-8")

  replacement = f'"python.defaultInterpreterPath": {json.dumps(py_interpreter)}'
  updated_content = re.sub(r'("python\.defaultInterpreterPath":)\s*"[^"]+"', replacement, settings_content)

  vscode_settings_file.write_text(updated_content, encoding="utf-8")


if __name__ == "__main__":
  py_script_arg = sys.argv[1]

  # Don't parse `uv run -v $PyScript` because that would actually *run* the script
  py_interpreter = subprocess.check_output(["uv", "python", "find", "--script", py_script_arg], text=True).strip()
  py_interpreter = py_interpreter.replace("\\", "/")
  print(f"Using {py_interpreter}")

  update_vscode_settings(py_interpreter)
