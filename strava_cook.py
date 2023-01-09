import browser_cookie3
import webbrowser
import time

def get_cookies():
  cj = browser_cookie3.chrome()
  return [c for c in cj if 'strava' in c.domain and 'CloudFront-' in c.name]

st = get_cookies()
if 1 or not st:
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
