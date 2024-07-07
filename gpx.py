"""Publish GPX from strava to OSM

Run with `pipx run`

TODO implement param -pick "Optionally, choose from recent activities"
  (see git history for regex filtering out previous, but better to use actual date and Counter)
TODO implement param -id "Optionally, paste in a specific strava activity ID"
"""

# /// script
# dependencies = [
#   "cli-oauth2",
#   "strava-cli",
#   "stravalib",
# ]
# ///

from datetime import datetime
import json
from pathlib import Path
import time
import webbrowser

from oauthcli import OpenStreetMapAuth
import stravalib
import strava.api._helpers as strava_cli


def latest_activity():
  client = stravalib.Client(requests_session=strava_cli.client)
  return next(client.get_activities(limit=1))


def download_gpx(id):
  start = time.time()

  print(f"Opening browser to download Strava activity {id} ...")
  webbrowser.open(f"https://www.strava.com/activities/{id}/export_gpx")

  timeout = 20
  while time.time() - start < timeout:
    for file in (Path.home() / "Downloads").glob("*.gpx"):
      if file.stat().st_mtime >= start:
        return file
    time.sleep(0.1)
  raise RuntimeError("Timeout waiting for GPX file to download")


def upload_gpx(file: Path, start: datetime):
  with (Path.home() / ".osm-secrets.json").open() as f:
    osm_config = json.load(f)
  auth = OpenStreetMapAuth(scopes=["write_gpx"], **osm_config).auth_code()

  # https://wiki.openstreetmap.org/wiki/API_v0.6#Create:_POST_.2Fapi.2F0.6.2Fgpx.2Fcreate
  print(f"Using OSM API to upload {file}...")
  files = {"file": (file.name, file.read_bytes())}
  data = {
    "description": f"Run {start:%Y-%m-%d} looking for paths",
    "tags": "",
    "visibility": "trackable",
  }
  response = auth.post("gpx/create", files=files, data=data)
  response.raise_for_status()
  return int(response.text)


activity = latest_activity()

gpx_file = download_gpx(activity.id)
gpx_id = upload_gpx(gpx_file, activity.start_date_local)
gpx_file.unlink()

webbrowser.open(f"https://www.openstreetmap.org/edit?gpx={gpx_id}")
