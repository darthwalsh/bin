`env` is a useful linux utility, useful for i.e. [[pwsh.tmp-env-var]]

## Windows
I found three different installations of `env` on my PC:
- [GOW](https://github.com/ScoopInstaller/Main/blob/master/bucket/gow.json)
- [Chocolately git](https://community.chocolatey.org/packages/git) MinGW64
- WSL has the normal linux env

```bash
$ C:\Users\cwalsh\scoop\shims\env.exe --version
env (GNU coreutils) 5.3.0
Copyright (C) 2005 Free Software Foundation, Inc.

$ & "C:\Program Files\Git\usr\bin\env.exe" --version
env (GNU coreutils) 8.32
Copyright (C) 2020 Free Software Foundation, Inc.

$ wsl /usr/sbin/env --version
env (GNU coreutils) 9.4
Copyright (C) 2023 Free Software Foundation, Inc.
```

There's a problem trying to use version 5 of `env`: it messes up spaces:
```bash
$ C:\Users\cwalsh\scoop\shims\env.exe python -c 'import sys; print(sys.argv)' abc def "g e f" '"x y"' "'zz'"  
File "<string>", line 1  
import  
      ^  
SyntaxError: Expected one or more names after 'import'
```

The other installations don't have this problem.
- [ ] #windows add `C:\Program Files\Git\usr\bin\` to PATH?