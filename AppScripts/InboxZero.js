// Apps Script to get count of starred, unread, and read emails
function doGet(e) {
  const query = "older_than:7d in:inbox is:important";
  const threads = GmailApp.search(query, 0, 500); // fetch up to 500 threads
  
  const counts = {
    starred: 0,
    unread: 0,
    read: 0
  };

  for (const thread of threads) {
    for (const msg of thread.getMessages()) {
      if (msg.isStarred()) {
        counts.starred++;
      }
      if (msg.isUnread()) {
        counts.unread++;
      } else {
        counts.read++;
      }
    }
  }

  console.log(counts);

  return ContentService
    .createTextOutput(JSON.stringify(counts))
    .setMimeType(ContentService.MimeType.JSON);
}
