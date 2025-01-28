## Chrome Browser handlers
In chrome://settings/handlers can adjust this later for specific websites
## `mailto` email
In https://mail.google.com/ can click the icon on omnibar to make gmail the default handler
*Note: this didn't work the first time, but removed and re-added the handler and now it worked. Maybe it would have worked to restart chrome*

Test it by clicking in browser and native apps: [click this email](mailto:carl@carlwa.com)
### Smart handler app
#app-idea 
- [ ] `mailto` handler that is generic email launcher (e.g. Android app for email intent) can discriminates based on the domain of the email account whether is launches Gmail/Outlook/etc using some matching rules.
## `tel` phone call / SMS
Chrome *used* to support this natively, but [removed it](https://x.com/ArtemR/status/1696692778233930031): see [Bring click-to-call back [40279622] - Chromium](https://issues.chromium.org/issues/40279622?pli=1).

#app-idea 
- [ ] Create a chrome app or native app `tel://` handler that redirects call to phone? Or extension that allows sharing into PushBullet? Or look into [this extension](https://chromewebstore.google.com/detail/send-to-my-device/nibihlffjdkcdmmdihndbmicgmbkppid)
- [ ] Also allow opening Messages For Web to send text message SMS/RCS to the number
