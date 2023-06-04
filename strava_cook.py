import base64
import json
import os
import subprocess
import time
import webbrowser

import browser_cookie3
import firebase_admin
from firebase_admin import credentials, firestore


def get_cookies():
  cj = browser_cookie3.chrome()
  return [c for c in cj if 'strava' in c.domain and 'CloudFront-' in c.name]

st = get_cookies()
if not st:
  print('No Strava cookies found. Opening heatmap')
  print('!!!Interaction needed!!! Dismiss the modal!')
  print()
  webbrowser.open('https://www.strava.com/heatmap')
  for _ in range(10):
    time.sleep(1)
    st = get_cookies()
    if st: break
  else:
    print('Still no Strava cookies found :(')
    exit(1)
  

print('; '.join(f'{c.name}={c.value}' for c in st))

print()

query = '&'.join(f'{c.name.removeprefix("CloudFront-")}={c.value}' for c in st)
print('https://heatmap-external-{switch:a,b,c}.strava.com/tiles-auth/run/gray/{zoom}/{x}/{y}.png?' + query)
print()


def get_user_id():
  output = subprocess.check_output('strava profile -o json'.split())
  return json.loads(output)['id']

def write_to_firestore():
  cred_path = os.path.expanduser('~/.keys/runtheglobe-8996a2b0c37c.json')
  cred = credentials.Certificate(cred_path)
  firebase_admin.initialize_app(cred)
  db = firestore.client()

  policy, = (c.value for c in st if c.name == 'CloudFront-Policy')
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
