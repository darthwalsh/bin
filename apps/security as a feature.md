*Some thoughts I shared on an internal forum*

I initially thought we should be able to ignore a vulnerability that’s not exploitable in the way we use a dependency… but seeing how vulns in dependencies-of-dependencies have a ripple effect for every consumer, I see now why we have a zero-tolerance stance to ignoring issues instead of fixing them. If your dependencies have a different policy towards scanning/fixing vulns, it seems like that’s a systematic issue to be fixed?

Security is another business requirement like performance or uptime or correctness, so what do you do when your dependencies can’t meet other business requirements? If your service promises 5 9's but you depend on something with only 4 9's, your project will eventually not meet its requirements.

I’d first communicate with the project owners, and if that doesn’t work you escalate to managers, directors, etc. Before each escalation, I’d put more effort into investigating the risks/costs of how we’d stop using that dependency.

One other feeling I have about “heroics” — I have read an interesting document [about that](https://rpadovani.com/no-heroes). The short summary is it’s not sustainable for individuals to apply band-aid solutions over systemic problems. Instead, let things fail, while spending your team’s limited time working to solve the problem systemically.

On some of our projects, we’ve had great success using [Renovate Bot](https://www.mend.io/renovate/) to submit PRs with the latest versions of each dependency. Maybe the dependency teams could start using that in their projects?