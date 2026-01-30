"""Tests for quote_ps.py."""
import os
import subprocess

from quote_ps import ps_quote, quote_args_for_powershell


def validate_quote(s: str, expected: str):
  """Validate that the quoted string round-trips through PowerShell."""
  quoted = ps_quote(s)
  assert quoted == expected

  if os.getenv("VALIDATE_TESTS"):
    # Validate PowerShell actually outputs the original string when using our quoting
    # For unquoted safe tokens, wrap in quotes for echo; for already-quoted strings, use as-is
    ps_arg = quoted if quoted.startswith("'") else f"'{quoted}'"
    result = subprocess.check_output(["pwsh", "-nop", "-Command", f"echo {ps_arg}"]).decode("utf-8").strip()
    
    assert result == s, f"PowerShell echo mismatch: got {result!r}, expected {s!r}"

class TestPsQuote:
  """Tests for ps_quote function."""

  def test_empty_string(self):
    """Test that empty string is quoted."""
    validate_quote("", "''")

  def test_safe_token(self):
    """Test that safe tokens are not quoted."""
    validate_quote("hello", "hello")
    validate_quote("test123", "test123")
    validate_quote("app.exe", "app.exe")
    validate_quote("my-app", "my-app")

  def test_paths_are_safe(self):
    """Test that paths without spaces are not quoted."""
    validate_quote("/usr/bin/app", "/usr/bin/app")
    validate_quote("C:\\Windows\\System32", "C:\\Windows\\System32")
    validate_quote("/Users/me/code:/app", "/Users/me/code:/app")
    validate_quote("~/Documents", "~/Documents")

  def test_safe_punctuation(self):
    """Test that safe punctuation chars are not quoted."""
    validate_quote("key=value", "key=value")
    validate_quote("file@2", "file@2")
    validate_quote("1+2", "1+2")

  def test_quotes_strings_with_spaces(self):
    """Test that strings with spaces are quoted."""
    validate_quote("hello world", "'hello world'")
    validate_quote("C:\\Program Files\\App", "'C:\\Program Files\\App'")

  def test_escapes_single_quotes(self):
    """Test that single quotes are escaped."""
    validate_quote("don't", "'don''t'")

  def test_quotes_powershell_special_chars(self):
    """Test that PowerShell special characters are quoted."""
    validate_quote("file (1).txt", "'file (1).txt'")  # parens
    validate_quote("$HOME", "'$HOME'")  # variable
    validate_quote("foo|bar", "'foo|bar'")  # pipeline
    validate_quote("a;b", "'a;b'")  # statement separator
    validate_quote("a&b", "'a&b'")  # call operator
    validate_quote("*.txt", "'*.txt'")  # wildcard
    validate_quote("a,b", "'a,b'")  # array operator
    validate_quote("{block}", "'{block}'")  # script block
    validate_quote("arr[0]", "'arr[0]'")  # indexing


class TestQuoteArgsForPowershell:
  """Tests for quote_args_for_powershell function."""

  def test_empty_list(self):
    """Test that empty list returns empty list."""
    assert quote_args_for_powershell([]) == []

  def test_safe_token_first_arg_no_ampersand(self):
    """Test that safe token as first arg doesn't get & operator."""
    result = quote_args_for_powershell(["hello"])
    assert result == ["hello"]

  def test_quoted_first_arg_gets_ampersand(self):
    """Test that quoted first arg gets & operator prepended."""
    result = quote_args_for_powershell(["hello world"])
    assert result == ["& 'hello world'"]

  def test_empty_string_first_arg_gets_ampersand(self):
    """Test that empty string as first arg gets & operator."""
    result = quote_args_for_powershell([""])
    assert result == ["& ''"]

  def test_quoted_second_arg_no_ampersand(self):
    """Test that quoted second arg doesn't get & operator."""
    result = quote_args_for_powershell(["hello", "world test"])
    assert result == ["hello", "'world test'"]

  def test_multiple_args_first_quoted(self):
    """Test multiple args where first is quoted."""
    result = quote_args_for_powershell(["C:\\Program Files\\app.exe", "arg1", "arg2"])
    assert result == ["& 'C:\\Program Files\\app.exe'", "arg1", "arg2"]

  def test_multiple_args_first_safe(self):
    """Test multiple args where first is safe token."""
    result = quote_args_for_powershell(["app.exe", "arg with spaces", "arg2"])
    assert result == ["app.exe", "'arg with spaces'", "arg2"]

  def test_single_quotes_escaped_with_ampersand(self):
    """Test that single quotes are escaped even when & is prepended."""
    result = quote_args_for_powershell(["don't stop"])
    assert result == ["& 'don''t stop'"]
