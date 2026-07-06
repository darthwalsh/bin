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

## Cursor agent shell doesn't see mise PATH
The Cursor Agent `Shell` tool runs a **non-interactive zsh** subprocess that only loads `~/.zshenv`:
```zsh
if [[ -n "$CURSOR_AGENT" ]]; then
  export PATH="$HOME/.local/share/mise/shims:$PATH"
fi
```

Can debug with [[mac-path]] to see the Cursor IDE has i.e. `PATH=/usr/bin:/bin:/usr/sbin:/sbin`
I thought to try [Mise VSCode](https://marketplace.visualstudio.com/items?itemName=hverlin.mise-vscode#overview) extension with [setting `mise.updateEnvAutomaticallyIncludePath`](https://hverlin.github.io/mise-vscode/reference/settings/#miseupdateenvautomaticallyincludepath) but Cursor didn't think it would affect agent `Shell`.

This is different than the Cursor Terminal addressed in [[cursor#Solution Conditional Shell Switch]]

## Where files land

Installation adds [[package.files]] under `~/.local/share/mise/installs/<tool>/<version>`; optionally `PATH` points to generated **shims** in `~/.local/share/mise/shims`, but no OS-level registration.
