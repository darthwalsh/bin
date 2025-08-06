#! /usr/bin/env uv run

"""Find strava activities with no effort set"""


# /// script
# dependencies = [
#   "strava-cli",
#   "stravalib",
# ]
# ///

import json
import os
from pathlib import Path
import webbrowser

import strava.api._helpers as strava_cli
from stravalib import Client

# Set up cache directory
cache_dir = Path.home() / "OneDrive" / "Apps" / "StravaNoEffort"
cache_dir.mkdir(parents=True, exist_ok=True)
cache_file = cache_dir / "exertion_cache.json"

# Load existing cache
cache = {}
if cache_file.exists():
  with open(cache_file, "r") as f:
    cache = json.load(f)

os.environ["SILENCE_TOKEN_WARNINGS"] = "true"  # strava-cli will handle token correctly
client = Client(requests_session=strava_cli.client)


for summary in client.get_activities(limit=100):
  if summary.type != "Run":
    continue

  activity_id = str(summary.id)

  if activity_id in cache:
    continue

  # Need detailed results to check exertion
  print(f"Fetching details for {summary.start_date_local} {summary.name}...")
  detailed_activity = client.get_activity(summary.id)
  
  if detailed_activity.perceived_exertion is not None:
    cache[activity_id] = True
    continue

  print("Opening activity in browser...")
  webbrowser.open(f"https://www.strava.com/activities/{activity_id}/edit")
  
with open(cache_file, "w") as f:
  json.dump(cache, f, indent=2)
