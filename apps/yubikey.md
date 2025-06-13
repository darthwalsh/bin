[YubiKey - Wikipedia](https://en.wikipedia.org/wiki/YubiKey)

For SSO to Azure ActiveDirectory, probably using **FIDO2/WebAuthn** which doesn't keep any session. CANNOT disable the PIN entry each time!

#ai-slop 
## What Happens in a YubiKey Session?
A **YubiKey session** refers to the period during which the YubiKey stays authenticated or active with a host system after a successful authentication event—such as entering a PIN or performing a touch. The meaning of “session” can vary slightly depending on the YubiKey _application_ in use (like FIDO2, PIV, OTP, or OATH), but the general idea is:

After you authenticate (e.g., enter a PIN or tap the key), the YubiKey allows further operations **without needing to re-authenticate repeatedly**—**until the session ends**. When and how a session ends depends on the application and context.
## Common YubiKey Applications and Their Sessions

| Application                | Session Scope                                                     | When It Ends                                                                      |
| -------------------------- | ----------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| **PIV (Smart Card / PKI)** | Session starts after a PIN is entered                             | Ends when the device is unplugged, the system sleeps, or you manually lock/logout |
| **FIDO2/WebAuthn**         | Typically per-use (stateless)                                     | Each use is isolated; no session persists                                         |
| **OATH (TOTP/HOTP)**       | Session can persist while the app is open and YubiKey is inserted | Ends when app closes or YubiKey is removed                                        |
| **OpenPGP**                | Session starts after PIN entry                                    | Ends on device removal or system reboot                                           |
For **FIDO2/WebAuthn** (which is what you're using when you log in to Azure via SSO with your YubiKey), the **PIN requirement** is **set at the time the credential (passkey) is created**, and it depends on a few factors:
**Azure AD requires strong user verification**, which includes a **PIN or biometric** during FIDO2 login. This is a security policy enforced by your organization and by Microsoft's identity platform.

### 🧩 Workarounds or Simplifications?
You can’t skip the PIN entirely, but here are ways to make things smoother:

| Option                  | Description                                                                                  |
| ----------------------- | -------------------------------------------------------------------------------------------- |
| ✅ **Biometric YubiKey** | Some YubiKeys (like the YubiKey Bio) let you use a fingerprint instead of a PIN.             |
| ✅ **Windows Hello SSO** | If your org allows, using Windows Hello + a YubiKey might reduce how often you need the key. |
| ❌ **No PIN**            | Not allowed by Azure for FIDO2—security requirements prevent it.                             |