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

# Set up at https://developer.withings.com/dashboard/
CONFIG_FILE = Path.home() / ".withings"
with CONFIG_FILE.open() as file:
  CONFIG = pytoml.load(file)

CREDENTIAL_FILE = Path.home() / ".withings-credentials.json"


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


api = WithingsApi(get_credentials())

sleep_data = api.sleep_get_summary(
  data_fields=[GetSleepSummaryField.SLEEP_SCORE],
  startdateymd=arrow.utcnow().shift(days=-25),
  lastupdate=None,  # https://github.com/vangorra/python_withings_api/issues/92
)
series = getattr(sleep_data, "series", [])
print("Date\tSleepScore")
for serie in series:
  date_str = serie.date  # TODO needs to shift by one day or another????
  # date_str = serie.date.format("YYYY-MM-DD")
  score = serie.data.sleep_score
  score_str = "N/A" if score is None else str(score)
  print(f"{date_str}\t{score_str}")
