For a weekly zoom ~~meeting~~ webinar I attend, I have been tasked to track the attendee count.

I've been 
1. putting in headphones -- *the Andoid app can't 100% mute the audio output, how rude!*
2. manually opening the zoom mobile app
3. switching accounts to the user account that owns the webinar
4. joining the webinar
5. taking a screenshot
6. manually counting attendees
7. sharing screenshot with the leaders

Is it easy to automate this?
- [ ] Try adding my `@gmail.com` address as an allowed co-host of this (or all) webinars? ⏫ 
## Getting Reports
- Can manually go to https://zoom.us/account/my/report/webinar
	- only shows attendees if run after the webinar is over!
	- I want to be able to see the in-person meeting attendance at the same time as the remote attendees
	- Still a hassle to click through this way
## Using API
- There are several APIs to get that report manually, but that doesn't solve the problem of 
	- MAYBE there's a different API for listening current participants
- A workaround, could set up webhook to receive each Participant Joined message?
- JWT auth is deprecated, but server-to-server auth looks reasonly simple (the easy parts of OAuth?)
- BUT, my account doesn't have permission to create a new Zoom App, so this is a dead end

