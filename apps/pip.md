## pip freeze with req file
https://pip.pypa.io/en/stable/cli/pip_freeze/
>`-r, --requirement <file>`
>Use the order in the given requirements file and its comments when generating output. This option can be used multiple times.
- [ ] Might be useful?

## Where files land

Unpacks [[package.files]] into `site-packages`; entry points become launchers in `bin/` (Unix) or `Scripts/` (Windows); metadata in `*.dist-info/`.
