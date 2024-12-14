## App DNS to redirect to project homepage
i.e. https://wizards.carlwa.com/ now gives HTTP 301 redirect to https://github.com/darthwalsh/WizardsThreatGuide
([forum](https://community.cloudflare.com/t/how-do-i-create-a-subdomain-and-redirect-it/74956/2))
1. Change DNS record to proxy if it was DNS-only
	1. Can make A rule `8.8.8.8` with comment
2. Create Page Rule, can use "URI Full" template
## Export and Delete cloud project
1. Export database
	1. Firebase Realtime Database can export JSON
2. Check auth users
3. Delete Firebase&GCP project
## Archive GitHub repo
> Before you archive, please consider:
> - Updating any repository settings
> - Closing all open issues and pull requests
> - Making a note in your README.md

1. Update summary description tags
2. Turn off Github Pages, custom domain
3. https://github.com/darthwalsh/$REPO/settings
