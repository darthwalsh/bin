# deps analysis plan

Goal: create a script that lists native command dependencies of all .ps1 scripts in bin/.

"Native" = external executables that must be installed (not PS built-ins, not other bin/ scripts).

---

## Method

1. Collect all script stems from `bin/*.ps1` and `bin/*.sh` — these are on PATH, so NOT native deps.
2. Extract command-position tokens from all `.ps1` files (start of statement, after `|`, after `&`).
3. Filter out:
   - PowerShell keywords: `if, else, elseif, foreach, for, while, do, switch, try, catch, finally, throw, return, break, continue, exit, param, begin, process, end, filter, function, class, enum, using, default, trap, where`
   - PS built-in cmdlet aliases: `cd, ls, dir, rm, mv, mkdir, cat, echo, copy, cls, type, del, md, rd, set, get, gci, sls, scb, pushd, popd, sleep, sort, select, measure, tee`
   - PS cmdlets (Verb-Noun pattern already filtered by lowercase check)
   - Other bin/ script names (from step 1)
   - Noise words that appear in variable/string context

---

## Bin script stems (NOT native deps)

DeleteLocalRemoteGitBranch, Get-Bin, Get-GitBranch, Get-GitDefaultBranch,
Get-InputOrClipboard, Get-Links, Get-StaticProps, RescueDay, Resolve-Host,
Test-Shebang, add_dotfile, all-colors, all-git-dirs, all-rg-colors, ansi,
apho, awswho, bak, binsls, branched-md, c, cdiff, chars, compress-jpg,
concat-audio, conv, cop, def, defe, dff, dim, dirsb, dsh, due, fail-log,
flf, flp, fn, funcmd, gb, gh-branch-protection-url, gh-branches, ghallrm,
ghb, ghchx, ghmerge, ghpagescf, ghrm, ghsls, ghtopdump, git-diff-lines,
gitcam, githist, gitjc, gitlog, gitodo, gitpr, gitrb, gitreor, gitrmrf,
gitstati, glo, guid, gwip, hard_disk_copy, in, install-deps, j2y, jj,
latest-down, logtime, lurls, metric-ansi, mv-ai, my, newps1, obslink, ocr,
pastebash, pomo, pretty, prev-daily, printkeep, pytree, quotation,
renovate-config-validator, renovate_stats, repo-stats, resolve-diff, rgg,
rm-empty, root, scan4github, setup, setup-cursor, slshist, splitargs,
splitpath, start-log, stravaCook, symmove, symunlink, tagthekeep, tmpgit,
tmpobs, tmpva, uncon, va, write-env, ymd

---

## Candidates found so far (command-position + pipe-position grep)

From frequency analysis of all .ps1 files in bin/ (maxdepth 2):

### Confirmed native (clearly external tools):
- `git`
- `gh` (GitHub CLI)
- `rg` (ripgrep)
- `glow` (markdown renderer)
- `jq` (JSON processor)
- `magick` (ImageMagick)
- `obsidian`
- `code` (VS Code)
- `oh-my-posh`
- `python` / `py`
- `npm` / `npx`
- `pwsh` (PowerShell itself)
- `ssh`
- `diff`
- `jira` (Jira CLI)
- `prettier`
- `nvm`
- `pipx`
- `sudo`
- `awk`
- `tr`
- `fold`
- `tail` (might be PS alias but also unix)
- `touch`

### Platform-specific candidates:
- `scoop` (Windows)
- `winget` (Windows)
- `brew` (macOS)
- `osascript` (macOS)
- `networksetup` (macOS)
- `shutdown`

### Still need to check (search was interrupted):
- `fd` (fd-find)
- `fzf`
- `bat`
- `delta` (git-delta)
- `lazygit`
- `eza` / `lsd`
- `zoxide`
- `starship`
- `tldr` / `tealdeer`

---

## TODO

- [ ] Complete search for fd, fzf, bat, delta and other modern CLI tools
- [ ] Read each flagged .ps1 file to verify command usage in context (not just strings/comments)
- [ ] Categorize: cross-platform vs mac-only vs win-only vs linux-only
- [ ] Write `deps-check.ps1` that runs `Get-Command <tool> -ErrorAction SilentlyContinue` for each and reports missing ones
- [ ] Decide: just print names, or check+report missing?

---

## Output script design

```
deps-check.ps1
  - Array of @{ Name='rg'; Desc='ripgrep' }, ...
  - foreach: if not found, output name (or "MISSING: rg")
  - or: just output all dep names (simpler, like the user said)
```
