#ai-slop

# Package Search & Discovery

How to find a package when you don't know its name yet — per ecosystem.

**Also see:** [[package manager]] for installation tooling.

## Cross-Ecosystem

| What                          | Tool                                                                                                                               |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| Multi-ecosystem aggregator    | [Libraries.io](https://libraries.io/) — PyPI, npm, Maven, NuGet, etc. with popularity/maintenance metadata                         |
| Cross-distro package versions | [Repology](https://repology.org/) — compare package versions across 50+ distros (apt, dnf, pacman, brew, nix, scoop, choco, etc.)  |
| Search by real code usage     | [grep.app](https://grep.app/) — fast GitHub-wide code search; search import patterns to discover what package name provides an API |
| AI-assisted code search       | [grep-mcp](https://github.com/galprz/grep-mcp) — MCP server exposing grep.app for LLM tool calls                                   |

**Practical workflow when you don't know the name:** search grep.app for an API call you'd expect (e.g. `from ? import slugify`), read the import statements to identify the package, then validate quality on the ecosystem-specific site below.

---

## Language Packages

| Ecosystem | Official | Better search |
|-----------|----------|---------------|
| **JS / TS** | [npmjs.com](https://www.npmjs.com/) · `npm search <kw>` | [npms.io](https://npms.io/) (quality/popularity/maintenance score), [npm.io](https://npm.io/) |
| **Python** | [pypi.org](https://pypi.org/) · `pip install <pkg>` | [PyDeps](https://pypiplus.com/) (dep graph), [pip-search](https://pypi.org/project/pip-search/) (`pip_search <kw>` in CLI) |
| **Rust** | [crates.io](https://crates.io/) · `cargo search <kw>` | [lib.rs](https://lib.rs/) (curated categories + trending) |
| **Go** | [pkg.go.dev](https://pkg.go.dev/) (also searches symbols) · `go get <mod>` | [gofind](https://github.com/sheepla/gofind) (pkg.go.dev from CLI) |
| **Java / JVM** | [central.sonatype.com](https://central.sonatype.com/) · [search.maven.org](https://search.maven.org/) | [mvnrepository.com](https://mvnrepository.com/) (nicer browsing UX) |
| **.NET / C#** | [nuget.org/packages](https://www.nuget.org/packages) · `dotnet package search <kw>` | — |
| **Haskell** | [hackage.haskell.org](https://hackage.haskell.org/) | [Hoogle](https://hoogle.haskell.org/) — search by **type signature**, not just name |

---

## System / Distro Packages

| Ecosystem                 | Official                                                                              | Better search                                                                                                                                    |
| ------------------------- | ------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| **macOS (brew)**          | [formulae.brew.sh](https://formulae.brew.sh/) · `brew search <kw>`                    | [brewdb.xyz](https://brewdb.xyz/) (modern UI), [Repology](https://repology.org/)                                                                 |
| **Arch / AUR (yay/paru)** | [aur.archlinux.org](https://aur.archlinux.org/packages/) · `yay -Ss <kw>`             | [Repology](https://repology.org/)                                                                                                                |
| **Debian/Ubuntu (apt)**   | `apt-cache search <kw>` · [packages.debian.org](https://packages.debian.org/)         | [Repology](https://repology.org/) (cross-check versions across distros)                                                                          |
| **Fedora/RHEL (dnf)**     | `dnf search <kw>` · [packages.fedoraproject.org](https://packages.fedoraproject.org/) | [Repology](https://repology.org/)                                                                                                                |
| **Nix**                   | [search.nixos.org](https://search.nixos.org/packages) · `nix search nixpkgs <kw>`     | [Repology](https://repology.org/)                                                                                                                |
| **pkgx**                  | [pkgx.dev/pkgs](https://pkgx.dev/pkgs/) · `pkgx -Q <kw>`                              | —                                                                                                                                                |
| **winget**                | `winget search <kw>`                                                                  | [winget.run](https://winget.run/) (fuzzy matching, filtering by tags/publisher)                                                                  |
| **scoop**                 | `scoop search <kw>` · [scoop.sh](https://scoop.sh/)                                   | [scoopsearch.search.windows.net](https://scoopsearch.search.windows.net/) (official), [scoop-directory](https://rasa.github.io/scoop-directory/) |
| **choco**                 | `choco search <kw>`                                                                   | [community.chocolatey.org/packages](https://community.chocolatey.org/packages)                                                                   |

---

## Semantic / Behavioral Search (Research Territory)

The idea of searching by *what a function does* (input/output examples, test cases) rather than its name exists mostly as research. Closest practical things today:

- **Type-directed:** [Hoogle](https://hoogle.haskell.org/) (Haskell), `pkg.go.dev` symbol search (Go)
- **Upgrade validation:** [edgetest](https://pypi.org/project/edgetest/) (Python) — runs your tests against newer versions to check compatibility
- **Academic:** Zaremski & Wing 1995 "Specification Matching of Software Components" — the canonical reference for theorem-prover-based retrieval
