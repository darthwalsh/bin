# Roku TV Remote — Python Web Server

## Problem

TCL Roku TV exposes ECP (External Control Protocol) on port 8060, but:
- No direct "set captions" API — only keypress simulation
- Browser→Roku blocked by CORS/mixed-content (HTTPS→HTTP, public→private network)
- Existing web remotes (tillbob/roku-web-remote) use Node.js; we want minimal Python

**Solution:** Python web server as proxy. Phone browser hits Pi, Pi hits Roku.

## Research: Existing Tools

| Tool | Language | Caption Toggle? |
|------|----------|-----------------|
| tillbob/roku-web-remote | Node.js | No |
| Home Assistant Roku | Python | No (media focus) |
| grahamplata/roku-remote | Go | No |
| RoMote (Android) | Kotlin | No |

**No existing tool toggles captions via `<closed-caption-mode>` query.** This is novel.

## V1 Scope

### Backend (Python + Flask or http.server)

```
GET  /                        → serve static HTML
POST /api/captions/toggle     → query mode, compute direction, send keypresses
```

Backend handles all ECP calls internally — frontend never talks to Roku directly.

### Caption Toggle Logic

Query `<closed-caption-mode>` from `/query/device-info`:

| Mode | Cycle Order | Direction to "Off" |
|------|-------------|-------------------|
| Off | ↓ | — |
| On always | ↓ | Up ×1 |
| On replay | ↓ | Up ×2 |
| On mute | ↓ | Up ×3 |

Observed values (from your testing):
- `When mute`
- `Instant replay`
- (need to confirm full cycle)

**Algorithm:**
1. GET `/query/device-info`, parse `<closed-caption-mode>`
2. Map current mode → target mode → compute Up/Down count
3. Navigate: `Info` → `Down` ×3 → `Select` → `Up`/`Down` ×N → `Select` → `Back`

### Frontend (static HTML)

```html
<input id="roku-ip" placeholder="192.168.86.208" onchange="localStorage.setItem('roku-ip', this.value)">
<button onclick="toggleCaptions()">Toggle Captions</button>
<script>
  document.getElementById('roku-ip').value = localStorage.getItem('roku-ip') || '';
</script>
```

Button calls `/api/captions/toggle` via `fetch()`, passing IP in request body.

## File Structure

```
roku-remote/
├── server.py          # Flask app
├── static/
│   └── index.html     # minimal UI
└── requirements.txt   # flask, requests
```

## Dependencies

- Python 3.10+
- `flask`
- `requests` (for Roku HTTP calls)

## Open Questions

1. **Exact caption mode cycle order?** Need to test on your TV:
   ```bash
   ROKU="192.168.86.208:8060"
   curl -s "http://$ROKU/query/device-info" | sed -n 's:.*<closed-caption-mode>\(.*\)</closed-caption-mode>.*:\1:p'
   ```
   Then cycle through settings manually and record order.

## Answered
2. **Navigate-to-settings required.** No system shortcut for caption toggle.
3. **Pi is primary deployment target.** Should also run easily from laptop for dev.

## Deployment
- [ ] Need to figure this out
- [ ] Run the server on my pi3?
- [ ] Want a good internal dns. Can I set up `http://roku/` from an internal DNS server?
	- [ ] DO NOT want to make a public DNS entry `roku.carlwa.com` with a private IP, see [[#DNS Rebinding Attacks]]
	- [ ] Good chance to set up a [[PiHole]]? (It's fine to just give the pi a static DNS and point the Google Wi-Fi at that)
### DNS Rebinding Attacks
Exposing private IPs can enable DNS Rebinding, a technique where a malicious website tricks a user's browser into making requests to an internal IP address (e.g., 192.168.1.1). This bypasses the browser's Same-Origin Policy, allowing the attacker to interact with local services like routers, smart home devices, or internal databases.

## V2 Ideas

### Auto-volume by app

```python
APP_VOLUMES = {
    "Disney Plus": 24,
    "YouTube": 20,
    "Netflix": 22,
    "HDMI1": 16,  # Switch
}
```

Poll `/query/active-app`, compare to last-known app, send `VolumeUp`/`VolumeDown` keypresses to delta.

**Caveat:** No "get current volume" API. Must track shadow state or reset to known baseline.

### YouTube deeplink

```bash
curl -X POST "http://$ROKU:8060/launch/837?contentId=dQw4w9WgXcQ"
```

YouTube app ID is `837`. `contentId` is the video ID.

### Disney Plus episode filter
- [ ] need to test that we can deep-link into specific episodes? Or... automate 50x `Down`?
 ast bluey episode lookup using text field??? ai-vector-embedding search over episode titles? (would be a nice premium feature)


## ECP Curl Commands (from PoC scripts)

**TV Setting Required:**
Settings > System > Advanced system settings > Control by mobile apps > **Permissive**

**Send keypress:**
```bash
ROKU="192.168.86.208:8060"
curl -s -X POST "http://$ROKU/keypress/VolumeUp"
curl -s -X POST "http://$ROKU/keypress/Down"
curl -s -X POST "http://$ROKU/keypress/Select"
```

**Query caption mode:**
```bash
curl -s "http://$ROKU/query/device-info" \
  | sed -n 's:.*<closed-caption-mode>\(.*\)</closed-caption-mode>.*:\1:p'
```

**Caption toggle nav sequence (WIP, needs mode mapping):**
```bash
# Navigate to caption settings
roku Info
roku Down; roku Down; roku Down
roku Select  # Accessibility and Language
roku Select  # Closed captioning
roku Up      # e.g. Captions on -> off
roku Select
```

## References

- [Roku ECP Docs](https://developer.roku.com/docs/developer-program/dev-tools/external-control-api.md)
- [ECP Gist (pseudosavant)](https://gist.github.com/pseudosavant/89b9b8ba1e42f6eaf36fc7af49f40fe4)
- [Home Assistant Roku](https://www.home-assistant.io/integrations/roku/)
