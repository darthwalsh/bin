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


def get_message():
  run_dates = [activity.start_date_local for activity in client.get_activities(limit=100) if activity.type == "Run"]
  if not run_dates:
    return "⚠️ strava_days.py not found ⚠️"
  last_run = max(run_dates)
  delta = datetime.now(UTC) - last_run
  days_since = delta.days
  print(f"{days_since=} {delta=}")
  emojis = "🏃" * (days_since - 2)
  if not emojis:
    return ""
  return " " + last_run.strftime("%A")[:3] + emojis


print(f"START strava_days at {datetime.now(UTC)}")
message = get_message()
with open(cache_file, "w") as f:
  f.write(message)
print(f"Adding to cache file: >>{message}<<")
