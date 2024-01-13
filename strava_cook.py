import base64
import json
import os
import subprocess
import time

from stravacookies import StravaCookieFetcher
from firebase_admin import initialize_app, credentials, firestore


def get_cookies():
  cookieFetcher=StravaCookieFetcher()
  with open(os.path.expanduser("~/.pw/strava.txt")) as f:
    stravaPassword = f.read().strip()
  cookieFetcher.fetchCookies('darthwalsh@gmail.com', stravaPassword)
  return cookieFetcher.getCookieString()


query = get_cookies()
print('https://heatmap-external-{switch:a,b,c}.strava.com/tiles-auth/run/gray/{zoom}/{x}/{y}.png?' + query)
print()


def get_user_id():
  output = subprocess.check_output('strava profile -o json'.split())
  return json.loads(output)['id']

def write_to_firestore():
  cred_path = os.path.expanduser('~/.keys/runtheglobe-8996a2b0c37c.json')
  cred = credentials.Certificate(cred_path)
  initialize_app(cred)
  db = firestore.client()

  query_d = dict(q.split('=') for q in query.split('&'))
  policy = query_d['Policy']
  decoded = base64.b64decode(policy.replace("_", "=")).decode()
  policy = json.loads(decoded)
  dateLessThan = policy['Statement'][0]['Condition']['DateLessThan']['AWS:EpochTime']
  expiration = dateLessThan * 1000
  print("Strava cookie expiration:", time.ctime(dateLessThan))

  # schema: https://github.com/darthwalsh/RunTheGlobe/blob/09a339fc0535e5dc2f877b03c29e10d27a0466ce/www/cloud.js#L175
  db.collection('users').document(str(get_user_id())).update(
    {'stravaCookie': {'cookieQuery': query, 'expires': expiration}}
  )

  print('Wrote to Firestore')

write_to_firestore()
