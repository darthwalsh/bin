"use strict";
// Don't give somebody else access to run this script as you after setting your token!

function toUrl(url, searchParams) {
  // Can't use URL or URLSearchParams: https://stackoverflow.com/a/64382970/771768
  const query = Object.entries(searchParams)
    .map(([k, v]) => `${encodeURIComponent(k)}=${encodeURIComponent(v)}`)
    .join("&");
  return url + "?" + query;
}

/** @param {string} date i.e. "2023-05-21" */
function download(date) {
  const r2Dir = DriveApp.getFoldersByName("RescueTime2Cal").next();
  const fileName = date + ".json";

  if (r2Dir.getFilesByName(fileName).hasNext()) {
    console.log("Already downloaded " + fileName);
    return;
  }

  const userProps = PropertiesService.getUserProperties();
  const rt_token = userProps.getProperty("rt_token");
  if (!rt_token) {
    throw "rt_token not set, run `userProps.setProperty('rt_token', your_token_here)` once to set secret";
  }

  const query = {
    key: rt_token,
    perspective: "interval",
    restrict_kind: "activity",
    interval: "minute",
    restrict_begin: date,
    restrict_end: date,
    format: "json",
  };

  console.log("Downloading " + date);
  var response = UrlFetchApp.fetch(toUrl("https://www.rescuetime.com/anapi/data", query));

  const blob = response.getBlob();
  blob.setName(fileName);
  r2Dir.createFile(blob);
}

// TODO implement creating calendar events from rescuetime data
// function createCalendar() {
//   const calendars = CalendarApp.getAllCalendars();
//   Logger.log('This user owns or is subscribed to %s calendars.',
//     calendars.length);
//   for (const cal of calendars) {
//     Logger.log(cal.getName(), cal.getId());
//   }
// }

// main function
function pastDays() {
  const today = new Date();
  for (let ago = 1; ago <= 5; ago++) {
    const date = new Date(today);
    date.setDate(date.getDate() - ago);
    const text = date.toISOString().slice(0, 10);
    download(text);
  }
}
