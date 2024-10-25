Jira is a bug-tracking server: https://www.atlassian.com/software/jira

I currently use the `jira` CLI  https://github.com/go-jira/jira
> [!NOTE] This is *different* than go client library https://github.com/andygrunwald/go-jira

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
2. Check it works:
```
jira ls -l 1
```

