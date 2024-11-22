Current default picks for package manager.
- Windows: [[scoop]]
    - Previously used [[choco]] extensively
    - Still occasionally using [[winget]] but don't like some elements of it
- macOS: [[brew]]
- Linux: dnf / [[brew]] / etc

Also use the mac/windows first-party app stores as a fallback.
Also use language-specific managers for python: global pip [^1], nodejs, and also some locally built golang apps.


[^1]: I'm not counting `pipx` or `npx` having some cached package. They are ephemeral by definition.
