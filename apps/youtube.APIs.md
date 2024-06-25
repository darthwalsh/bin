*note: I've called this idea MyTube, YourTube, YourFeed, or MultiYoutube in discussions* 

I've wanted some automations to improve my Youtube watching experience, avoiding opening the YouTube Feed. Maybe:
- Automatically adding videos from subscribed channels to a new playlist: **✅ Possible**
- Automatically picking which video to watch next based on partial watch-time: **❌ Impossible**
	- maybe HTTP URL that 302 -> redirects to the video
- Automatically removing videos after watching: **✅ Possible**

# List My Playlists
`GET https://www.googleapis.com/youtube/v3/playlists?part=snippet&mine=true`
https://developers.google.com/youtube/v3/docs/playlists/list
- Use `pageToken=.nextPageToken` to paginate
- `maxResults` defaults to 5, max 50
-  the `snippet` property contains properties like `title`  and `timeCreated`.

# List Videos in Playlist
`GET https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=$ID_FROM_URL`
https://developers.google.com/youtube/v3/docs/playlistItems/list
returns values in https://developers.google.com/youtube/v3/docs/playlistItems#
- Sorted like in playlist, also has `.position`

# Getting whether a video was watched is NOT possible
Can the API return the playback amount, which drives the red bar at the bottom of the thumbnail when viewing playlist?
- API response https://developers.google.com/youtube/v3/docs/videos#resource doesn't contain the "you've watched this far, resume video at 123s"
- https://stackoverflow.com/questions/41478952/workaround-for-retrieving-users-youtube-watch-history says the API stopped supporting this in 2016
- Request to get Watch History from v3 API was closed Won't Fix: https://issuetracker.google.com/issues/35172816
- Can't read Watch History from API: https://stackoverflow.com/questions/30849284/how-to-get-watched-history-of-youtube-user-using-youtube-javascript-api
- "Best" solution would either be browser scraping or a chrome extension
- Also explained here: https://stackoverflow.com/questions/46987690/tracking-youtube-watch-history

## History Workaround
- [ ] Try a PoC for whatever might best
	- Browser scraping with i.e. bookmarklet
	- Chrome extension could write to a better database
	- Export Google Takeout data