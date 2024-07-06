"""
Run with `pipx run`
Writes current strava routes to synced folder

The main interesting properties are elevation_gain (m) distance(m) and estimated_moving_time

- [ ] TODO move deleted to a Deleted/ subfolder, adding a deleted-date, and maybe a link to the strava activity?
- [ ] TODO add proper strava expired token handling
- [ ] TODO add some alias for this script?
"""

# /// script
# dependencies = ["stravalib"]
# ///

import json
import os
from stravalib import Client


dest = os.path.expanduser("~/OneDrive/Apps/StravaRoutes/")
existing = set(os.listdir(dest))


def get_client():
  # TODO this requires strava-cli to have been run recently
  access_token_json = os.path.expanduser("~/.strava-cli/access_token.json")
  with open(access_token_json) as f:
    config = json.load(f)
  return Client(access_token=config["access_token"])


client = get_client()
for route in client.get_routes():
  print(route.name)
  text = route.json(exclude={"athlete"}, indent=2)
  file_name = f"{route.id_str}.json"
  with open(os.path.join(dest, file_name), "w") as f:
    f.write(text)

  existing.discard(file_name)

if existing:
  print()
  print("Deleted:")
  for file_name in existing:
    with open(os.path.join(dest, file_name), "r") as f:
      print(file_name, json.load(f)["name"])
