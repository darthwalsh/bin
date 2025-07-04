"""Publish GPX from strava to OSM

Run with `uv run`

Requires
  1. 1password op CLI logged in to my account
  2. strava_cli installed, `strava config` with https://www.strava.com/settings/api and `strava login`
"""

# /// script
# dependencies = [
#   "cli-oauth2",
#   "questionary",
#   "strava-cli",
#   "stravalib>=2",
# ]
# ///

import argparse
import json
import re
import subprocess
import time
import webbrowser
import xml.etree.ElementTree as ET  # Not secure against DoS: for security use defusedxml or lxml
from datetime import datetime, timedelta
from functools import cache
from pathlib import Path
from typing import NamedTuple

import questionary
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

  uploaded = set()
  for gpx_file in gpx_files():
    if m := re.match(r"Run \$?(\d{4}-\d{2}-\d{2}) looking for paths", gpx_file.description):
      uploaded.add(m.group(1))

  choices = []
  for a in client.get_activities(limit=30):
    if a.start_date_local.strftime("%Y-%m-%d") in uploaded:
      # HACK if there are multiple activities on the same day, we'll skip all, but this is a good metric
      continue

    # distance_quantity = a.distance.quantity()
    # HACK this is documented to work: https://stravalib.readthedocs.io/en/latest/reference/api/stravalib.model.Duration.html#stravalib.model.Duration
    # but it fails with AttributeError: 'float' object has no attribute 'quantity'
    distance_quantity = stravalib.model.Distance(a.distance).quantity()

    elapsed = stravalib.model.Duration(a.elapsed_time).timedelta()  # HACK ditto
    sport = a.sport_type.root.rjust(7)[:7]
    name = a.name.ljust(50)[:50]  # TODO on windows, UTF-8 is getting messed up here
    dist = f"{distance_quantity.to('mile'):0.2f}s".rjust(11)

    display = f"{a.start_date_local.replace(tzinfo=None)}   {sport}   {name}   {elapsed}   {dist}"
    choices.append({"name": display, "value": a})

  choice = questionary.select(
    "Choose an activity:",
    choices=choices,
    use_indicator=True,
  ).ask()
  if not choice:
    exit()
  return choice


def open_google_photos(start: datetime):
  """Google Photos doesn't index photos for several hours, so the search could fail."""
  if datetime.now(start.tzinfo) - start < timedelta(days=2):
    webbrowser.open("https://photos.google.com/")
  else:
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
  # https://wiki.openstreetmap.org/wiki/API_v0.6#Create:_POST_.2Fapi.2F0.6.2Fgpx.2Fcreate
  print(f"Using OSM API to upload {file}...")
  files = {"file": (file.name, file.read_bytes())}
  data = {
    "description": f"Run {start:%Y-%m-%d} looking for paths",
    "tags": "",
    "visibility": "trackable",
  }
  response = get_osm().post("gpx/create", files=files, data=data)
  response.raise_for_status()
  return int(response.text)


class GpxFile(NamedTuple):
  id: str
  name: str
  user: str
  visibility: str
  timestamp: datetime
  description: str
  tags: list[str]


def gpx_files() -> list[GpxFile]:
  # https://wiki.openstreetmap.org/wiki/API_v0.6#List:_GET_/api/0.6/user/gpx_files
  response: requests.Response = get_osm().get("user/gpx_files")
  response.raise_for_status()
  
  root = ET.fromstring(response.content)
  return [
    GpxFile(
      id=gpx_file.get("id"),
      name=gpx_file.get("name"), 
      user=gpx_file.get("user"),
      visibility=gpx_file.get("visibility"),
      timestamp=datetime.strptime(gpx_file.get("timestamp"), "%Y-%m-%dT%H:%M:%SZ"),
      description=gpx_file.find("description").text,
      tags=[tag.text for tag in gpx_file.findall("tag")],
    )
    for gpx_file in root.findall("gpx_file")
  ]


def show_traces():
  traces = []
  for gpx_file in gpx_files():
    name = gpx_file.name.removesuffix(".gpx")
    if m := re.match(r"Run \$?(\d{4}-\d{2}-\d{2}) looking for paths", gpx_file.description):
      activity_date = datetime.strptime(m.group(1), "%Y-%m-%d")
    else:
      activity_date = gpx_file.timestamp.replace(hour=0, minute=0, second=0, microsecond=0)  # Approximation

    text = f"{activity_date.strftime('%Y-%m-%d')} {name} https://www.openstreetmap.org/edit?gpx={gpx_file.id}"
    traces.append((activity_date, text))
  traces.sort()
  for _, description in traces:
    print(description)


@cache
def get_osm():
  osm_auth_op_id = "pihxghocs2meenfg4mqnpe433i"
  item = subprocess.check_output(["op", "item", "get", osm_auth_op_id, "--format", "json"], text=True)
  item = json.loads(item)
  fields = {field["label"]: field.get("value") for field in item["fields"]}
  # MAYBE use https://github.com/wandera/1password-client

  return OpenStreetMapAuth(fields["username"], fields["credential"], scopes=["write_gpx", "read_gpx"]).auth_code()


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
