I often have the problem when taking a picture or switching to a resource-heavy app like Pokemon Go, that the Strava app will have stopped recording a run. I can open the app again and it will say there was a problem and restart tracking, but if I already went a mile it's frustrating.
## battery unrestricted didn't help
2023-08-20 set Strava app to battery=unrestricted
2023-08-31 Service stopped working after taking a few pictures
## workaround adb
Found this [workaround](https://www.reddit.com/r/Strava/comments/9ins8e/solved_how_to_fix_gps_stopping_recording_during/) to try:
- [ ] adb shell `settings put global location_background_throttle_package_whitelist "com.strava"`
## debugging look for logs
https://android.stackexchange.com/questions/14430/how-can-i-view-and-examine-the-android-log
## restarter app
#app-idea 
datum:
- Strava recovered from a problem the widget stopped updating the time, and the notification went away
could collect the latest data from the Strava service and if it quits then give a notification warning to restart strava recording
- [ ] How to prevent this custom service from getting stopped at the same time?