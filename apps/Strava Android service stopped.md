I often have the problem when taking a picture or switching to a resource-heavy app like Pokemon Go, that the Strava app will have stopped recording a run. I can open the app again and it will say:

> Strava has recovered from a problem and resumed your recording.
> **OK**

Just pushing OK is often not enough to fix the problem. You need to hit Stop-Resume to get the recording going again... if I already went a mile before checking it's frustrating to lose all that tracked data.
## battery unrestricted didn't help
2023-08-20 set Strava app to battery=unrestricted
2023-08-31 Service stopped working after taking a few pictures
*get more from google photos*
2023- Stopped.
2023- Stopped.
2023- Stopped.
2023- Stopped.
2023-08-31 Stopped.
2023-10-16 Stopped. Double checked, the Strava App is still marked Battery Unrestricted
2023-10-26 Stopped.
2023-11-25 Stopped.
2023-11-29 Stopped.
2024-01-21 Stopped after camera.
2024-02-21 Recording stopped.
2024-05-01 Stopped after camera.
2024-05-06 Stopped after camera.
2024-06-17 Stopped after camera. Phone system only had 90 hours uptime, so rebooting weekly wouldn't have helped...
2024-06-27 Stopped again
2025-02-08 Stopped after I switched to camera
## workaround adb
Found this [workaround](https://www.reddit.com/r/Strava/comments/9ins8e/solved_how_to_fix_gps_stopping_recording_during/) to try:
- [ ] adb shell `settings put global location_background_throttle_package_whitelist "com.strava"`
## debugging look for logs
https://android.stackexchange.com/questions/14430/how-can-i-view-and-examine-the-android-log
## restarter app
#app-idea 
- [ ] How to prevent this custom service from getting stopped at the same time?

datum:
- Strava recovered from a problem the widget stopped updating the time, and the notification went away
could collect the latest data from the Strava service and if it quits then give a notification warning to restart strava recording
- When recording stopped, the Auto-Paused seems to be left on, and the timer does not track up.