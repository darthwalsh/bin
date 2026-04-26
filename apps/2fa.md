Explored in https://chatgpt.com/share/67e98360-51ac-8011-85dd-8eb230c65a90

| Method     | Network-attack resistant | Phishing resistant |
| ---------- | ------------------------ | ------------------ |
| Email code | ❌ account compromise     | ❌                  |
| SMS code   | ❌                        | ❌                  |
| TOTP code  | ✅                        | ❌                  |
| Yubikey    | ✅                        | ✅                  |
| WebAuthn   | ✅                        | ✅                  |

In [[2fa-sms-audit]] I plan to migrate from SMS 2FA.
## SMS origin-bound OTP spec (WICG)

## SMS origin-bound OTP spec (WICG)
The [wicg.github.io/sms-one-time-codes](https://wicg.github.io/sms-one-time-codes/) spec has the last line `@<host> #<code>` of an SMS declare which host the code SHOULD be bound to:

```
Your verification code is 123456.

@login.example.com #123456
```

The browser treats the host as an HTTPS origin internally.

**Subdomain binding is non-exact:** The spec permits same-site assistance (sibling subdomains), so binding is not strictly exact-host-only.

**Weaker phishing resistance:** SMS origin binding is a *hinted trust signal* — same-site leakage is allowed by spec: See [[ThreatModel]] WebAuthn/passkeys are better for "Origin Binding" priority.

Exploring [[2fa-sms-fill.PLAN]] idea for a browser extension to autofill SMS origin-bound OTPs.
