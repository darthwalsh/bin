## Going Passwordless
- [ ] Not sure what this means for entering a password for i.e. [[TaskScheduler]]
Azure Active Directory lets you use hardware token as the only auth factor (at least for repeated sign in?)

## Windows
- [ ] How to see AD password policies
## macOS
I was wondering:
> is there a way to set a device PIN on a macbook? On windows I’m used to having a complex domain password, but I can set a PING code  local to the device as the hardware limits wrong guesses. It seems a recent macbook with password-cracking-prevention-hardware should treat the local password differently than a network password?

Doesn't seem to support PIN the way that windows does, but you can customize your `sudoers`

macOS [supports](https://developers.yubico.com/PIV/Guides/Smart_card-only_authentication_on_macOS.html) mandatory use of a smart card, which **disables all password-based authentication**. This makes it possible to use a [[yubikey]] with **PIV** support for all authentication on macOS, including computer login. But that probably needs to be set up by your IT team?

Can run `pwpolicy getaccountpolicies` and view the regex implementation.
