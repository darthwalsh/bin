---
aliases:
  - MyTube, YourTube, YourFeed, MultiYoutube
---
*note: I've called this idea different things in discussions, see `.aliases`* 
- [ ] See if [[ReadItLater#RainDrop]] could solve this problem?
- [ ] See if [Play](https://apps.apple.com/us/app/play-save-videos-watch-later/id1596506190) can solve though macOS desktop automation?

I've wanted some automations to improve my Youtube watching experience, avoiding opening the YouTube Feed. Maybe:
- Automatically adding videos from subscribed channels to a new playlist: **✅ Possible**
- Automatically picking which video to watch next based on partial watch-time: 
	- **❌ Impossible** using the REST API
	- a browser extension could get the data from youtube.com internal APIs, but that doesn't sync if you only use mobile app
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
# Queued videos is NOT possible
The current watch Queue is not listed at [YouTube Data API](https://developers.google.com/youtube/v3/docs)
# History is NOT possible
Watch History would tell you if whether a video was watched
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

## Quick-Add youtube video from playlist
#app-idea 
>add a youtube video straight to a playlist, without opening youtube.com. Main platforms: android, maybe macOS

- [ ] Probably easy to make small [[bin/AppScripts/README|AppScript]] and find a generic share-to-`POST` app for each platform?

[[IFTTT]]? No, not supported in the built-in Youtube app
[[Raycast]] mac? Seems not.
macOS app? [Play](https://apps.apple.com/us/app/play-save-videos-watch-later/id1596506190) *might work*, has custom-url quick-add and Shortcuts automations, but manual action to get into youtube temp-list
Browser extension? haven't searched