- [ ] try https://nixcloud.io/tour/

There are several related tools:
- [Nix](https://wiki.nixos.org/wiki/Nix "Nix") package manager for reproducible builds
    - [`nix-build`](https://nix.dev/manual/nix/2.18/command-ref/nix-build) builds the nix file
    - [`nix-shell`](https://nix.dev/manual/nix/2.18/command-ref/nix-shell) starts shell with dependencies in path
    - [`nix-env`](https://nix.dev/manual/nix/2.18/command-ref/nix-env) user environments are sets of packages, managed with imperative commands
- [Flakes](https://wiki.nixos.org/wiki/Flakes) is experimental way to pin dependencies in lock file
- [Home Manager](https://wiki.nixos.org/wiki/Home_Manager) manages user's installed software and [[dotfiles]] using nix
    - Instead of having immutable config, much easier to use symlinks i.e. `stow`: [Why I'm Ditching Nix Home Manager](https://www.youtube.com/watch?v=U6reJVR3FfA&lc=UgzHwWeNoSnRpB5vi0x4AaABAg)
- [NixOS](NixOS) - Linux distro based on Nix, with declarative system config

## Zero-to-nix guide
i.e. https://zero-to-nix.com/concepts/flakes or https://zero-to-nix.com/concepts/nixos is much easier to understand
- [ ] Replace links and summaries above

## NixOS WSL support
https://github.com/nix-community/NixOS-WSL/issues/63
Seems like it's mostly working, just haven't got the package into the store yet

# On MacOS
Looks like it's somewhat supported to use home-manager on MacOS

## Tools
https://github.com/nix-community/lorri
>lorri is a `nix-shell` replacement
>When changes are made that would affect a project's development shell, lorri builds the new shell in the background, and applies the result on the next shell prompt.
