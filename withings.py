#! /usr/bin/env uv run
"""Get Withings data"""

# /// script
# dependencies = [
#   "withings-api",
#   "pytoml",
#   "arrow",
# ]
# ///

import json
from pathlib import Path

import arrow
import pytoml
from withings_api import AuthScope, Credentials2, GetSleepSummaryField, WithingsApi, WithingsAuth
from withings_api.common import UserGetDeviceDevice

from withings_fmt import (
  ANSI_BG_RED,
  ANSI_BOLD,
  ANSI_RESET,
  fmt_date,
  fmt_sleep_axis,
  fmt_sleep_bar,
  fmt_time,
  score_to_ansi_color,
)

# Set up at https://developer.withings.com/dashboard/
CONFIG_FILE = Path.home() / ".withings"
with CONFIG_FILE.open() as file:
  CONFIG = pytoml.load(file)

CREDENTIAL_FILE = Path.home() / ".withings-credentials.json"

DAYS_TO_SHOW = 7


def save_credentials(creds, file_path=CREDENTIAL_FILE):
  """Save credentials to JSON file"""
  try:
    with file_path.open("w") as file:
      json.dump(
        {
          "access_token": creds.access_token,
          "token_type": creds.token_type,
          "refresh_token": creds.refresh_token,
          "userid": creds.userid,
          "client_id": creds.client_id,
          "consumer_secret": creds.consumer_secret,
          "expires_in": creds.expires_in,
          # store as epoch seconds so ArrowType can parse it back
          "created": creds.created.int_timestamp,
        },
        file,
      )
  except Exception:
    file_path.unlink()
    raise


def get_credentials():
  if CREDENTIAL_FILE.exists():
    with CREDENTIAL_FILE.open() as file:
      creds = Credentials2.parse_raw(file.read())
      is_expired = creds.created.shift(seconds=creds.expires_in) < arrow.utcnow()
      if not is_expired:
        return creds
      print("Refreshing token")
      api = WithingsApi(creds)
      api.refresh_token()
      save_credentials(api.get_credentials())
      return api.get_credentials()

  auth = WithingsAuth(
    client_id=CONFIG["apikey"],
    consumer_secret=CONFIG["apisecret"],
    callback_uri="http://localhost:8080/callback",
    # https://developer.withings.com/developer-guide/v3/integration-guide/public-health-data-api/get-access/oauth-authorization-url
    scope=(
      AuthScope.USER_INFO,
      AuthScope.USER_METRICS,
      AuthScope.USER_ACTIVITY,
    ),
  )

  authorize_url = auth.get_authorize_url()
  print(f"Please authorize the application by visiting this URL: {authorize_url}")

  authorization_code = input("Enter the code from the URL: ")

  creds = auth.get_credentials(authorization_code)
  save_credentials(creds)
  return creds


# Battery levels per Withings docs: high (> 75%), medium (> 30%), low.
# Score values drive the same red→green color scale used for sleep scores.
# Not possible to get exact percentages or detect low-battery/power-reserve
# https://developer.withings.com/api-reference/#tag/user/operation/userv2-getdevice:~:text=Lingo%20Sensor-,battery,-string
BATTERY_LEVEL_PCT: dict[str, tuple[int, int]] = {
  "high": (75, 100),
  "medium": (30, 75),
  "low": (0, 30),
}

WATCH_KEYWORDS = ("scanwatch", "steel", "move", "pulse", "activité", "activite")
WATCH_BATTERY_LOW_PCT = 30


def _is_watch(device: UserGetDeviceDevice) -> bool:
  return any(kw in device.model.lower() for kw in WATCH_KEYWORDS)


def _fmt_battery(device: UserGetDeviceDevice) -> str:
  level = device.battery.lower()
  if level not in BATTERY_LEVEL_PCT:
    return f"{ANSI_BG_RED}{ANSI_BOLD}⚠ UNKNOWN BATTERY: '{device.battery}'{ANSI_RESET}"
  lo, hi = BATTERY_LEVEL_PCT[level]
  color = score_to_ansi_color(hi)
  label = f"{device.battery} ({lo}-{hi}%)"
  return f"{color}{label}{ANSI_RESET}"


api = WithingsApi(get_credentials())

device_data = api.user_get_device()
watch_battery_low = False
for device in device_data.devices:
  battery_str = _fmt_battery(device)
  print(f"{device.model} ({device.type}): {battery_str}")
  if _is_watch(device) and BATTERY_LEVEL_PCT.get(device.battery.lower(), (100, 100))[1] <= WATCH_BATTERY_LOW_PCT:
    watch_battery_low = True

print()

sleep_data = api.sleep_get_summary(
  data_fields=[GetSleepSummaryField.SLEEP_SCORE],
  startdateymd=arrow.utcnow().shift(days=-(DAYS_TO_SHOW + 5)),  # fetch extra to cover gaps
  lastupdate=None,  # https://github.com/vangorra/python_withings_api/issues/92
)
series = getattr(sleep_data, "series", [])

# Key by local date string "YYYY-MM-DD" so we can detect missing days
by_date: dict[str, object] = {}
for serie in series:
  key = serie.date.format("YYYY-MM-DD")
  by_date[key] = serie

today = arrow.now()
date_col_width = len("Thu Apr  9")  # fixed width for formatted date
score_col_width = 3  # e.g. "90 " or "?? "

# Axis prefix aligns with bar in row layout: "{score}  {date}  {start_time}  {bar}"
axis_prefix = " " * (score_col_width + 2 + date_col_width + 2 + 5)
print(axis_prefix + fmt_sleep_axis())

for offset in range(-DAYS_TO_SHOW, 0):
  day = today.shift(days=offset)
  key = day.format("YYYY-MM-DD")
  date_str = fmt_date(day)

  if key not in by_date:
    print(f"{'??':<{score_col_width}}  {date_str:<{date_col_width}}")
    continue

  serie = by_date[key]
  score = serie.data.sleep_score
  if score is None:
    colored_score = f"{'??':<{score_col_width}}"
  else:
    color = score_to_ansi_color(score)
    colored_score = f"{color}{score:<{score_col_width}}{ANSI_RESET}"

  start_str = fmt_time(serie.startdate)
  end_str = fmt_time(serie.enddate)
  bar = fmt_sleep_bar(serie.startdate, serie.enddate)

  end_date_str = fmt_date(serie.enddate)
  print(f"{colored_score}  {date_str}  {start_str}  {bar}  {end_str} {end_date_str}")

if watch_battery_low:
  print()
  print(f"{ANSI_BG_RED}{ANSI_BOLD}WATCH BATTERY LOW!{ANSI_RESET}")
