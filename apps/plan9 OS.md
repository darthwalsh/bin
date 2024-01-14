Plan 9 is a different OS, a kind of UNIX successor

The second idea (a message-oriented filesystem) means that processes can offer their services to other processes by providing virtual files that appear in the other processes' namespace. The client process's input/output on such a file becomes inter-process communication between the two processes. This way, Plan 9 generalizes the Unix notion of the filesystem as the central point of access to computing resources. It carries over Unix's idea of device files to provide access to peripheral devices (mice, removable media, etc.) and the possibility to mount filesystems residing on physically distinct filesystems into a hierarchical namespace, but adds the possibility to mount a connection to a server program that speaks a standardized protocol and treat its services as part of the namespace.
https://en.wikipedia.org/wiki/Plan_9_from_Bell_Labs?wprov=sfla1

https://orib.dev/git9.html