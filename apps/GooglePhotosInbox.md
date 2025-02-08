---
tags: app-idea
created: 2024-04-28
---
- [ ] Check if this exists ⏫ 
- [ ] Check if these projects are impacted by the Library API shutdown ⏳ 2025-02-01 

Goal: Your Google Photos is an inbox to process every photo. End state: in some album.
- [ ] With person-to-auto-albums, shouldn't have to process many photos (but would be nice to have workflow to add to pinned albums!)
- [ ] Should sync down the description, which I often add TODO text to: add with [[in.ps1]]
- [ ] Should sync down the location and time, which I would use from my [[gpx.py]] script
	- [ ] Separate android app: watch for new screenshots and edits the GPS exif meta data


https://support.google.com/photos/thread/12363001/viewing-photos-not-in-an-album?hl=en

https://support.google.com/photos/thread/12363001?hl=en&msgid=81969237

Answer with rclone commands to let you diff which photos are in some album vs in no album!
From pre-2020, earlier notes:
- http://webapps.stackexchange.com/questions/82693/how-can-i-view-google-photos-that-are-not-in-a-google-photos-album
	- https://github.com/jonagh/gapi-querier
		- [x] [Google Photos Library API will stop working March 31, 2025? · Issue #14 · jonagh/gapi-querier](https://github.com/jonagh/gapi-querier/issues/14)
	- Mass select everything in an album and Archive it?
		- Or, mass-shift the dates back by 1000 years, then restore them later
- Deprecated older libraries:
	- https://developers.google.com/gdata/docs/client-libraries
	- https://code.google.com/archive/p/google-gdata/wikis
	- https://code.google.com/archive/p/gdata-javascript-client/, 
	- suggest to use https://github.com/google/google-api-javascript-client

## Different idea to use browser extension
Chrome extension: Google photos inbox use some custom CSS to hide the archived ones. Maybe only in Search View.
- [ ] V2 click to toggle. Works in albums too
- [ ] V3 hide if in any album


