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
3. If all else fails, I might resort to [Oracle Cloud](https://www.oracle.com/cloud/free/) which can host docker containers for free
4. https://railway.com/pricing - minimum cost $5
	1. "It's like if you had everything from an infra stack but didn't need to manage it (Kubernetes for resilience, Argo for rollouts, Terraform for safely evolving infrastructure, DataDog for observability)"
### More niche tools
- https://container-hosting.anotherwebservice.com/ looks nice to use, but pretty bare-bones and I would rather pick a"boring" service i expect to be online in 10 years
- https://shiper.app/
- https://sliplane.io/ looks nice too
- ~~chunk.run~~ web archive because site is down: [Chunk – From idea to live server-side code in seconds](https://web.archive.org/web/20240526144409/https://chunk.run/)

