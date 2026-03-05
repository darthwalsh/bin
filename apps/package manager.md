Current default picks in order:

## System Package Managers

- xplat
    - [ ] Try meta-manager [AnyPackage](https://www.anypackage.dev/)
    - [ ] Try [eget: Easily install prebuilt binaries from GitHub.](https://github.com/zyedidia/eget)
    - [ ] Try [Zero Install](https://docs.0install.net/)
    - `uvx`/`pipx` or `npx` for language-specific commands
- Windows: [[scoop]] is best when you want 0 registry integration, portable installs
    - [[winget]] seems to work better for complicated installers that require admin anyways, and queries the Microsoft Store for apps
    - Previously used [[choco]] extensively, but trying not to use it. Next time, would run as "user account"
    - Once tried [Ninite](https://ninite.com/): limited choice of apps, but simple GUI
- macOS: [[brew]], or App Store, or [[tea#pkgx Ecosystem|pkgm]]
- Linux: [[tea#pkgx Ecosystem|pkgm]] / dnf / [[brew]] / etc: see [[linux#Families with packaging]]
- Android Termux: [pkg]([Package Management - Termux Wiki](https://wiki.termux.com/wiki/Package_Management))
- ChromeOS: [Chromebrew](https://chromebrew.github.io/)

## Per-Project tool managers
- [ ] Try [`mise`](https://mise.jdx.dev/getting-started.html) (xplat) — version-locks runtimes (Node, Python, Go) + CLIs
    - [ ] also, look into replacing other tools:
    - [ ] Environment Management replaces like `direnv` or [[va.ps1]]
    - [ ] automating tasks like `make`, `task`, or `just`
- asdf (doesn't support Windows, older, plugin-based, mise is compatible)
- uv / pyenv / ~~nvm~~ (single-language alternatives)

## Library dependency managers
- uv/hatch/pip/pipenv/poetry (Python)
