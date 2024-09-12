# Linux
From https://roadmap.sh/devops
> There are many tools available to monitor the performance of your application. Some of the most popular are:
> - `nmon` - A system monitor tool for Linux and AIX systems.
> - `iostat` - A tool that reports CPU statistics and input/output statistics for devices, partitions and network filesystems.
> - `sar` - A system monitor command used to report on various system loads, including CPU activity, memory/paging, device load, network.
> - `vmstat` - A tool that reports virtual memory statistics.

Only vmstat was installed by default on RHEL:
```
$ vmstat
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 1  0  13140 736348   3292 4715736    0    0     1    15    5    8  1  1 98  0  0
```

# macOS
```bash
memory_pressure | egrep 'free percentage: \d+'
```

# Windows
- Builtin: Task Manager
- Builtin: Resource Monitor
- [Process Monitor](https://learn.microsoft.com/en-us/sysinternals/downloads/procmon) procmon.exe
- [Process Explorer](https://learn.microsoft.com/en-us/sysinternals/downloads/process-explorer) procexp.exe