For work, have used AWS Lambda with python, and deployed to private cloud VMs.
For personal, have used GCP/Firebase Functions and Azure Web Apps.
- [ ] Anything else from [[TechStackFile]]?

I'm unhappy with the vendor-lock-in that comes from integrating into the serverless frameworks.
Wouldn't pushing a docker image that runs in a managed HTTP server be much more stable?

What is a good scale-to-zero web host that's simple for hobbyists? 

1. [[hosting.fly|fly.io]] looks great to try, and I'm ok with spending pennies
	1. [October 2024](https://www.srvrlss.io/blog/fly-io-pay-as-you-go/#conclusion) changed pricing to remove free tier
2. [heroku buildpacks](https://devcenter.heroku.com/articles/buildpacks) has custom support for languages
	1. that might be too much lock-in?
	2. In the past, had [free dyno hours](https://devcenter.heroku.com/articles/free-dyno-hours#dyno-sleeping) but now can use [Eco tier](https://www.heroku.com/pricing) that [[ScaleToZero]] after 30 minutes. If all budget used, will [shut down](https://devcenter.heroku.com/articles/eco-dyno-hours#dyno-sleeping) for rest of the month.
3. [render](https://render.com/pricing) has a better free tier, and seems better if you need databases and/or don't care about framework setup
4. https://container-hosting.anotherwebservice.com/ looks nice to use, but pretty bare-bones and I would rather pick a"boring" service i expect to be online in 10 years

