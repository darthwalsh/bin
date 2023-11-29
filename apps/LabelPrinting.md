TL;DR: How to easily print Christmas Card envelop labels from your Google Contacts

### Problems
Maintaining a huge spreadsheet and template DOCX with everybody's emails is a huge pain

Instead, can maintain a mailmerge spreadsheet using Avery Label software

Maintaining [[Google Contacts]] with updated shipping address still takes effort every year.
- https://webapps.stackexchange.com/questions/1584/is-there-a-way-to-share-synchronize-contacts-between-google-accounts
- Syncing with your spouse:
	- Plenty of contact-sync apps from 2010's, but are they still working & reputable?
	- https://twitter.com/talexe/status/1604628321765318657
- On Twitter I [complained](https://twitter.com/carlfwalsh/status/1612514834838605824) about Google CSV not having the right address fields for import into 
- I'll need a new field `__XMAS_DISPLAY_NAME` for i.e. "The Smith family" vs "Jon Smith and Jane Smithette" etc.

### My workflow
Same as https://gist.github.com/kgodard/5072573

### My ideal workflow: project LabelLambda
1. Export Google CSV, run some script, outputs mailmerge.CSV
2. ...?
3. Profit!

*? Alt Name: LabelLlama already taken... use a emoji like Label🐑 or Labelλ*

### Existing workflows
https://www.youtube.com/watch?v=g2CmGJNsXp0
> Export Google contact CSV
> Edit columns
> Import Avery online template
> Uses fields: First / Last / Street / City / State / ZIP

https://gist.github.com/kgodard/5072573
> In Google Sheets manually edit mailmerge CSV
> Detailed steps for Avery Print Online

https://handylabelmaker.com/
> Only **$19.95** *Regularly $39.95. Save 50%!*
> Export contacts to Yahoo, Google, other email system, or mobile device!
> Requires Windows

---

### Update forums if I find the solution
- https://twitter.com/carlfwalsh/status/1612514834838605824
  
> In order to use google contacts CSV, I'd need a new tool that can expand "Address 1 - Formatted" column? Plus, I'll need a new field __XMAS_DISPLAY_NAME  
> Maybe in 11 months I'll try to build this...  
  
https://twitter.com/talexe/status/1604628321765318657?t=h5kF1YPQ43W8xH2AxhK0PA&s=09

> Until you get married. Then you suddenly have an Excel spreadsheet!
