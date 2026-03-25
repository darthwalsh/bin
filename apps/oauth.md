#ai-slop

# OAuth

OAuth delegates access to a user's resources without sharing their credentials. The core design question for each flow: **which devices hold which secrets, and who can see the tokens?**

See [[auth]] for authentication concepts (401 vs 403, capabilities). OAuth is **authorization** (delegated access), not authentication -- [OpenID Connect](https://openid.net/developers/how-connect-works/) layers identity on top of OAuth.

## Confidential vs. public clients

This distinction drives which flow to use:

- **Confidential client**: has a server that can keep a `client_secret` private (web app with a backend)
- **Public client**: can't store secrets (SPA, mobile app, CLI tool) -- anyone can decompile the binary or inspect the JS bundle

[OAuth 2.1](https://oauth.net/2.1/) pushes everything toward PKCE regardless of client type.

## Authorization Code ("three-legged" / 3LO)

The standard flow for apps with a backend server. Three parties: user, your app, the auth server.

("3LO" is [Atlassian's abbreviation](https://developer.atlassian.com/cloud/jira/platform/oauth-2-3lo-apps/); the OAuth spec just calls it "Authorization Code Grant.")

```
Browser ──(1) redirect────────> Auth Server
                                  User logs in, consents
Browser <──(2) code + state──── Auth Server
Browser ──(3) code──> Your Server ──(4) code + client_secret──> Auth Server
                      Your Server <──(5) access_token + refresh_token
                      Your Server ──(6) access_token──> Resource Server
```

**Where secrets live:**

| Secret | Lives on | Visible to browser? |
|---|---|---|
| `client_id` | URL params, server config | Yes (semi-public) |
| `client_secret` | Server only | No |
| `authorization_code` | Redirect URL, one-time, ~60s TTL | Briefly |
| `access_token` | Server only | No |
| `refresh_token` | Server only | No |

The browser never sees bearer tokens. A compromised browser yields a session cookie, not raw API credentials.

The `state` parameter prevents CSRF: the server generates a random value, stashes it in the session, includes it in the auth redirect, and rejects callbacks where `state` doesn't match.

## Authorization Code + PKCE

Same as Authorization Code but replaces `client_secret` with a per-request proof. Designed for **public clients** (SPAs, mobile apps).

```
Client generates:  code_verifier  (random 43-128 chars, kept in memory)
                   code_challenge = BASE64URL(SHA256(code_verifier))

Browser ──(1) redirect + code_challenge──> Auth Server
Browser <──(2) code
Browser ──(3) code + code_verifier──> Auth Server
            Auth Server verifies: SHA256(code_verifier) == code_challenge
Browser <──(4) access_token
```

| Secret | Lives on | Notes |
|---|---|---|
| `client_id` | URL params | Public |
| `code_verifier` | Client memory | Never sent until token exchange |
| `code_challenge` | Auth server | Hash of verifier -- can't reverse |
| `access_token` | Client (browser/app) | XSS-accessible if in a browser |

No backend server needed. The tradeoff: tokens live on the client.

PKCE protects against authorization code interception (e.g., malicious app registered for the same custom URI scheme on mobile). It does **not** protect tokens once issued.

## Client Credentials ("two-legged" / 2LO)

No user involved. A service authenticates as itself.

```
Your Service ──(client_id + client_secret)──> Auth Server
Your Service <──(access_token)
Your Service ──(access_token)──> Resource Server
```

All secrets stay on the server. No browser, no user, no redirect. Common for: cron jobs, service-to-service APIs, backend pipelines.

## Device Authorization Grant

For devices without a browser (smart TVs, CLI tools, IoT).

```
Device ──(client_id)──> Auth Server
Device <── device_code, user_code, verification_url

Device displays: "Go to verification_url and enter: ABCD-1234"

User (on phone) ──> visits URL, enters code, authenticates

Device polls Auth Server with device_code until approved
Device <──(access_token)
```

Examples: `gh auth login`, Chromecast setup, TV streaming apps.

## Implicit grant (deprecated)

Returned `access_token` directly in the redirect URL fragment -- no code exchange. Removed in OAuth 2.1 because the token is exposed in browser history, referrer headers, and server logs. Use PKCE instead.

---

## Hobbyist OAuth: minimal infrastructure

When building a low-effort personal app (e.g., a Strava dashboard), a full server with sessions and a database is overkill. What changes when you strip that away.

### No session DB -- tokens live in the browser

Classic OAuth parks tokens on the server and gives the browser a session cookie. Without a server or database, tokens go directly to the browser, and the browser calls the resource server itself.

This is **OAuth with the trust boundary intentionally placed in the browser**. Not reckless -- just explicit about the tradeoff.

### Confidential-only providers need a lambda shim

Some providers (e.g., Strava) only support confidential clients -- they require a `client_secret` for token exchange. A pure SPA can't do this.

Minimal solution: a stateless [[webhooks|lambda/cloud function]] that does **one thing**:

```
Browser ──(code + state)──> Lambda ──(code + client_secret)──> Auth Server
                            Lambda <──(tokens)
Browser <──(tokens)──────── Lambda
Browser ──(access_token)──> Resource Server
```

The lambda is a confidential client for the exchange, then hands tokens to what is effectively a public client. Treat it as a single-purpose cryptographic appliance:
- Verify `state` (browser passes the original value alongside the code)
- Exchange code for tokens
- Return tokens
- No other routes, rate-limit hard, never log tokens

See [[webapp.hosting]] for serverless/lambda hosting options.

### Dev-mode OAuth apps

Most providers let you register an OAuth app that works **only for your own account** (or a short allowlist) without going through a review process. For a personal tool, this is permanent and fine.

Provider behavior varies:
- **Strava**: dev apps restricted to the app owner's account
- **GitHub**: unverified apps work for anyone but show a warning banner
- **Spotify, Fitbit**: dev mode limits to explicitly allowlisted accounts

No approval process needed for personal dashboards and automations.

### Trust boundary: server vs. browser

```
Classic:   Browser ──(session cookie)──> Server ──(token)──> Resource
Hobbyist:  Browser ──(code)──> Lambda ──(tokens)──> Browser ──(token)──> Resource
```

In the classic model, XSS gives the attacker a session cookie scoped to your app. In the hobbyist model, XSS gives raw API tokens to the resource provider.

Mitigations that fit a no-infrastructure setup:
- **Minimal scopes** -- scope is the real permission boundary now; if tokens leak, scope determines blast radius
- **Short token TTL** -- prefer inconvenient re-auth over silent long-term compromise
- **Memory-only storage** -- JS variables or `sessionStorage` over `localStorage` (tokens vanish on tab close)
- **Assume breach** -- if JS execution is compromised, the account is compromised. That's the trade.

CORS does not protect tokens. CORS is a browser-to-browser policy, not a security boundary against attackers. See [[ThreatModel]] for broader threat modeling context.
