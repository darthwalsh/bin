function count_inbox() {
  const counts = new Map();

  // https://stackoverflow.com/a/55723614/771768
  let startIndex = 0;
  const maxThreads = 500;
  let threads
  do {
    threads = GmailApp.getInboxThreads(startIndex, maxThreads);
    for (const thread of threads) {
      for (const message of thread.getMessages()) {
        let from = message.getFrom();
        match = from.match(/<(.*@(.*))>/);
        if (match) {
          const [_, email, domain] = match;
          from = domain;
        }
        counts.set(from, 1 + (counts.get(from) || 0));
      }
    }
    startIndex += maxThreads;
  } while (threads.length == maxThreads); // If this times out on HUGE inbox, could break earlier

  const sorted = [...counts.keys()].sort((a, b) => counts.get(b) - counts.get(a));
  for (const from of sorted.slice(0, 200)) {
    if (counts.get(from) < 5) break;

    const url =
      "https://mail.google.com/mail/u/0/#search/" + encodeURIComponent("in:inbox from:" + from);
    console.log(from, counts.get(from), url);
  }
}
