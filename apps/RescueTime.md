I use https://www.rescuetime.com/ on all my devices

## API Calls
[Documentation](https://www.rescuetime.com/rtx/developers)
Auth: API Key makes it easy

To get my data: want to set fields:

| URL Key | value | notes |
| --- | --- | -- |
| `perspective` | `interval` | |
| `restrict_kind` | `activity` | See below for comparisons |
| `interval` | `minute` | alias for `resolution_time` -- gets values at 5 minute resolution: the highest |
| `restrict_begin` | `2023-08-18` | just get one date of data, from midnight-midnight |
| `restrict_end` | *same* | |
| `format` | `json` | Much easier to work with |


### `restrict_kind`
Documented options:
> - **overview:** sums statistics for all activities into their top level category
> - **category:** sums statistics for all activities into their sub category
> - **activity:** sums statistics for individual applications / web sites / activities
> - **productivity:** productivity calculation
> - **efficiency:** efficiency calculation (not applicable in "rank" perspective)
> - **document:** sums statistics for individual documents and web pages

The JSON files ranged from 6K to 49K, so I'm not worried about the size here.

Querying all 6, expanding with PowerQuery into tables:

```
let
    Source = Json.Document(File.Contents("C:\Users\cwalsh\AppData\Local\Temp\DEL-20230819-06-46-30.26\productivity.json")),
    #"Converted to Table" = Table.FromRows(Source[rows], Source[row_headers])
in
    #"Converted to Table"
```
(CSV would have made this easier I guess!)

#### `activity`
Looks like:

|Date|Time Spent (seconds)|Number of People|Activity|Category|Productivity|
|---|---|---|---|---|---|
|2023-05-19T09:05:00|8|1|mobile - com.google.android.apps.youtube.music|Music|1|
|2023-05-19T09:10:00|85|1|Android Dialer|Voice Chat|1|
|2023-05-19T09:10:00|58|1|Messenger for Android|Instant Message|0|
|2023-05-19T09:10:00|32|1|GMail for Android|Email|0|
|2023-05-19T09:10:00|27|1|Google Calendar for Android|Calendars|1|
|2023-05-19T09:15:00|162|1|Android Dialer|Voice Chat|1|

#### `document`
Same as `activity`, except added Document field:
Useless for me, just shows "No Details" for everything--unless you are on the [Premium Plan](https://www.rescuetime.com/premium):
> RescueTime uses the the page title of the current application or website to distinguish between different documents or web pages. This gives you a more detailed view about your time with this activity. You will also have the ability to categorize or score individual documents or web pages differently than the main application or website.


#### `overview`
Aggregates by top-level category, not as useful to me.

#### `category`
Aggregates by sub-category, not as useful to me.

#### `productivity`
Aggregates by Productivity Score, not useful to me.

### `efficiency`
Different than the others, not sure it's that useful to me though
    
|Date|Time Spent (seconds)|Number of People|Efficiency (-2:2)|Efficiency (percent)|
|---|---|---|---|---|
|2023-05-19T09:05:00|8|1|1|75|
|2023-05-19T09:10:00|202|1|0.55|63.86|
|2023-05-19T09:15:00|180|1|0.9|72.5|
