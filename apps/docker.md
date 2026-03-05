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
## System Requirements
Docker containers share the host kernel. They're not VMs themselves, but they require a Linux kernel with the right features. This is why Docker works inside a Linux VM but not in user-space syscall translation layers (proot, [[Termux]])

Docker requires a **Linux kernel** with support for:
- [[LinuxNamespaces|Namespaces]] (PID, NET, MNT, IPC, UTS, USER, CGROUP, TIME) for isolation — CGROUP is a namespace type, but cgroups (the resource control feature) existed before namespaces
- **cgroups** (control groups) for resource limits — the underlying kernel feature for CPU/memory/IO limits
- [ ] #android Check docker support in: Debian VM in Android's Linux Terminal 

On Windows/macOS, Docker Desktop runs a Linux VM. (Unless using [Windows Containers](https://learn.microsoft.com/en-us/virtualization/windowscontainers/about/)!)
