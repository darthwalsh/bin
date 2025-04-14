Current default picks for package manager.
- Windows: [[scoop]] is best when you want 0 registry integration, portable installs
    - [ ] If adding tool for just on project, consider using [`mise`](https://mise.jdx.dev/getting-started.html)
    -  [[winget]] seems to work better for complicated installers that require admin anyways
    - Previously used [[choco]] extensively, but trying not to use it. Next time, would try as "user account"
- macOS: [[brew]]
- Linux: dnf / [[brew]] / etc

Also use the mac/windows first-party app stores as a fallback.
Also use language-specific managers for python: global pip [^1], nodejs, and also some locally built golang apps.


[^1]: I'm not counting `pipx` or `npx` having some cached package. They are ephemeral by definition.
