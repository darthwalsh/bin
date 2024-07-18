---
tags:
  - app-idea
---
GitHub app that solves the "I can't reproduce the problem on my machine"

1. checks github issue for reproduction steps
2. spins up a docker image and runs the steps
3. tags the issue as "reproducible" ...or closes the issue and encourages member to re-open
4. watches for issue to be edited, and re-runs steps

Cons: Remote code execution? You should host this in a no-privilege cloud environment.
Maybe you'd want a LLM to interpret the reproduction steps.