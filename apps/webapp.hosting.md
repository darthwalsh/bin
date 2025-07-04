TL;DR: ***What is a good scale-to-zero web host that's simple for hobbyists?*** 

For work, have used AWS Lambda with python, and deployed to private cloud VMs.
For personal, have used GCP/Firebase Functions and Azure Web Apps *(and now [[hosting.fly|fly.io]])*
- [ ] Anything else from [[TechStackFile]]?

I'm unhappy with the vendor-lock-in that comes from integrating into the serverless frameworks.

Wouldn't pushing a docker image that runs in a managed HTTP server be much more stable?
## Current docker hosting
[[hosting.fly|fly.io]] was easy to set up.

[October 2024](https://www.srvrlss.io/blog/fly-io-pay-as-you-go/#conclusion) changed pricing to remove free tier, but I'm ok with spending pennies.
## Other tools I might try
1. [heroku buildpacks](https://devcenter.heroku.com/articles/buildpacks) has custom support for languages
	1. that might be too much lock-in?
	2. In the past, had [free dyno hours](https://devcenter.heroku.com/articles/free-dyno-hours#dyno-sleeping) but now can use [Eco tier](https://www.heroku.com/pricing) that [[ScaleToZero]] after 30 minutes. If all budget used, will [shut down](https://devcenter.heroku.com/articles/eco-dyno-hours#dyno-sleeping) for rest of the month.
2. [render](https://render.com/pricing) has a better free tier, and seems better if you need databases and/or don't care about framework setup
3. https://railway.com/pricing - minimum cost $5
	1. "It's like if you had everything from an infra stack but didn't need to manage it (Kubernetes for resilience, Argo for rollouts, Terraform for safely evolving infrastructure, DataDog for observability)"
4. If all else fails, I might resort to [Oracle Cloud](https://www.oracle.com/cloud/free/) which can host docker containers for free
### Oracle is risky
From [Oracle Cloud deleting active user accounts without possibility for data recovery | Hacker News](https://news.ycombinator.com/item?id=42901897)
>Well since I'm not in the business of trusting a lot of corporations I decided to use a privacy.com virtual card that only had a one time transaction and would close afterwards. Well after signing up and starting the instance and doing some quick tests. I ended up coming back to it a bit later and found out the account was just out right terminated. After a while of going through support and looking around at what logs I could get, turns out they tried to do a $0.01 charge on the card and since it failed marked the card as stolen (or something similar.) And even with a long conversation with support they told me there was literally nothing that could be done, not even with proof of identification or anything. Even making a new account didn't work since something was matching and they were rejecting me making a new account (don't know if it was address, ip or my name.)
>
>At this point I share the opinion that others here are sharing, no matter the reason never work with oracle.

### More niche tools
- https://container-hosting.anotherwebservice.com/ looks nice to use, but pretty bare-bones and I would rather pick a"boring" service i expect to be online in 10 years
- https://shiper.app/
- https://sliplane.io/ looks nice too
- ~~chunk.run~~ web archive because site is down: [Chunk – From idea to live server-side code in seconds](https://web.archive.org/web/20240526144409/https://chunk.run/)
## Small Apps
https://cardstock.run/ runs [[python]] on the web

[Decker](https://beyondloom.com/decker/index.html) is a modern version of [HyperCard](https://en.wikipedia.org/wiki/HyperCard), scripted in [Lil](https://beyondloom.com/decker/lil.html)
