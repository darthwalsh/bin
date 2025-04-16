"""Publish GPX from strava to OSM

Run with `uv run`

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
import json
import re
import time
import webbrowser
import xml.etree.ElementTree as ET  # Not secure against DoS: for security use defusedxml or lxml
from datetime import datetime
from pathlib import Path

import requests
import strava.api._helpers as strava_cli
import stravalib
from oauthcli import OpenStreetMapAuth

parser = argparse.ArgumentParser(description="Publish GPX from strava to OSM")
parser.add_argument("-p", "--pick", action="store_true", help="Choose from recent activities")
parser.add_argument("-i", "--id", type=str, help="Download a specific Strava activity ID")
parser.add_argument("--traces", action="store_true", help="Print existing uploaded GPX traces")


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

    elapsed = stravalib.model.Duration(a.elapsed_time).timedelta()  # HACK ditto
    sport = a.sport_type.root.rjust(7)[:7]
    name = a.name.ljust(50)[:50]  # TODO on windows, UTF-8 is getting messed up here
    dist = f"{distance_quantity.to('mile'):0.2f}s".rjust(11)
    print(a.id, a.start_date_local, sport, name, elapsed, dist, sep="   ")

  id = input("Paste Activity ID: ")
  return client.get_activity(id)


def open_google_photos(start: datetime):
  webbrowser.open(f"https://photos.google.com/search/{start:%Y-%m-%d}")


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
  osm = get_osm()

  # https://wiki.openstreetmap.org/wiki/API_v0.6#Create:_POST_.2Fapi.2F0.6.2Fgpx.2Fcreate
  print(f"Using OSM API to upload {file}...")
  files = {"file": (file.name, file.read_bytes())}
  data = {
    "description": f"Run {start:%Y-%m-%d} looking for paths",
    "tags": "",
    "visibility": "trackable",
  }
  response = osm.post("gpx/create", files=files, data=data)
  response.raise_for_status()
  return int(response.text)


def show_traces():
  osm = get_osm()
  # https://wiki.openstreetmap.org/wiki/API_v0.6#List:_GET_/api/0.6/user/gpx_files
  response: requests.Response = osm.get("user/gpx_files")
  response.raise_for_status()

  root = ET.fromstring(response.content)
  traces = []
  for gpx_file in root.findall("gpx_file"):
    gpx_id = gpx_file.get("id")
    name = gpx_file.get("name").removesuffix(".gpx")
    description = gpx_file.find("description").text
    if m := re.match(r"Run \$?(\d{4}-\d{2}-\d{2}) looking for paths", description):
      activity_date = datetime.strptime(m.group(1), "%Y-%m-%d")
    else:
      upload_date = datetime.strptime(gpx_file.get("timestamp"), "%Y-%m-%dT%H:%M:%SZ")
      activity_date = upload_date.replace(hour=0, minute=0, second=0, microsecond=0)  # Approximation

    text = f"{activity_date.strftime('%Y-%m-%d')} {name} https://www.openstreetmap.org/edit?gpx={gpx_id}"
    traces.append((activity_date, text))
  traces.sort()
  for _, description in traces:
    print(description)


def get_osm():
  with (Path.home() / ".osm-secrets.json").open() as f:
    osm_config = json.load(f)
  scopes = ["write_gpx", "read_gpx"]
  auth = OpenStreetMapAuth(scopes=scopes, **osm_config).auth_code()
  return auth


args = parser.parse_args()
if args.traces:
  show_traces()
  exit()

activity = strava_activity()

open_google_photos(activity.start_date_local)

gpx_file = download_gpx(activity.id)
gpx_id = upload_gpx(gpx_file, activity.start_date_local)
gpx_file.unlink()

webbrowser.open(f"https://www.openstreetmap.org/edit?gpx={gpx_id}")
