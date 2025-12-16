"""Calculate days since last Strava run and write to cache file

Runs with uv run
This script is designed to be run periodically (e.g., via launchd) to update
a cache file that can be read quickly by the terminal prompt.

To reload launchd:
launchctl unload ~/code/bin/com.user.stravadays.plist
launchctl load ~/code/bin/com.user.stravadays.plist

To run once:
launchctl kickstart -k gui/$(id -u)/com.user.stravadays

To see status:
launchctl list | grep com.user.stravadays
"""

# /// script
# dependencies = [
#   "strava-cli",
#   "stravalib",
# ]
# ///

import os
from datetime import UTC, datetime

import strava.api._helpers as strava_cli
from stravalib import Client

cache_file = os.path.expanduser("~/.cache/strava-days.txt")

with open(cache_file, "w") as f:
  f.write("...strava_days.py starting")

os.environ["SILENCE_TOKEN_WARNINGS"] = "true"  # strava-cli will handle token correctly
client = Client(requests_session=strava_cli.client)

last_run = None
for activity in client.get_activities(limit=100):
  if activity.type == "Run":
    last_run = activity
    break

if last_run:
  now = datetime.now(UTC)
  last_run_utc = last_run.start_date
  if not last_run_utc.tzinfo:
    last_run_utc = last_run_utc.replace(tzinfo=UTC)
  
  days_since = (now - last_run_utc).days
  print(f"{days_since=}")
  emojis = "🏃" * (days_since - 2)
  if emojis:
    message = " " + last_run_utc.strftime("%A")[:3] + emojis
  else:
    message = ""
else:
  message = "⚠️ strava_days.py not found ⚠️"

with open(cache_file, "w") as f:
  f.write(message)
print(f"Adding to cache file: >>{message}<<")
