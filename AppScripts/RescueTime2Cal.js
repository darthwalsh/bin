// TODO stub function
function myFunction() {
    const calendars = CalendarApp.getAllCalendars();
    Logger.log('This user owns or is subscribed to %s calendars.',
        calendars.length);

    for (const cal of calendars) {
        Logger.log(cal.getName(), cal.getId());
    }
}
