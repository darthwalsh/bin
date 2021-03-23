import browser_cookie3

cj = browser_cookie3.chrome()

st = [c for c in cj if 'strava' in c.domain and 'CloudFront-' in c.name]

print('; '.join(f'{c.name}={c.value}' for c in st))

print()

query = '&'.join(f'{c.name.removeprefix("CloudFront-")}={c.value}' for c in st)
print('https://heatmap-external-{switch:a,b,c}.strava.com/tiles-auth/run/gray/{zoom}/{x}/{y}.png?' + query)
