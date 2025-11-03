#!/usr/bin/env python
"""WIP script to parse ADB dumpsys shortcut data into a JSON object
Really hacky. Based on some terrible ideas in https://chatgpt.com/share/68f927bc-0dc0-8011-8355-a73db3ef27c9
"""

import re
from dataclasses import dataclass, field

# TODO change to subprocess `adb dumpsys shortcut`
FILE = "/var/folders/v7/p7wfv43s725dwxcp5fn3vyz80000gp/T/code-stdin-abj"
# FILE = "/var/folders/v7/p7wfv43s725dwxcp5fn3vyz80000gp/T/code-stdin-BaA"

################################################################################
################################ Pseudo-JSON parser ############################
################################################################################
def tokenize(text):
  return re.findall(r'[^\n,{}="]+|.', text.replace(" ", ""), re.DOTALL)


def peek():
  return tokens[0]


def pop():
  return tokens.pop(0)


def try_take(s):
  if peek() == s:
    return pop()


def take(s):
  actual = pop()
  if actual != s:
    raise ValueError(f"Expected {s} but at {tokens}")


def parse_obj():
  name = pop()
  if not try_take("{"):
    return name
  data = {}
  while True:
    key = pop()
    if try_take("="):
      value = parse_obj()
    else:
      value = "N/A"
    data[key] = value

    if try_take("}"):
      break
    if not (try_take(",") or try_take("\n")):
      # raise ValueError(f"Expected ',' or '\n' but at {tokens}")
      pass  # Some data doesn't have this comma
  return {"_name": name} | data


tokens = []


def parse(line, lines):
  while line.count("{") > line.count("}"):
    line += "\n" + next(lines)

  tokens[:] = tokenize(line)
  # print('\n'.join(tokens))
  return parse_obj()


@dataclass
class Entry:
  key: str
  value: str
  indent: int
  children: list["Entry"] = field(default_factory=list)

  def child_json(self):
    if not self.children:
      return self.value
    val = {}
    if self.value: 
      val["_val"] = self.value
    for child in self.children:
      match val.get(child.key):
        case list():
          val[child.key].append(child.child_json())
        case None:
          val[child.key] = child.child_json()
        case x:
          val[child.key] = [x, child.child_json()]
    return val

  def dump(self, indent):
    print(f"{' ' * indent}{self.key}= {self.value}")
    for child in self.children:
      child.dump(indent + 2)

################################################################################
################################ Pseudo-YAML parser ############################
################################################################################
def parse_data(path):
  """Parses a pseudo-YAML file from ADB dumpsys shortcut"""
  with open(path, "r") as f:
    data = f.read()
  root = Entry(key="root", value="", indent=-1)
  stack = [root]

  lines = iter(data.splitlines())
  for line in lines:
    if not line.strip():
      continue
    if line.startswith("  Pending saves: "):
      continue

    indent = len(line) - len(line.lstrip())
    if "{" in line:
      value = parse(line, lines)
      key = value.pop("_name")
    else:
      try:
        key, value = line.split(":", 1)
      except ValueError:
        key, value = line.split("=", 1)
      key, value = key.strip(), value.strip()

    # Pop until we're at the correct indent level
    while indent <= stack[-1].indent:
      stack.pop()

    child = Entry(key, value, indent)
    last_stack = stack[-1]
    if indent > last_stack.indent:
      last_stack.children.append(child)
      stack.append(child)
    else:
      last_stack.children.append(child)

  return root


raise NotImplementedError
# def extract_pinned(node):
#   packages = node["User"][0]["Package"]
#   for package in packages:

# root = parse_data(FILE)
# # for d in root.children: d.dump(0)

# node = root.child_json()
# # print(json.dumps(node, indent=2))

