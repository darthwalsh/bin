---
tags:
  - app-idea
created: 2024-04-28
---
- [x] Check if this exists ⏫
- [x] Check if these projects are impacted by the Library API shutdown ⏳ 2025-02-01
	- [x] gapi-querier asked

Goal: Your Google Photos is an inbox to process every photo. End state: in some album.
- [ ] With person-to-auto-albums, shouldn't have to process many photos (but would be nice to have workflow to add to pinned albums!)
- [ ] Should sync down the description, which I often add TODO text to: add with [[in.ps1]]
- [ ] Should sync down the location and time, which I would use from my [[gpx.py]] script
	- [ ] OR, Instead of struggling to download photos&metadata from Google photos, what about setting up a parallel upload to OneDrive and having the script download those
	- [ ] Separate android app: watch for new screenshots and edits the GPS exif meta data



## Google Photos API going away, affecting some tools
Big comment complaint thread: https://issuetracker.google.com/issues/368816420#comment6

At [https://developers.google.com/photos/support/updates](https://developers.google.com/photos/support/updates) I noticed

> ### Listing, searching, and retrieving media items and albums
> 
> **What's changing:** You can now only list, search, and retrieve albums and media items that were created by your app.
> 
> **What you can do:**
> 
> - If your app needs users to select photos or albums from their entire library, use to the new [Google Photos Picker API](https://developers.google.com/photos/picker/guides/get-started-picker). This provides a secure and user-friendly way for users to grant access to specific content.
> - If your app relies on accessing the user's entire library, you may need to re-evaluate your app or consider alternative approaches.

> As shown on the [updated Authorization page](https://developers.google.com/photos/overview/authorization#library-api-scopes), the following scopes will be removed from the Library API after March 31, 2025:
> 
> - `photoslibrary.readonly`
> - `photoslibrary.sharing`
> - `photoslibrary`

i.e. [`mediaItems.list`](https://developers.google.com/photos/library/reference/rest/v1/mediaItems/list) will soon be

> limited to interacting with media items created by your app.
### rclone CLI
found in https://support.google.com/photos/thread/12363001?hl=en&msgid=81969237 and https://support.google.com/photos/thread/12363001/viewing-photos-not-in-an-album?hl=en
Answer with rclone commands to let you diff which photos are in some album vs in no album!
```
rclone ls gphotopt:album -P # lists all photos in each album, but doesn't list them if not in an album
rclone lsf gphotopt:media/by-year -P # lists all file names for ***all*** images
```

Forum https://forum.rclone.org/t/add-the-new-google-photos-picker-api-to-rclone/47938/9
> downloading all albums and shared albums (that's currently possible) won't be possible once the new API changes are fully rolled out and previous API is disabled

Forum https://forum.rclone.org/t/fix-google-photos/47684/5 Discusses challenges in remote-debugging a browser to scrape the Photos webapp
#### docs
https://rclone.org/googlephotos/#albums
>Rclone can only upload files to albums it created.

>[!important] Google Photos API strips EXIF!
that means that location data can't be copied to GPX mapping, without relying on timestamps 
### gapi-querier
- https://github.com/jonagh/gapi-querier
- [x] [Google Photos Library API will stop working March 31, 2025? · Issue #14 · jonagh/gapi-querier](https://github.com/jonagh/gapi-querier/issues/14)

## Google StackExchange manual webapp approach
http://webapps.stackexchange.com/questions/82693/how-can-i-view-google-photos-that-are-not-in-a-google-photos-album

Mass select everything in an album and Archive it?
- doesn't work to Archive photos in an album view... but from regular search can put in name of Album and the photos show up.
- If recently renamed album, will need to wait some times, like a few days.
- If recently added photo to album, need to wait more than a few minutes
	- in one test, made change... a few minutes later, not showing in sarch. then 24 hours later the photos *did* show up in search

Albums for me to search before looking at inbox each time
- https://photos.google.com/search/AutoJenna
- https://photos.google.com/search/iLoveHue
- https://photos.google.com/search/lifeAtADSK

### ALTERNATIVE: mass-shift dates
In google photos album view, can't archive, but *can* shift the dates to the eleventh century
1. mass-shift the dates back by 1000 years
2. See what photos are left in inbox
3. then restore them later

## Google Takeout approach
https://support.google.com/photos/thread/12363001?hl=en&msgid=81969237
>Basically (I think that) what you suggest is:
> 1. Download all photos to a computer 
> 2. Download all photos that are in an album to the computer
> 3. Compare both sets to get a folder with all photos that are NOT in an album
> 4. Add these photos to an album (can be done by uploading manually directly in an album)

- [x] Created takeout **uploading to OneDrive**, see if it worked ⏳ 2025-02-27
Some Google->OneDrive failed: generated 207 x 2GB zip files, but several uploads failed; only 189 uploaded.
In `/Users/walshca/Library/CloudStorage/OneDrive-Personal/Apps/Google⁠ Download Your Data`
- [ ] Explore metadata in first/last/etc?
- [x] Delete old takeouts that are taking up space ⏳ 2025-04-27
## Deprecated older libraries
- https://developers.google.com/gdata/docs/client-libraries
- https://code.google.com/archive/p/google-gdata/wikis
- https://code.google.com/archive/p/gdata-javascript-client/, 
- suggest to use https://github.com/google/google-api-javascript-client

## Different idea to use browser extension
Chrome extension: Google photos inbox use some custom CSS to hide the archived ones. Maybe only in Search View.
- [ ] V2 click to toggle. Works in albums too
- [ ] V3 hide if in any album


