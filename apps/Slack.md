## Webhooks
Easiest integration: create a Slack App, pick a channel, get a URL to POST messages to. No OAuth needed.

More complex actions (replies per thread, DMs) require OAuth.

## Changing Status
- [ ] [CLI utility for changing Slack status](https://gist.github.com/AGresvig/ff269904abdb7826be9f54c9ab4d7d71)
- [ ] Webhook: [[strava]] run → change status to "running"; end → clear status

## Calling Slack from a CLI script
Slack's [search API](https://api.slack.com/methods/search.messages) supports `is:saved` to query saved-for-later items.
[[mcp#Auth|`mcptools` auth]] is not supported!

|                  | AI Option A: Slack MCP like Cursor                                         | AI Option B: REST API                              |
| ---------------- | -------------------------------------------------------------------------- | -------------------------------------------------- |
| App registration | None — reuse Cursor's public client ID `3660753192626.8903469228982`       | Register own Slack app with `search:read:*` scopes |
| Client secret    | Not needed — uses [PKCE](https://docs.slack.dev/authentication/using-pkce) | Needed (or PKCE if you enable it)                  |
| Endpoint         | `https://mcp.slack.com/mcp` (MCP JSON-RPC)                                 | `https://slack.com/api/search.messages`            |
| Enterprise risk  | Low — same app Cursor already authorized                                   | Enterprise may block new app installations         |
| My next steps    | related to [[withings.py]]                                                 | See [[Tasks#Slack]]                                |
