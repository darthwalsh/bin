import json
import sys

import yaml

# /// script
# dependencies = [
#   "pyyaml",
# ]
# ///


def str_presenter(dumper, data):
  if len(data.splitlines()) > 1:  # check for multiline string
    return dumper.represent_scalar("tag:yaml.org,2002:str", data, style="|")
  return dumper.represent_scalar("tag:yaml.org,2002:str", data)


yaml.add_representer(str, str_presenter)

o = json.loads(sys.stdin.read())
print(yaml.dump(o, allow_unicode=True, sort_keys=False))
