---
tags: app-idea
created: 2018-01-13
---
For each person, we might have implicit rules about message priority or content. i.e. "I'll WhatsApp you if it's important, otherwise treat email as low priority -- except for Google Photos- or Strava-related content I'll message inside the social media app" -- or "this person doesn't SMS, so just fallback to email"

On Android, when the Share dialog comes up, you pick the app, then you pick a person. This feels backward: I'd rather pick the person first from a big grid and easy keyboard search, then pick the app second. (For most people, based on the type of link/text/image content there might be only one relevant app, so just pick that.)
Sometimes there will be auto-suggested "message this person in this app" but I want complete control of this part.

It would be extra great if there was a web protocol to list your apps in terms of preference. i.e. `mysite.example.com/__handlers__.json` like
```json
{
  "prefs": [
    "SMS",
    { "email": "sha256_YOUR_HASHED_PROFESSIONAL_EMAIL" },
    "PhoneCall",
    { "email": "sha256_YOUR_MIDDLE_SCHOOL_EMAIL" },
    "ZoomVideoCall"
  ]
}
```

- [ ] How can you securely share a hash of your email? Might need to use some asymmetric encryption where your app will share a private key with anybody in your contact book


## Bot to automatically find somebody to talk to
#app-idea created: 2018-02-18
Related to 
- [ ] Especially if you don't have that knowledge, could an app automate the steps to get to a phone call?
- [ ] If you start doomscrolling, it should initiate social connection on it's own:
	- [ ] Your phone starts ringing; it's your best friend!
	- [ ] "Hi Bestie, what's up?"
	- [ ] "I dunno, you called me" 
	- [ ] "Oh, it must have been my virtual bot that decided we should talk more"
- [ ] It could use different sources to decide who is best to call:
	- [ ] [[WeasleyClock]] which helps you know if somebody are free.
	- [ ] Could look at call history
	- [ ] `mysite.example.com/__free__.ics` could host a calendar feed with free/busy times?
- [ ] Depending on whether contact is more of a GenX or a Zoomer, might just call, or text first to see if they are free to chat?
