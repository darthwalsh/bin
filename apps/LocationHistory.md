---
tags:
  - data-hoarding
aliases:
  - timeline
---
I've been using Google Timeline for nearly a decade.

## Web Deprecation notice
- [x] Convert to local tracking on Android 📅 2025-06-01
	- [x] Take a cloud backup first:  /My Drive/Takeout/maps/
	- [x] Turn on local tracking, *looking at every setting for retention: make sure infinite*
	- [x] Check local retention is not set to 3 months
	- [x] Auto-deletion = DON'T
	- [x] Turn ON cloud blackup

> **Timeline is changing.**  
> **To avoid losing visits and routes, update your settings.**
> 
> If you'd like to keep your saved visits, you need to update your settings by **Jun 9, 2025**. To see your options, go to Timeline in the Google Maps app on your preferred smartphone.
> 
> After you do this, you'll only be able to use Timeline in the app.
> 
> If you're not ready to switch to the app
> You can still use Timeline on your web browser until Jun 9, 2025.
> 
> If you take no action by Jun 9, 2025, some or all of your data will be deleted. Timeline will remain on for your account, and your devices will continue saving new visits.

[Tips](https://www.reddit.com/r/GooglePixel/comments/1hdi88i/comment/m1xakgz/) for a good backup:

> Important: To turn on backup, auto-delete must be off.
> On your Android phone, open the Google Maps app ￼.
> Tap your profile picture or initial ￼ ￼ Your Timeline .
> At the upper right, tap the cloud ￼.
> If auto-delete is turned on, turn it off.
> To turn off auto-delete, tap Don’t auto delete activity.
> On the Backup screen, turn on Backup.

### My issues with the Timeline web UI
- If it wasn't sure about a location, it would often say "YourCity" and I'd have to look for that to fix it.
	- It would always fail to pick certain religious buildings, picking YourCity
- Often took multiple clicks for basic editing workflow
	- It should be one tap to convert Moving to walking or diving, the main activities
- No sanity check on walking, that it wasn't goin > 10mph
- Would miss obvious walks in GPS data
	- I gave up on tracking every dog walk I took; too much effort to split up Home time!
- Should use google calendar event locations when guessing which address I was at
Thought about writing a browser extension to address these, but I guess it's good I didn't invest in that!
## Tracking from Android
- [ ] See if using Google Takeout from Google Timeline from Android mobile app is "usable" ⏫ 
	- [ ] [Export Google Maps Timeline Data on Android : r/GoogleMaps](https://www.reddit.com/r/GoogleMaps/comments/1chlsst/export_google_maps_timeline_data_on_android/)
	- [ ] [google maps - How can I export my Location History now that this data is only stored locally on the phone? - Android Enthusiasts Stack Exchange](https://android.stackexchange.com/questions/257663/how-can-i-export-my-location-history-now-that-this-data-is-only-stored-locally-o?answertab=scoredesc#tab-top)
- [x] NEXT, try installing https://gpslogger.app/ ? ⏳ 2025-02-10 
	- [x] Didn't configure unrestricted battery, so it stopped logging after a day, oops: https://gpslogger.app/#sometimestheappwillnotlogforlongperiodsoftime -- set Unrestricted Battery now ✅ 2025-05-25
- [ ] Try uploading https://gpslogger.app/ data to i.e. darawich
## Viewing Google Timeline Takeout content
- [x] https://takeout.google.com/manage look in Google Drive for zip files ⏫
	- [x] My Drive/Takeout/takeout-20241118T044437Z-001.zip -002.zip
 
- [x] Try TimeLinize https://timelinize.com/docs/setup/install ⏫ ⏳ 2024-12-31
	- Needs `ffmpeg` and `vips` installed
  - [x] ~/Downloads/timelinize_0.0.2_darwin_arm64/timelinize
	- [x] Look in discord mentions
	- [x] See if it shows place name:
		- [asked on discord](https://discord.com/channels/1063526777844158535/1324237836618039326/1324237836618039326): not implemented yet
	- [x] try to search by place name -- CANNOT
- [x] https://timelinize.com/docs/data-sources/google-location-history

1. Other sources might be interesting?
	1. [ ] https://timelinize.com/docs/data-sources/android-text-messages ⏫ 
	2. https://timelinize.com/docs/data-sources/strava
	3. https://timelinize.com/docs/data-sources/contact-list
	4. https://timelinize.com/docs/data-sources/google-photos
	5. https://timelinize.com/docs/data-sources/facebook
	6. https://timelinize.com/docs/data-sources/x

NEXT if TimeLinize not good
- [ ] NEXT https://github.com/Freika/dawarich ⏫ ⏳ 2025-04-31
	- [ ] https://dawarich.app/docs/tutorials/track-your-location/
- [ ] [OwnTracks - Your location companion](https://owntracks.org/)
- [ ] https://www.reddit.com/r/GoogleMaps/comments/1gmpxhz/i_developed_a_website_to_visualize_and_filter/
- [ ] Overland android app not supported: https://github.com/OpenHumans/overland_android
- [ ] https://github.com/mholt/timeliner old version

NEXT
https://danq.me/2020/10/09/accidental-geohashing/ has some steps
>I found a setting in Google Takeout to export past location data in KML, rather than JSON, format. KML is understood by [GPSBabel](http://www.gpsbabel.org/) which can convert it into GPX. I can “cut up” the resulting GPX file using [a little grep-fu](https://gist.github.com/Dan-Q/311b032948189bf297da33e00dd62cc1) ([relevant xkcd](https://xkcd.com/208/)?) to get month-long files and import them into μLogger. Easy!

NEXT, could try apps like Moves and/or [[FitnessTracker#Gyroscope|Gyroscope]]