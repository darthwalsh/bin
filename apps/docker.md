`docker` is a powerful tool that combines the reliability of deploying a virtual machine with the performance of running a native app.
## Rough metaphor
When coding, the idea of compiling code into a binary and running it is second nature:
- *Dockerfile* is like "source code" to build a docker image
- *Docker Image* is the built "binary executable"
- *Docker Container* is the "running process" with state 
## Tips
- `git config --global url."https://$GITHUB_TOKEN@github.com/".insteadOf https://github.com/` is handy for hardcoding auth for the whole container
	- ***But*** don't publish docker containers with secrets in them. Newest docker supports [build secrets](https://docs.docker.com/build/building/secrets/#using-build-secrets).
- If a huge `docker` command line is getting awkward, consider [[docker-compose]].
## Cons
- [ ] Some criticism: [Are Dockerfiles good enough?](https://matduggan.com/are-dockerfiles-good-enough/)