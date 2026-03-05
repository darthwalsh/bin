Jira is a bug-tracking server: https://www.atlassian.com/software/jira

I currently use the `jira` CLI  https://github.com/go-jira/jira
> [!NOTE] This is *different* than
> - go client library https://github.com/andygrunwald/go-jira
> - https://github.com/ankitpokhrel/jira-cli with POSIX args
> 	- [[markdown]] for writing descriptions
> 	- has several args for filtering, instead of needing JQL

I used to install from `brew install go-jira` but found this was missing a fix I needed.
Installed latest with:
```command
go install github.com/go-jira/jira/cmd/jira@master
```

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

## OAuth2 Client Credentials (client_id / client_secret)
**go-jira does not implement the OAuth2 *client credentials* flow** (it does not call `https://auth.atlassian.com/oauth/token` to exchange `client_id` + `client_secret` for an `access_token`).

If your environment standardizes on client-credentials, you’ll need an **external wrapper** (script/service) to mint tokens and then pass the resulting access token to go-jira (see **Bearer token** below).

## Bearer token support (bring your own token)
go-jira **can send Bearer tokens** by setting `authentication-method: bearer-token`, adding: `Authorization: Bearer <TOKEN>` to every request. go-jira **does not refresh or mint** the token for you — it just uses whatever token you provide.

### Wrapper that refreshes OAuth + injects token
- [ ] See if we can get a token from Cursor's MCP for https://mcp.atlassian.com/v1/sse logged into jira?
- [ ] Script below needs to have a jira client app, hmmm.... 
Script:
1) Fetches/refreshes an OAuth access token (however your org does it)
2) Exposes it to go-jira as the “password” value (token) via env var / stdin / keyring
3) Runs go-jira with `authentication-method: bearer-token`

Example (conceptual):

```python
#!/usr/bin/env python3
# /// script
# dependencies = ["cli-oauth2", "requests-oauthlib"]
# ///
"""jira-wrapper – mints/caches an Atlassian OAuth 2.0 (3LO) token, then execs go-jira."""
import os, subprocess, sys
from typing import Optional, Sequence

from oauthcli import AuthFlow
from requests_oauthlib import OAuth2Session

JIRA_ENDPOINT = os.environ["JIRA_ENDPOINT"]    # e.g. https://yourorg.atlassian.net
CLIENT_ID     = os.environ["JIRA_CLIENT_ID"]
CLIENT_SECRET = os.environ["JIRA_CLIENT_SECRET"]


class AtlassianAuth(AuthFlow):
    def __init__(self, client_id: str, client_secret: str,
                 scopes: Optional[Sequence[str]] = None):
        if scopes is None:
            scopes = ["read:jira-work", "write:jira-work"]
        super().__init__(
            "atlassian",
            OAuth2Session(client_id, scope=scopes),
            "https://auth.atlassian.com/authorize",
            "https://auth.atlassian.com/oauth/token",
            client_secret,
        )

    def process_url(self, api: str) -> str:
        return f"{JIRA_ENDPOINT}/rest/api/3/{api.lstrip('/')}"


# Opens browser on first run; token cached in ~/.config/PythonCliAuth/tokens.json
token = AtlassianAuth(CLIENT_ID, CLIENT_SECRET).auth_code()
# Tokens typically expire (e.g., 1 hour). The wrapper should cache until near expiry.

os.environ["JIRA_API_TOKEN"] = token["access_token"]
subprocess.execvp("jira", ["jira", "--endpoint", JIRA_ENDPOINT, *sys.argv[1:]])
```

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
