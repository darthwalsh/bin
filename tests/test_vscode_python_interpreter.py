"""Tests for vscode_python_interpreter.py."""

import subprocess
import sys
from pathlib import Path

import pytest

from vscode_python_interpreter import find_hatch_test_interpreter, find_uv_script_interpreter, update_vscode_settings


@pytest.fixture
def settings_file(tmp_path):
  """Create a temporary settings.json file for testing."""
  vscode_dir = tmp_path / ".vscode"
  vscode_dir.mkdir()
  settings = vscode_dir / "settings.json"
  return settings


class TestUpdateVscodeSettings:
  """Tests for update_vscode_settings function."""

  def test_updates_existing_value(self, settings_file):
    """Test updating an existing python.defaultInterpreterPath value."""
    settings_file.write_text("""{
  "python.defaultInterpreterPath": "/old/path/python",
  "editor.fontSize": 14
}
""")

    update_vscode_settings("/new/path/python", settings_file)

    assert (
      settings_file.read_text().strip()
      == """{
  "python.defaultInterpreterPath": "/new/path/python",
  "editor.fontSize": 14
}"""
    )

  def test_preserves_comments(self, settings_file):
    """Test that JSONC comments are preserved."""
    settings_file.write_text("""{
  // This is a comment about the interpreter
  "python.defaultInterpreterPath": "/old/python",
  /* Block comment */
  "editor.fontSize": 14
}
""")

    update_vscode_settings("/new/python", settings_file)

    assert (
      settings_file.read_text().strip()
      == """{
  // This is a comment about the interpreter
  "python.defaultInterpreterPath": "/new/python",
  /* Block comment */
  "editor.fontSize": 14
}"""
    )

  def test_preserves_trailing_commas(self, settings_file):
    """Test that trailing commas are preserved."""
    settings_file.write_text("""{
  "python.defaultInterpreterPath": "/old/python",
  "editor.fontSize": 14,
}
""")

    update_vscode_settings("/new/python", settings_file)

    assert (
      settings_file.read_text().strip()
      == """{
  "python.defaultInterpreterPath": "/new/python",
  "editor.fontSize": 14,
}"""
    )

  def test_adds_key_if_missing(self, settings_file):
    """Test that the key is added if it doesn't exist."""
    settings_file.write_text("""{
  "editor.fontSize": 14
}
""")

    update_vscode_settings("/new/python", settings_file)

    assert (
      settings_file.read_text().strip()
      == """{
  "editor.fontSize": 14,"python.defaultInterpreterPath": "/new/python"
}"""
    )

  def test_handles_special_characters_in_path(self, settings_file):
    """Test paths with special characters are properly escaped."""
    settings_file.write_text("""{
  "python.defaultInterpreterPath": "/old"
}
""")

    special_path = '/path/with spaces/and "quotes"'
    update_vscode_settings(special_path, settings_file)

    assert (
      settings_file.read_text().strip()
      == """{
  "python.defaultInterpreterPath": "/path/with spaces/and \\"quotes\\""
}"""
    )

  def test_file_not_found(self, tmp_path):
    """Test error when settings file doesn't exist."""
    nonexistent = tmp_path / "nonexistent" / "settings.json"

    with pytest.raises(FileNotFoundError):
      update_vscode_settings("/some/python", nonexistent)


@pytest.fixture(scope="session", autouse=True)
def check_jsonc_available():
  """Verify jsonc is available before running tests."""
  try:
    subprocess.run(["jsonc", "--version"], check=True, capture_output=True)
  except (subprocess.CalledProcessError, FileNotFoundError) as e:
    pytest.skip(f"jsonc not available (npm install --global jsonc-cli): {e}")


class TestFindHatchTestInterpreter:
  """Tests for find_hatch_test_interpreter function."""

  def test_finds_matching_python_version(self, monkeypatch, tmp_path):
    """Test finding interpreter for current Python version."""
    current = f"{sys.version_info.major}.{sys.version_info.minor}"
    envs_json = f'{{"hatch-test.py{current}": {{"type": "virtual"}}}}'

    env_path = tmp_path / "envs" / f"hatch-test.py{current}"
    (env_path / "bin").mkdir(parents=True)
    (env_path / "bin" / "python").touch()

    monkeypatch.setattr(subprocess, "check_output", lambda *a, **kw: str(env_path) + "\n")

    result = find_hatch_test_interpreter(envs_json)
    assert result == str(env_path / "bin" / "python")

  def test_picks_highest_version_when_current_missing(self, monkeypatch, tmp_path):
    """Test picking highest version when current Python not available."""
    envs_json = '{"hatch-test.py3.10": {}, "hatch-test.py3.12": {}, "hatch-test.py3.11": {}}'

    env_path = tmp_path / "envs" / "hatch-test.py3.12"
    (env_path / "bin").mkdir(parents=True)
    (env_path / "bin" / "python").touch()

    def mock_check_output(cmd, **kw):
      assert "hatch-test.py3.12" in cmd
      return str(env_path) + "\n"

    monkeypatch.setattr(subprocess, "check_output", mock_check_output)

    find_hatch_test_interpreter(envs_json)
    # mock_check_output asserts the correct env was selected

  def test_raises_when_no_test_envs(self):
    """Test error when no hatch test environments exist."""
    envs_json = '{"default": {}, "hatch-build": {}}'

    with pytest.raises(RuntimeError, match="No hatch test environments found"):
      find_hatch_test_interpreter(envs_json)


class TestFindUvScriptInterpreter:
  """Tests for find_uv_script_interpreter function."""

  def test_returns_cached_environment_after_script_run(self, tmp_path):
    """Test that function returns cached environment path after script has been run."""
    # Create a test script with uv inline script format
    test_script = tmp_path / "test_script.py"
    test_script.write_text(
      """#!/usr/bin/env uv run
# /// script
# dependencies = [
#     "requests",
# ]
# ///
import sys
sys.exit(0)
"""
    )

    # Run uv run once to create the cached environment
    subprocess.run(
      ["uv", "run", "--script", str(test_script)],
      check=True,
      capture_output=True,
    )

    result = find_uv_script_interpreter(str(test_script))

    assert ".venv" not in result, f"Result contains .venv: {result}"
    assert Path(result).exists()

  def test_raises_when_script_not_run_yet(self, tmp_path):
    """Test that function raises error when script hasn't been run yet."""
    # Create a script with unique deps to ensure no cache hit
    import uuid

    test_script = tmp_path / f"never_run_{uuid.uuid4().hex[:8]}.py"
    test_script.write_text(
      """#!/usr/bin/env uv run
# /// script
# dependencies = [
#     "httpx>=0.28.0,<0.28.1",
# ]
# ///
import sys
sys.exit(0)
"""
    )

    # Script hasn't been run, so no cached environment exists
    with pytest.raises(RuntimeError, match="Run the script once first"):
      find_uv_script_interpreter(str(test_script))
