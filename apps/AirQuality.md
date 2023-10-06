
- [ ] Update with my choice -- no good existing apps... [Status of Airwyn App? - General - PurpleAir Community](https://community.purpleair.com/t/status-of-airwyn-app/4482/5)
- [ ] Review/share app I'm using: [Plume Labs: Air Quality App](https://play.google.com/store/apps/details?id=com.plumelabs.air)
	- has a widget
	- has forecast
	- different: Plume's default AQI seems more impacted by Ozone numbers, but maybe O3 is worse for me?
## APIs for Air Quality apps

### PurpleAir

- [ ] Links to PurpleAir API docs
- Account starts with million credits, then it's a few credits per API call, so maybe 1 cent
- Existing [Airwyn App](https://community.purpleair.com/t/status-of-airwyn-app/4482/5) is dead
- Existing [PurpleAir Companion](https://play.google.com/store/apps/details?id=com.eddroid.pacomp) looks good, but is end-of-life. My review:
>App looks like exactly what I wanted, but I can't recommend installing it because the app plans to be retired and de-listed from the play store at the end of 2023. It makes sense that the developer won't keep supporting it after Purple changed their pricing policies... if they were willing to publish the code to GitHub they would be awesome though!

### IQAir

- App: [IQAir AirVisual | Air Quality](https://play.google.com/store/apps/details?id=com.airvisual&hl=en_US&gl=US)

### AirNow API - Web Services

https://docs.airnowapi.org/webservices

- Current Observations by reporting area
- Observations by bounding box
- Forecasts by reporting area
- Reporting Areas by zip or lat/long
- Free

App: [Air quality app & AQI widget](https://play.google.com/store/apps/details?id=com.elecont.airquality&hl=en_US&gl=US) uses a few providers: AirNow and incorrect Copernicus. My review:
>Looks powerful and has cool widgets, but the 2.5 AQI data is completely wrong! This app shows the PM2.5 AQI as a safe *39* now in dozens of stations in Marin County, California--except AirNow/PurpleAir/IQAir all agree it's in the hazardous 90-150 range! Something is glitchy with the data quality, at least where I live.