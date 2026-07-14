- [ ] Submit bug report?

I ran into a TOTP problem with my Google account in 1Password. The one-time password field had stopped generating codes and instead showed this message:

> one-time password
> The one-time password URL is incorrect: check the URL and try again. If you still have trouble, contact support for the site you're trying to add.

At first, I wondered whether something had changed with Google account TOTP support during the last couple of years, but the TOTP entry was years old and its history didn't explain the error either.

I updated the macOS app, but that did not help.

I then went to [Google's authenticator settings](https://myaccount.google.com/two-step-verification/authenticator), and chose to switch authenticator apps, and Google displayed a new QR code. 1Password offered to update my existing login item and overwrite the old TOTP configuration, but the field still showed the same error.

I then used the 1Password menu to capture the QR code manually. That produced two different results at the same time: 1Password copied the current six-digit code to my clipboard, but the login item still displayed the malformed one-time-password field.

I used that six-digit code and successfully enrolled the new QR code with Google. However, I still could not get any more six-digit codes from the main one-time-password field in 1Password. 😡😡😡

Then I noticed that 1Password showed a main `one-time password` field near the top, but farther down the item there were ***other*** TOTP fields that were generating rotating six-digit codes:

> SECURITY
>
> one-time password
> `123 456`

I deleted the broken `one-time password` field, and another one appeared in its place. I repeated deleting maybe three 
times, until all of the other TOTP fields at the bottom of the item were gone.

I then successfully enrolled the Google QR code again.

This time, 1Password created a working one-time-password field and began generating rotating six-digit codes normally.
