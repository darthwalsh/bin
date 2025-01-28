Goal: replace cron rules to run some logic based on entries in a google calendar.
Example: when personal calendar events start/stop, change my work [[Slack]] status from busy and back...

Open FR: [Trigger script on particular calendar event: 36753183](https://issuetracker.google.com/issues/36753183)

What isn't as helpful is a trigger that runs when event was created: https://stackoverflow.com/q/43242701/771768
## CalendarTriggerBuilder doesn't work
docs for [CalendarTriggerBuilder](https://developers.google.com/apps-script/reference/script/calendar-trigger-builder)
>Specifies a trigger that fires when a calendar entry is created, updated, or deleted.

Tried setting this up:
```js
function myFunction() {
     ScriptApp
      .newTrigger('findNewEvents')
      .forUserCalendar(Session.getActiveUser().getEmail())
      .onEventUpdated()
      .create()
}
```

- at 11:33AM created a calendar event 1:00-2:00PM
- Goal: get trigger to run at 1PM and 2PM
- Actual: trigger ran at 11:33AM...

## Calendar API webhooks
docs for setting up [push notifications](https://developers.google.com/calendar/api/guides/push)
[Heard](https://issuetracker.google.com/issues/36753183?pli=1) "the expiration and renewal is a bit of painful point"
- [ ] try this API 🔼 

## Use [[Home Assistant]]
- [ ] https://www.home-assistant.io/docs/automation/trigger/#calendar-trigger

## Use IFTTT
(Currently use IFTTT to automate creating Calendar events based on Strava runs...)

- [ ] https://ifttt.com/google_calendar/details
*Might be too expensive*

## Use Android app 
- [ ] look into https://macrodroidforum.com/wiki/index.php/Trigger:_Calendar_Event

## Gemini AI suggestion hallucinated a solution...
>  Install the Calendar Event Triggers service. This service allows you to trigger functions based on calendar events. Go to Extensions > Manage Add-ons and search for "Calendar Event Triggers". Install it and enable it for your project.
>  * Create triggers for your functions. Go to Edit > Current project's triggers. Click on Add trigger and set the following:
>  * Function: Choose the function you want to trigger (e.g., onCalendarEventStart).
>  * Event type: Select from Calendar.
>  * Event source: Choose All calendars.
>  * Event name: Select When an event starts.

Now, whenever a calendar event starts or ends, the corresponding function will be triggered.
