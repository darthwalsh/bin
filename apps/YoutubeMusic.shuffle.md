## Solution
Just use `/watch` without v, and with `&shuffle=1`
https://music.youtube.com/watch?list=THE_PLAYLIST_ID&shuffle=1
## Problem: How to Shuffle Automatically
- YouTube Music lets you **toggle shuffle** manually in the UI — either via the shuffle button near the playback controls or via the playlist’s menu.
- There’s _no **official**_ way to encode shuffle into a static URL for automatic random start order. That means your link can’t guarantee a different starting song each time purely via query parameters.
Goal: get Pre-Run playlist to shuffle when playing?
- [-] ask Google Assistant to “shuffle play `PLAYLIST` on YouTube Music” which emulates the shuffle action programmatically. ❌ 2026-01-29
	- didn't work, gave feedback that it always played in-order
- [-] Using `&index=5` doesn't work (at least on desktop) ❌ 2026-01-29
## Orig Idea: Not needed
#app-idea-done 
- [ ] PWA that will redirect using `&v=Zh9p-6JfrSo` with random selection from playlist??
- [ ] Tools like [YouTube Playlist Randomizer](https://playlistrandomizer.com/?utm_source=chatgpt.com) sites take your playlist URL and generate a new _shuffled_ version that you can open and share. These effectively reorder the playlist before playback?
- [x] SPIKE: will it work for some automated way I can open a `example.com/randomizer` URL, that gets `HTTP` redirected, into YT URL?
	- ChatGPT: when Chrome follows your 302 to `music.youtube.com/...`, it will typically hand off to the app.
	- [ ] Consider returning an **`intent:` URL**
