#!/usr/bin/env -S uv run
"""Output all termcolor colors

Shows all colors available in termcolor library, displaying both regular and dark variants.
"""

# /// script
# dependencies = [
#   "termcolor",
# ]
# ///

from termcolor import COLORS, HIGHLIGHTS, colored

MAX_LEN = max(len(c) for c in HIGHLIGHTS)

def try_print(color):
  try:
    if color.startswith("on_"):
      complement = 'black' if color.endswith('white') else 'white'
      print(colored(color, color=complement, on_color=color), end="")
    else:
      print(colored(color, color), end="")
  except KeyError:
    print(end=' ' * len(color))

  print(end=" " * (MAX_LEN - len(color)))


# Display colors with both regular and dark variants
for color in COLORS:
  if "_" in color:
    continue

  # Special handling for black - show on white background
  if color == "black":
    print(colored("black", "black"), end=" ")
    print(colored("<- (did you see Black)", "black", on_color="on_white"))
    continue

  try_print(color)
  try_print(f"light_{color}")
  try_print(f"on_{color}")
  try_print(f"on_light_{color}")
  print()
