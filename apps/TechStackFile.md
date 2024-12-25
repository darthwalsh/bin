# My Design Sketch
- Probably first YAML file with each of our cloud resources
- Nice to have some markdown blurb too
- Would be good to have some cloud automation, but also be able to run locally

## e.g. stack for https://github.com/darthwalsh/dotNetBytes
- Status: Maintenance mode (or Active, Alpha, Done, etc.)
- Languages
    - C#
    - JS
    - IL
- Framework
    - dotnet6
        - *deprecated e.g. 2028-01-01*
    - browser JS
    - mstest v2
- CI/CD
    - Appveyor
        - link: https://ci.appveyor.com/project/darthwalsh/dotnetbytes
        - Images: Win10 VS2022
    - *9/10 last builds succeeded*
- Cloud:
    - GCP Function
        - version: v1
        - runtime dotnet6
        - *deprecated e.g. 2025-01-01*
    - *Billing: free tier*
- Databases
- Publish to:
    - Docker images/registory
    - nuget/npm library
    - cloud S3 bucket
    - Github Pages / CloudFlare Pages
- Dependency automated update:
- Published libraries to nuget

Key:
- *italics:* nice to have, but could be added in some post-processing state and not in YAML

Then last, I could have a script to combine the tables into one big my-projects stack?
- Maybe use symlink or markdown embed

- [ ] idea: copy some of the markdown-summary/techstack.md or YML syntax from https://github.com/stackshareio/awesome-stacks/pull/77/files#diff-937a76ed9e53c397ca8eff62b127e9cdcdceb26d9752e92522d5271661d6ad15
# StackShare
https://stackshare.io/tech-stack-file
- [x] Installed on three cloudish repos: https://github.com/settings/installations/54196617
- [x] draft email to tell them about 404: https://web.archive.org/web/20240816185658/https://github.com/marketplace/stack-file

### GitHub app not working...?
- [x] Waiting on https://stackshare.io/stack-file-management 🛫 2024-08-27

Sent email to stackshare@fossa.com based on their website Contact us:

---

> Hi Stack Share @ FOSSA,
> 
> I was talking to my sister about wanting a standardized YAML manifest file of which tools each of my github projects uses, and came across [https://stackshare.io/tech-stack-file](https://stackshare.io/tech-stack-file) which sounds like the _perfect_ solution!
> 
> The github app doesn't seem to be working though...?
> 
> I tried installing [https://github.com/apps/stack-file](https://github.com/apps/stack-file) a week ago, and added it to a few github repos, and [https://stackshare.io/stack-file-management](https://stackshare.io/stack-file-management) still shows it is stuck on the first step.  
> 
> `![image.png]()`
> 
> 
> Something is wrong with the demo at [https://stackshare.io/tech-stack-file](https://stackshare.io/tech-stack-file) too.
> 
> I tried running a few different github repos in the section "Get a sample tech stack file for a public GitHub repo", and all gives the same error: "Server error"
> 
> 
> Anyways, I'm quite interested in getting this tool to work, so any support is appreciated!
> 
> Do you have a github repo for the tech-stack-file project with issue tracker or source code? I'm happy to roll my sleeves up and help if that's possible :)
> 
> Thanks,
> Carl Walsh
> 
>   
> PS Some of the links go to the link [https://github.com/marketplace/stack-file](https://github.com/marketplace/stack-file) gives 404 error
> (i.e. go to the very bottom [https://stackshare.io/tech-stack-file](https://stackshare.io/tech-stack-file) where it says "Generated via [Stack File](https://github.com/marketplace/stack-file)")

----

but this email bounced
FROM: mailer-daemon@googlemail.com

> We're writing to let you know that the group you tried to contact (stackshare) may not exist, or you may not have permission to post messages to the group. A few more details on why you weren't able to post:  
>   
>  * You might have spelled or formatted the group name incorrectly.  
>  * The owner of the group may have removed this group.  
>  * You may need to join the group before receiving permission to post.  
>  * This group may not be open to posting.  
>   
> If you have questions related to this or any other Google Group, visit the Help Center at [https://support.google.com/a/fossa.com/bin/topic.py?topic=25838](https://support.google.com/a/fossa.com/bin/topic.py?topic=25838).  
>   
> Thanks,  
>   [fossa.com](http://fossa.com/) admins

### Email not working...?
- [x] pinged them on twitter https://x.com/carlfwalsh/status/1829890127663153469
- [ ] follow up on other support channels? 🛫 2024-09-14 

# PoC
- [ ] PoC take a note of different firebase projects, using whichever API
[Code search results](https://github.com/search?q=org%3Adarthwalsh+firebase+NOT+language%3AJSON+language%3AHTML&type=code&l=HTML)  
[Code search results](https://github.com/search?q=org%3Adarthwalsh+firebase+NOT+language%3AJSON+language%3AJavaScript&type=code&l=JavaScript)  
[Code search results](https://github.com/search?q=org%3Adarthwalsh+firebase+NOT+language%3AJSON+language%3APython&type=code&l=Python)  
[Code search results](https://github.com/search?q=org%3Adarthwalsh+firebase+NOT+language%3AJSON+language%3APowerShell&type=code&l=PowerShell)