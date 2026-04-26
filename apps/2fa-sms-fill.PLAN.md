# SMS OTP Autofill — Browser Extension Plan

**Problem:** Some sites enforce SMS 2FA. On macOS + Pixel, there is no autofill bridge — manual copy/paste from Google Messages Web is unavoidable. This extension would close that gap for origin-bound SMS OTPs.

## Core idea

A browser extension that:
1. Watches the Google Messages PWA tab for new incoming SMS
2. Parses messages for the [WICG origin-bound OTP format](https://wicg.github.io/sms-one-time-codes/) (`@host #code` on last line)
3. If the user is currently on a tab whose origin matches the bound host → autofills the OTP field (`autocomplete="one-time-code"`)

## Threat model alignment

> From [[ThreatModel]]:
> - **Trusted Host / Automation is Allowed**: scripts and automated processes acting on behalf of the user are acceptable. Silent autofill without a "touch" prompt is explicitly preferred over UP/UV friction.
> - **Origin Binding** is a stated security priority. The extension enforces this by *only* filling when `current page host === SMS-bound host` (exact match, stricter than the WICG spec's same-site allowance).
> - **Trusted UX**: click-jacking / confused-tab protection is not a primary concern, so filling the focused tab without a confirmation prompt is acceptable.

## Architecture

```
Google Messages PWA tab
  └─ content script (MutationObserver on message list DOM)
       └─ on new message node → extract text → parse last line for @host #code
            └─ send { host, code } to background service worker
                 └─ background: query all tabs for matching origin
                      └─ if exactly-matching HTTPS tab found and has autocomplete="one-time-code" input
                           └─ inject fill script into that tab
```

### Key design decisions

| Decision | Choice | Reason |
| --- | --- | --- |
| Origin matching | Exact host only (stricter than WICG same-site) | ThreatModel: Origin Binding priority |
| Fill confirmation prompt | None — silent fill | ThreatModel: UP deprioritized, Automation is Allowed |
| Scope | Only `autocomplete="one-time-code"` inputs | Avoids mis-filling arbitrary number fields |
| Tab selection | Currently-active tab if it matches; else any matching tab | Minimize cross-tab surprise |
| Parsing source | DOM mutation on Messages PWA | No SMS API exists; Messages Web is the only desktop surface |

### Constraints / known gaps

- **MutationObserver on Messages PWA is fragile**: Google can change the DOM at any time; requires maintenance.
- **Messages Web must be open**: extension cannot wake it up or push-connect to Android.
- **No fallback if SMS lacks `@host #code`**: most real-world SMS do not use the WICG format. The extension only helps for services that adopt the spec.
- **Cross-tab fill requires `scripting` permission** (Manifest V3 `chrome.scripting.executeScript`), which triggers a "read and change all your data on websites" warning in the Chrome store — may deter users / complicate publishing.

## V2 ideas

### Gmail watcher (email OTP)
- Browser extension content script on `mail.google.com` watches for new messages
- Parse email body for OTP patterns + origin hint (less standardized than SMS spec)
- Same fill logic

### Gmail OAuth connection (no open tab required)
- OAuth token with `gmail.readonly` scope
- Background service worker polls Gmail API for new messages matching OTP patterns
- No open Gmail tab needed
- Trade-off: requires user to grant OAuth, token stored in extension storage

> ThreatModel note: OAuth token stored locally is acceptable ("Automation is Allowed"), but non-extractability matters — store in `chrome.storage.session` (cleared on browser close) rather than `chrome.storage.local`.

## Open questions

1. Does Google Messages Web use a stable enough DOM class/attribute to hook a MutationObserver reliably?
2. What `permissions` does Manifest V3 require to read another tab's DOM vs. just inject a fill script? (`scripting` vs. `tabs` vs. `activeTab`)
3. Is there a way to narrow the `host_permissions` to just the matched origin at fill time, rather than declaring broad permissions upfront?
4. Would a Plasmo or WXT framework reduce the boilerplate enough to be worth the dependency?
