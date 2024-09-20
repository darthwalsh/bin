Several linux resources are controlled by namespaces, allowing different containers to avoid collisions.

From https://en.wikipedia.org/wiki/Linux_namespaces
Also see less technical summary at: https://www.redhat.com/sysadmin/7-linux-namespaces
Also see more technical, with labs: https://book.hacktricks.xyz/linux-hardening/privilege-escalation/docker-security/namespaces
- USER: User ID
	- different users with different privileges
		- container with a root user that can admin the 
		- root user in container can have ID 0, while it has another user ID by the system
		- ditto for groups
	- All these namespaces are owned by some user namespace
		- Parent namespaces have permission to change a namespace
	- at creation, empty set of users
- CGROUP: Control Group
	- cgroups are another important part of containers
		- Resource limiting (CPU, memory, disk I/O), prioritization, 
		- Kernal can OOM all processes in cgroup as a unit
		- (One other important part of containers is chroot. After creating "chroot jail" a process sees a new root directory)
	- first cgroup API was before namespaces
- PID: process ids
	- first process id in namespace is numbered 1, treated as init process
	- nested, so new process will have a PID in each namespace up the tree
- MNT: mount points
	- won't be shared by default, unless opting win with "shared subtrees"
	- resource copied to new namespace on creation, but new mounts aren't shared
- NET: network 
	- at first, contains only loopback
	- resource is in only one namespace
- IPC: inter-process communication
	- manages "System V IPC"
	- [System V IPC](https://man7.org/linux/man-pages/man7/svipc.7.html)  is "message queues, semaphores, and shared memory" and gives full docs
	- chatGPT says "it was introduced in AT&T’s UNIX System V, hence the name" 
	- resource is in only one namespace
- UTS: Unix Time-Sharing
	- name is confusing: allows for different host/domain names
	- resource is copied on namespace creation
- TIME: 
	- see a different system time


I've heard that Docker isn't a safe way to run malicious code, in the way that a VM is.
There [exist](https://book.hacktricks.xyz/linux-hardening/privilege-escalation/docker-security/docker-breakout-privilege-escalation) several escapes from incorrectly configured containers, and one exploitable CVEs.
