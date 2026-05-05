mise is a package manager for tools. It is a replacement for [[brew]] and [[asdf]].
I have [linked dotfile](../dotfiles/.mise.toml).

## upgrading
Updating versions pinned to `latest` requires running [`mise upgrade`](https://mise.jdx.dev/cli/upgrade.html) explicitly — nothing auto-upgrades in the background like [[brew#Autoupdate in the background]]

Run periodically via [scheduled job](../dotfiles/.pitchfork.toml) like [[pitchfork]]:
```bash
mise plugins update          # refresh plugin registry (optional, harmless)
mise upgrade                 # upgrade all tools matching their selectors
mise prune --tools           # prevents unused old versions from accumulating on disk
```

 `mise cache clear` is for manual troubleshooting: not worth scheduling.

## Supply-chain hardening: `install_before`

The [`install_before`](https://mise.jdx.dev/tips-and-tricks.html#minimum-release-age) setting rejects tool versions with publish date newer than a given age:

```toml
# ~/.config/mise/config.toml
[settings]
install_before = "7d"
```

## Reinstalling gh after corruption
>The gh install was corrupted during the upgrade — the extracted zip contents were nested one level too deep (`gh_2.92.0_macOS_arm64/` subdirectory) so mise couldn't find the binary and didn't register it as a valid shim.

Reinstalling from scratch resolved it:
```
mise uninstall gh@2.92.0 && mise install gh@latest
```