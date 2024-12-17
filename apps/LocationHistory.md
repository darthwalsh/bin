---
tags:
  - data-hoarding
---
I've been using Google Timeline for nearly a decade.

## Web Deprecation notice
- [ ] Export settings to Android 📅 2025-06-01 

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
## Tracking from Android
- [ ] See if using Google Takeout from Google Timeline from Android mobile app is "usable" ⏫ 
- [ ] NEXT, try https://gpslogger.app/ ?
## Viewing Google Timeline Takeout content
- [x] https://takeout.google.com/manage look in Google Drive for zip files ⏫
	- [x] My Drive/Takeout/takeout-20241118T044437Z-001.zip -002.zip
 
- [ ] Try TimeLinize https://timelinize.com/docs/setup/install ⏫ ⏳ 2024-12-17
	- Needs `ffmpeg` and `vips` installed
  - [x] ~/Downloads/timelinize_0.0.2_darwin_arm64/timelinize
	- [ ] Look in discord mentions
	- [ ] See if it shows place name
	- [ ] try to search by place name?
- [ ] https://timelinize.com/docs/data-sources/google-location-history 

1. Other sources might be interesting?
	1. https://timelinize.com/docs/data-sources/strava
	2. https://timelinize.com/docs/data-sources/android-text-messages
	3. https://timelinize.com/docs/data-sources/contact-list
	4. https://timelinize.com/docs/data-sources/google-photos
	5. https://timelinize.com/docs/data-sources/facebook
	6. https://timelinize.com/docs/data-sources/x

NEXT if TimeLinize not good
- [ ] https://github.com/Freika/dawarich
- [ ] https://www.reddit.com/r/GoogleMaps/comments/1gmpxhz/i_developed_a_website_to_visualize_and_filter/
- [ ] https://github.com/mholt/timeliner old version

NEXT
https://danq.me/2020/10/09/accidental-geohashing/ has some steps
>I found a setting in Google Takeout to export past location data in KML, rather than JSON, format. KML is understood by [GPSBabel](http://www.gpsbabel.org/) which can convert it into GPX. I can “cut up” the resulting GPX file using [a little grep-fu](https://gist.github.com/Dan-Q/311b032948189bf297da33e00dd62cc1) ([relevant xkcd](https://xkcd.com/208/)?) to get month-long files and import them into μLogger. Easy!
