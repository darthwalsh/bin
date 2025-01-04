"""Publish GPX from strava to OSM

Run with `pipx run`

TODO implement --pick filtering out previous
  (see `git show 922df76fe9f14565e75b5e0fd4e2344f7a2590b4:gpx.ps1` for regex, but better to use actual date and Counter)
"""

# /// script
# dependencies = [
#   "cli-oauth2",
#   "strava-cli",
#   "stravalib>=2",
# ]
# ///

import argparse
from datetime import datetime
import json
from pathlib import Path
import time
import webbrowser

from oauthcli import OpenStreetMapAuth
import stravalib
import strava.api._helpers as strava_cli


parser = argparse.ArgumentParser(description='Publish GPX from strava to OSM')
parser.add_argument('-p', '--pick', action='store_true', help='Choose from recent activities')
parser.add_argument('-i', '--id', type=str, help='Download a specific Strava activity ID')


def strava_activity():
  client = stravalib.Client(requests_session=strava_cli.client)

  if args.id:
    return client.get_activity(args.id)
  if not args.pick:
    return next(client.get_activities(limit=1))

  for a in client.get_activities(limit=30):
    # distance_quantity = a.distance.quantity()
    # HACK this is documented to work: https://stravalib.readthedocs.io/en/latest/reference/api/stravalib.model.Duration.html#stravalib.model.Duration
    # but it fails with AttributeError: 'float' object has no attribute 'quantity'
    distance_quantity = stravalib.model.Distance(a.distance).quantity()
    
    elapsed = stravalib.model.Duration(a.elapsed_time).timedelta() # HACK ditto 
    sport = a.sport_type.root.rjust(7)[:7]
    name = a.name.ljust(50)[:50]  # TODO on windows, UTF-8 is getting messed up here
    dist = f"{distance_quantity.to('mile'):0.2f}s".rjust(11)
    print(a.id, a.start_date_local, sport, name, elapsed, dist, sep="   ")

  id = input("Paste Activity ID: ")
  return client.get_activity(id)


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


args = parser.parse_args()
activity = strava_activity()

gpx_file = download_gpx(activity.id)
gpx_id = upload_gpx(gpx_file, activity.start_date_local)
gpx_file.unlink()

webbrowser.open(f"https://www.openstreetmap.org/edit?gpx={gpx_id}")
