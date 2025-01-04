# Google App Scripts

Things I have in https://script.google.com/

## Inbox Group By
[`InboxGroupBy.js`](InboxGroupBy.js) is a script that groups emails in your inbox by sender. 

It's useful for when you want to unsubscribe from whichever accounts are spamming your inbox, but you don't know what the worst offenders are. It's also useful to quickly scan dozens of emails and archive all of them.

Running it, it generates a bunch of lines like:

> 8:48:01 AM	Info	amazon.com 97 https://mail.google.com/mail/u/0/#search/in%3Ainbox%20from%3Aamazon.com
8:48:01 AM	Info	em1.mint.intuit.com 85 https://mail.google.com/mail/u/0/#search/in%3Ainbox%20from%3Aem1.mint.intuit.com
8:48:01 AM	Info	linkedin.com 79 https://mail.google.com/mail/u/0/#search/in%3Ainbox%20from%3Alinkedin.com
8:48:01 AM	Info	google.com 70 https://mail.google.com/mail/u/0/#search/in%3Ainbox%20from%3Agoogle.com
8:48:01 AM	Info	e.coribush.org 65 https://mail.google.com/mail/u/0/#search/in%3Ainbox%20from%3Ae.coribush.org

By clicking each link, you can open all the emails from that sender.

- [-] Refactor to make opening the new tabs easier ❌ 2024-12-28
	- ~~open new browser tabs directly OR~~
	- ~~make the links clickable in the console out OR~~
		- https://webapps.stackexchange.com/questions/169527/is-it-possible-to-make-clickable-links-using-logger-log#comment156756_169527
	- writing to a Google sheet / HTML page
			- [ ] make a web app deployment? Then anybody could run the script?
## Development
- [ ] Look into [`clasp` framework](https://www.npmjs.com/package/@google/clasp): 
	- develop your Apps Script projects locally
	- Write Apps Script in TypeScript
	- Run scripts locally
- [ ] Possible to use webpack/babel to [bundle npm packages](https://web.archive.org/web/20240124093236/https://blog.gsmart.in/es6-and-npm-modules-in-google-apps-script/) into your App Script project
- [ ] Figure out [[CalendarTriggers]]
