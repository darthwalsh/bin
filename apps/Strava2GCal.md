Automates creating [[GCal]] events for each past [[Strava]] activity, using [[CloudAutomation#Zapier]]
Converting into calendar events with formatted details (activity type, distance, duration, pace, and a link to the activity).

1. Strava event New Athlete Activity
2. Google Calendar - Create Detailed Event

YAML export:
```yaml
name: Add new Strava activities as events in Google Calendar
type: run
zapId: "126012246"
engine: series_skip_errors

steps:
  - id: "126012246"
    app: StravaCLIAPI@1.4.2
    type: read
    action: new_athlete_activity

  - id: "126012247"
    app: GoogleCalendarCLIAPI@1.10.10
    type: write
    action: detailed_event
    params:
      calendarid: <SNIP>@group.calendar.google.com
      summary: "{{126012246__type}} {{126012246__distance_in_miles}} {{126012246__name}}"
      start__dateTime: "{{126012246__start_date}}"
      end__dateTime: "{{126012246__start_date}} +{{126012246__elapsed_time}}s"
      description: |
        {{126012246__type}}: {{126012246__name}}
        {{126012246__moving_time_pretty}} duration
        {{126012246__distance_in_miles}} miles @{{126012246__pace_per_mile}} min/mile
        {{126012246__activity_url_generated}}
      location: "{{126012246__start_latlng}}"
      all_day: false
      conferencing: "no"
      visibility: default
      reminders__useDefault: "yes"
      colorId: "6"
    meta:
      selectedGives:
        126012246__type: Type
        126012246__name: Name
        126012246__moving_time_pretty: Moving Time Pretty
        126012246__distance_in_miles: Distance In Miles
        126012246__pace_per_mile: Pace Per Mile
        126012246__activity_url_generated: Activity URL Generated
        126012246__start_latlng: Start Latlng
        126012246__start_date: Start Date
        126012246__elapsed_time: Elapsed Time
      params:
        calendarid:
          label: <SNIP>
        colorId:
          label: "#ffb878"
```

