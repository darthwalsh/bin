Jira is a bug-tracking server: https://www.atlassian.com/software/jira

I currently use the `jira` CLI  https://github.com/go-jira/jira
> [!NOTE] This is *different* than
> - go client library https://github.com/andygrunwald/go-jira
> - https://github.com/ankitpokhrel/jira-cli with POSIX args instead of JQL, and [[markdown]] for descriptions

I used to install from `brew install go-jira` but found this was missing a fix I needed.
~~Installed latest~~ with:
```command
go install github.com/go-jira/jira/cmd/jira@master
```
*instead install from [[#Create issues broken on current jira server]]*
## Debugging

### Debug logic and network requests with `JIRA_DEBUG`
```command
$ export JIRA_DEBUG=1
$ jira issuetypes -p ABC
DEBUG Getting Password
DEBUG password-source: keyring
INFO  Querying keyring password source.
INFO  Password cached.
DEBUG Request 1: GET /rest/api/2/issue/createmeta?projectKeys=ABC&expand=projects.issuetypes.fields HTTP/1.1
...
```

### Debug template creation
Change the editor to `--editor cat` and the template contents just gets printed

## Create issues broken on current jira server
`/createmeta` has been [removed](https://confluence.atlassian.com/jiracore/createmeta-rest-endpoint-to-be-removed-975040986.html).
Known issue: https://github.com/go-jira/jira/issues/481
PR is pending: https://github.com/go-jira/jira/pull/502

Install:
```command
md ~/go-jira-fork
gh clone prpht9/go-jira
cd ./go-jira/
git checkout jira_9_createmeta_api_url_bug
go install ./cmd/jira/
cd ~
jira ls -l 1
```

#### Workaround create override component
[Commented](https://github.com/go-jira/jira/pull/502#issuecomment-2433441589):
I hit a small issue with overriding `components` using `jira create`.

My jira server (v9.12.12) responded to `/rest/api/2/issue/createmeta/ABC/issuetypes` without any `.allowedValues` in the response. I needed to query a specific issue type e.g. `/rest/api/2/issue/createmeta/ABC/issuetypes/3` and then `.allowedValues` showed up for all fields.

This led to the default [`create` template](https://github.com/go-jira/jira/blob/4263bd24f9e9c702a92358c5cd7ce0ddd711df4c/jiracli/templates.go#L486) not having any `.meta.fields.components.allowedValues` , which leads to CLI `jira create --override components=Something` getting ignored. It's might be fair to call "components gets ignored" a separate preexisting issue, but it's exposed by this PR's fix.

As a workaround, I created a custom creation template that hardcodes
```yaml
  components:
    - name: {{ .overrides.component }}
```

## Jira Cloud authentication

[Basic auth with passwords is deprecated](https://developer.atlassian.com/cloud/jira/platform/deprecation-notice-basic-auth-and-cookie-based-auth/). Atlassian [recommends OAuth 2.0 over API tokens](https://developer.atlassian.com/cloud/jira/service-desk/basic-auth-for-rest-apis/) for stronger security.

Auth options for Jira Cloud:
- **Personal Access Token** (PAT) — Simple with basic/bearer auuth. Still supported, if your company doesn't block it
- **OAuth 2.0 (3LO)** authorization code — authenticates as the user via browser SSO, gets bearer token with user's permissions, then use refresh tokens.
    - Only OAuth way to authenticate as yourself on Jira Cloud
    - go-jira **can send Bearer tokens** by setting `authentication-method: bearer-token`, adding: `Authorization: Bearer <TOKEN>` to every request.
    - go-jira **does not create** the token for you.
- **OAuth 2.0 client credentials** — service account flow only. Cannot represent a personal account.
    - See [Atlassian service account docs](https://support.atlassian.com/user-management/docs/create-oauth-2-0-credential-for-service-accounts/).
    - go-jira does not implement the OAuth2 *client credentials* flow (exchange `client_id` + `client_secret` at `https://auth.atlassian.com/oauth/token`)

### 3LO app setup checklist

In the [Atlassian Developer Console](https://developer.atlassian.com/console/myapps/):
1. Create app → **Authorization** → Configure **OAuth 2.0 (3LO)**
2. Add callback URL (e.g. `http://127.0.0.1:8080/` for local CLI tools) -- or pick a random port
3. **Permissions** → Add Jira API (Platform) with [scopes required by your endpoints](https://developer.atlassian.com/cloud/oauth/getting-started/determining-scopes/). Prefer [classic scopes](https://developer.atlassian.com/cloud/jira/service-desk/scopes-for-oauth-2-3LO-and-forge-apps/), keep under 50 total.

### Admin must authorize 3LO app

After login, Atlassian may show "Your site admin must authorize this app." The site admin must [approve the app](https://support.atlassian.com/atlassian-cloud/kb/your-site-admin-must-authorize-this-app-error-in-atlassian-cloud-apps/) at **admin.atlassian.com → Apps → [site] → Connected apps**.

Template message for the admin:
> I created an internal OAuth 2.0 (3LO) app for Jira Cloud (`APP_NAME`).
> It authenticates as the end user via Atlassian SSO (not a service account).
> Scopes: `<SCOPES>`
> Could you approve it under **Admin → Apps → `<YOUR_SITE>` → Connected apps**?

### Wrapper script that refreshes OAuth + injects token
- [-] See if we can get a token from Cursor's MCP for https://mcp.atlassian.com/v1/sse logged into jira? ❌ 2026-03-17
    - vscode secret store is pretty complicated
- [x] Script below needs a jira client app — see **3LO app setup checklist** above
    - Fetches/refreshes an OAuth access token and set `$JIRA_API_TOKEN`
    - Exec go-jira
    - See: [[walshca/bin/uat-jira.py]]
## Rotating jira token auth on macbook

### debug: print current token in plaintext
```
security find-generic-password -s go-jira -w
```
### Rotating cred
1. Delete old PW
```
security delete-generic-password -s go-jira
```

1. Go to https://JIRA_URL/secure/ViewProfile.jspa?selectedTab=com.atlassian.pats.pats-plugin:jira-user-personal-access-tokens
2. Run this and paste token:
```
$ jira ls -l 1
? Jira API-Token [user@example.com]:  [? for help] *************
ABC-123:      Some Jira Issue Summary
$ jira ls -l 1
ABC-123:      Some Jira Issue Summary
```
