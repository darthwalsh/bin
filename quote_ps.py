#!/usr/bin/env uv run
"""Convert CLI command and args to PowerShell-safe quoting"""

import re
import sys

# Safe PowerShell token: alphanumeric, path chars (/\:._-), and common safe punctuation (~+=@)
# Must quote: space ' " $ ` ( ) { } [ ] | ; & < > # * ? , ! newlines
SAFE_TOKEN = re.compile(r"^[A-Za-z0-9._/\\:~+=@-]+$")


def ps_quote(s: str) -> str:
  # Empty string must be quoted in PowerShell
  if s == "":
    return "''"

  # Safe unquoted PowerShell token
  if SAFE_TOKEN.match(s):
    return s

  # PowerShell single-quote escaping: ' -> ''
  s = s.replace("'", "''")
  return f"'{s}'"


def quote_args_for_powershell(args: list[str]) -> list[str]:
  """Quote arguments for PowerShell, prepending & to first arg if it becomes quoted."""
  if not args:
    return []

  quoted = []
  for i, arg in enumerate(args):
    original = arg
    quoted_arg = ps_quote(arg)
    # If first arg becomes quoted (wasn't a safe token), prepend & operator
    if i == 0 and quoted_arg != original:
      quoted_arg = f"& {quoted_arg}"
    quoted.append(quoted_arg)

  return quoted


def main():
  quoted = quote_args_for_powershell(sys.argv[1:])
  print(" ".join(quoted))


if __name__ == "__main__":
  main()
