function count_inbox() {
  const counts = new Map();
  for (const thread of GmailApp.getInboxThreads()) {
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
  
  const sorted = [...counts.keys()].sort((a, b) => counts.get(b) - counts.get(a))
  for (const from of sorted.slice(0, 40)) {
    const url = 'https://mail.google.com/mail/u/0/#search/' + encodeURIComponent('in:inbox from:' + from)
    console.log(from, counts.get(from), url);
  }
}

