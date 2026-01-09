# TODO Categorization Analysis

This document categorizes all TODO items and checkbox items found in PowerShell (.ps1) files.

## Summary

- **Total items analyzed**: 33 (32 TODOs + 1 checkbox item)
- **Trivial to implement**: 9
- **Has mistaken/outdated assumptions**: 3
- **Requires significant work**: 20
- **Checkbox documentation items**: 1

---

## Trivial to Implement (9 items)

### 1. `ocr.ps1:5` - Move file to win/ directory
**File**: `ocr.ps1`  
**Line**: 5  
**TODO**: `TODO move to win/`  
**Category**: Trivial - Simple file move  
**Reasoning**: This is just a file organization task. The script already works only on Windows (calls `winocr`), so moving it to the `win/` subdirectory is straightforward.

### 2. `compress-jpg.ps1:23` - Support .jpeg extension
**File**: `compress-jpg.ps1`  
**Line**: 23  
**TODO**: `# TODO JPEG?`  
**Category**: Trivial - Simple extension check  
**Reasoning**: Currently only checks for `.jpg` extension. Adding support for `.jpeg` is a one-line change: `if ((Get-Item $File).Extension -notin @(".jpg", ".jpeg"))`.

### 3. `tmpobs.ps1:14` - Implement Windows support
**File**: `tmpobs.ps1`  
**Line**: 14  
**TODO**: `throw "TODO not implemented for windows"`  
**Category**: Trivial - Similar code already exists  
**Reasoning**: The Windows implementation already exists in `obslink.ps1:82`. The URL encoding and Start-Process logic can be copied directly, though there's a warning that it doesn't work perfectly.

### 4. `Get-Links.ps1:17` - Test on Windows
**File**: `Get-Links.ps1`  
**Line**: 17  
**TODO**: `# TODO does this work on windows too?`  
**Category**: Trivial - Just needs testing/documentation  
**Reasoning**: The code uses `$_.LinkType` which is a standard PowerShell property that works cross-platform. This TODO can likely just be removed after verification, or a simple comment added confirming it works.

### 5. `bak.ps1:8` - Write to log file instead of STDOUT
**File**: `bak.ps1`  
**Line**: 8  
**TODO**: `TODO instead write to Temp:\bakup/log.txt instead of STDOUT?`  
**Category**: Trivial - Simple output redirection  
**Reasoning**: The script already creates `Temp:\bakup` directory. Adding logging is straightforward - just redirect the `$bak` and `Convert-Path $bak` output to a log file instead of stdout.

### 6. `win/ping_mudd.ps1:33` - Fix windowstyle parameter
**File**: `win/ping_mudd.ps1`  
**Line**: 33  
**TODO**: `# TODO windowstyle not working`  
**Category**: Trivial - Known PowerShell issue with workaround  
**Reasoning**: The `-WindowStyle Hidden` parameter on line 32 isn't working. This is a known issue with `New-ScheduledTaskAction`. The workaround is to add `-WindowStyle Hidden` to the pwsh.exe arguments instead of relying on the parameter.

### 7. `mac/brewdump.ps1:14` - Next step reminder
**File**: `mac/brewdump.ps1`  
**Line**: 14  
**TODO**: `Write-Host "TODO Next step, run npx share-brewfiles?" -ForegroundColor Yellow # TODO`  
**Category**: Trivial - Just a user prompt/reminder  
**Reasoning**: This is already implemented as a yellow warning message. The TODO markers can be removed - it's functioning as intended to remind the user of the next manual step.

### 8. `obslink.ps1:86` - Use better URL encoding
**File**: `obslink.ps1`  
**Line**: 86  
**TODO**: `# TODO should probably be [uri]::EscapeDataString instead?`  
**Category**: Trivial - Simple function replacement  
**Reasoning**: Currently uses `[System.Web.HttpUtility]::UrlEncode()`. Changing to `[uri]::EscapeDataString()` is a one-line change and is indeed the more modern/correct approach for URI encoding in PowerShell.

### 9. `hard_disk_copy.ps1:16` - Fix hardcoded TODO path
**File**: `hard_disk_copy.ps1`  
**Line**: 16  
**TODO**: `$dest = Join-Path ~/OneDrive/TODO/HardDiskCopy $line`  
**Category**: Trivial - Configuration/path fix  
**Reasoning**: Similar to winocr.ps1, has literal "TODO" in the path. Should be replaced with an actual folder name. This might not even be a TODO - could be a folder literally named "TODO" for collecting items.

---

## Has Mistaken/Outdated Assumptions (3 items)

### 1. `win/Microsoft.PowerShell_profile.ps1:41` - Feature now mainstream
**File**: `win/Microsoft.PowerShell_profile.ps1`  
**Line**: 41  
**TODO**: `# TODO now mainstream: https://learn.microsoft.com/en-us/powershell/scripting/learn/experimental-features?view=powershell-7.5#pscommandnotfoundsuggestion EnsureExperimentalActive PSCommandNotFoundSuggestion`  
**Category**: Mistaken assumption - Feature is now stable  
**Reasoning**: The TODO itself states that `PSCommandNotFoundSuggestion` is now mainstream in PowerShell 7.5+. The code currently checks for `PSFeedbackProvider`. This TODO should be acted upon - the experimental check can likely be removed or updated to use the stable feature.

### 2. `gitodo.ps1:29` - Intent-to-add suggestion
**File**: `gitodo.ps1`  
**Line**: 29  
**TODO**: `# TODO try https://stackoverflow.com/a/857696/771768`  
**Category**: Mistaken assumption - Already partially implemented  
**Reasoning**: The comment suggests using `git add --intent-to-add` to allow diffing untracked files. However, the code right after this TODO (lines 25-31) already handles untracked files by listing them with `git ls-files --others` and running `Select-String` on them. The suggested approach might be cleaner, but the functionality already exists.

### 3. `c.ps1:47` - Unfinished script
**File**: `c.ps1`  
**Line**: 47  
**TODO**: `throw "TODO"`  
**Category**: Mistaken assumption - Script appears abandoned/incomplete  
**Reasoning**: The entire script is incomplete. Looking at the commented-out code and the script synopsis, it seems like it was meant to open vscode with stdin or based on a path, but was never finished. The parameter handling code is commented out. This is not a simple TODO - the entire script needs design and implementation, or should be removed if unused.

---

## Requires Significant Work (20 items)

### 1. `def.ps1:23` - Parse function calls to Python files
**File**: `def.ps1`  
**Line**: 23  
**TODO**: `# TODO parse a function like \`pipx run (Join-Path $PSScriptRoot gpx.py) @args\``  
**Category**: Complex - Requires PowerShell AST parsing  
**Reasoning**: Would need to parse PowerShell function definitions to extract Python file references from complex expressions. The current implementation just uses regex to find `.py` files, which is described as "hacky" but functional.

### 2. `gitstati.ps1:76` - Smart fetch optimization
**File**: `gitstati.ps1`  
**Line**: 76  
**TODO**: `# TODO by default skip fetching if recently fetched in last day, allowing for faster repeat runs`  
**Category**: Complex - Requires state tracking  
**Reasoning**: Would need to track last fetch time per repository (possibly in a cache file) and implement time-based logic. Requires design decisions about where to store this state and how to invalidate it.

### 3. `prev-daily.ps1:38` - Dynamic query generation
**File**: `prev-daily.ps1`  
**Line**: 38  
**TODO**: `# TODO should query this dynamically: https://chatgpt.com/share/68eeb509-684c-8011-98ff-c5a6f72d1dc2`  
**Category**: Complex - Requires Gmail API integration  
**Reasoning**: Currently hardcodes a Gmail search URL. Making it dynamic would require understanding user's important mail patterns or integrating with Gmail API to build the query programmatically.

### 4. `gitcam.ps1:7` - Add fixup commit support
**File**: `gitcam.ps1`  
**Line**: 7  
**TODO**: `TODO add parameter to create \`git commit --fixup\` instead of amend`  
**Category**: Moderate - Feature addition  
**Reasoning**: Needs to add a new parameter, implement `--fixup` logic, and then run `git rebase --autosquash`. The TODO describes the approach but it's a multi-step feature with potential edge cases.

### 5. `renovate_stats.ps1:3` - Complete implementation
**File**: `renovate_stats.ps1`  
**Line**: 3  
**TODO**: `TODO summarize the version bumps in renovate PRs`  
**Category**: Complex - Script purpose is the TODO itself  
**Reasoning**: The entire script is described as a TODO. While there's some implementation for parsing renovate commits, the actual summarization of version bumps is incomplete or not fully realized.

### 6. `ghrm.ps1:19` - Improve branch filtering logic
**File**: `ghrm.ps1`  
**Line**: 19  
**TODO**: `# TODO filtering out default branch feels like hack. Maybe want to go back to using the "commit was merged logic" from older version`  
**Category**: Moderate - Design improvement  
**Reasoning**: The current approach filters by branch name, but the author acknowledges this is hacky. The older commit-based merge detection would be more accurate but was removed for a reason. Would need to research why and potentially reimplement.

### 7. `gitrmrf.ps1:29` - Optimize git operations
**File**: `gitrmrf.ps1`  
**Line**: 29  
**TODO**: `Write-Warning 'TODO avoid churn always fetch first, then dont pull at end: git fetch origin "$($defBranch):$defBranch"'`  
**Category**: Moderate - Optimization  
**Reasoning**: Wants to reduce unnecessary network operations by fetching first (line 53) and not pulling at the end (line 67). Requires refactoring the git operations flow and testing that all scenarios still work correctly.

### 8. `repo-stats.ps1:5` - Implement scoring system
**File**: `repo-stats.ps1`  
**Line**: 5  
**TODO**: `TODO look at scoring system in https://github.com/ganesshkumar/obsidian-plugins-stats-ui/discussions/52`  
**Category**: Complex - Major feature addition  
**Reasoning**: The script currently just displays repo stats. Adding a scoring system would require defining metrics, weights, algorithms, and presenting the results. The TODO comments (lines 14-20) outline what metrics to consider but this is substantial work.

### 9. `dff.ps1:35` - Support file paths as parameters
**File**: `dff.ps1`  
**Line**: 35  
**TODO**: `# TODO allow left and right to be path as string or fileinfo objects`  
**Category**: Moderate - Parameter type enhancement  
**Reasoning**: Currently only accepts ScriptBlocks. Would need to modify parameter handling to detect if the input is a path (string or FileInfo) and treat it differently. Requires updating param validation and adding conditional logic.

### 10. `conv.ps1:15` - Handle empty first line
**File**: `conv.ps1`  
**Line**: 15  
**TODO**: `# TODO crashes if first line of stdin is empty. Maybe try if $input would be better`  
**Category**: Moderate - Bug fix  
**Reasoning**: Pipeline processing issue. The current begin/process/end blocks don't handle empty input well. Would need to refactor how stdin is collected and validated before processing.

### 11. `gh-branches.ps1:6` - Find associated PRs
**File**: `gh-branches.ps1`  
**Line**: 6  
**TODO**: `# TODO would be nice to find associated pull requests, and/or filter out branches with PRs`  
**Category**: Complex - GraphQL query expansion  
**Reasoning**: Would need to extend the existing GraphQL query to include PR information for each branch, match branches to PRs, and add filtering logic. The GraphQL query is already complex (lines 13-34).

### 12. `win/winocr.ps1:20` - Fix hardcoded TODO path and temp
**File**: `win/winocr.ps1`  
**Line**: 20  
**TODO**: `$path = "{0}\Clipboard-{1}.png" -f (Join-Path (Join-Path $Env:USERPROFILE OneDrive) TODO), ((Get-Date -f s) -replace '[-T:]', '_') # TODO move to temp?`  
**Category**: Trivial to Moderate - Two separate issues  
**Reasoning**: Two TODOs here: (1) The path has literal "TODO" text in it which should be replaced with an actual folder name, and (2) suggests moving to temp. The first is trivial, the second requires deciding on the right temp location and cleanup strategy.

### 13. `win/updateAll.ps1:5` - Reference ChatGPT conversation
**File**: `win/updateAll.ps1`  
**Line**: 5  
**TODO**: `TODO reference https://chatgpt.com/share/69097934-04a0-8011-a45e-40297aca7883`  
**Category**: Moderate - Documentation/research  
**Reasoning**: Needs to review the ChatGPT conversation and incorporate relevant information. Can't complete without access to that conversation and understanding what should be referenced.

### 14. `win/updateAll.ps1:6` - Document installation
**File**: `win/updateAll.ps1`  
**Line**: 6  
**TODO**: `TODO document how to install this using scripts: https://serverfault.com/a/1074285/243251`  
**Category**: Moderate - Documentation  
**Reasoning**: Needs to create installation documentation based on the Stack Overflow answer. The script header (lines 7-15) already has some installation instructions but could be enhanced.

### 15. `win/updateAll.ps1:17` - Error handling strategy
**File**: `win/updateAll.ps1`  
**Line**: 17  
**TODO**: `# $script:ErrorActionPreference = "Stop" TODO need to figure out how to handle updates that fail. Write to system mail?`  
**Category**: Complex - Error handling design  
**Reasoning**: The script intentionally doesn't set `ErrorActionPreference = "Stop"` (line 27) so it continues on failures. Proper error handling would require deciding how to notify the user (email? event log? status file?) and implementing that mechanism.

### 16. `obslink.ps1:82` - Fix Windows URI handling (warning)
**File**: `obslink.ps1`  
**Line**: 82  
**TODO**: `Write-Warning "TODO not working right to use obsidian:// URI in windows... see apps\ObsidianFolderOpen.md" # TODO`  
**Category**: Complex - Windows-specific issue  
**Reasoning**: The Obsidian URI scheme doesn't work correctly on Windows. The referenced documentation file (`apps\ObsidianFolderOpen.md`) would have more details. This likely requires Windows-specific handling or a different approach entirely.

### 17. `obslink.ps1:84` - Handle folder targets
**File**: `obslink.ps1`  
**Line**: 84  
**TODO**: `# TODO this doesn't work when the target is a folder? Need to find the last-updated MD file in the folder!`  
**Category**: Moderate - Feature enhancement  
**Reasoning**: When symlinking a folder, needs to find the most recently updated markdown file within it and open that. Requires adding directory detection, file searching, and sorting logic.

### 18. `Microsoft.PowerShell_profile.ps1:31` - Auto-generate Python script functions
**File**: `Microsoft.PowerShell_profile.ps1`  
**Line**: 31  
**TODO**: `# TODO loop over PY files with '# /// script' and create the functions?`  
**Category**: Complex - Dynamic function generation  
**Reasoning**: Would need to scan for Python files with PEP 723 inline script metadata, parse them, and dynamically create PowerShell functions. This is a metaprogramming task that requires careful design to handle edge cases.

### 19. `githist.ps1:175` - Add pagination
**File**: `githist.ps1`  
**Line**: 175  
**TODO**: `- TODO pagination`  
**Category**: Moderate - API enhancement  
**Reasoning**: The GitHub API search call needs pagination support to get all results beyond the first page. Requires implementing page loop logic and handling the pagination tokens from the API response.

### 20. `mac/dump.ps1:5` - Automate with scheduler
**File**: `mac/dump.ps1`  
**Line**: 5  
**TODO**: `TODO run this dump from a plist (for windows from windows task scheduler)`  
**Category**: Moderate - Automation setup  
**Reasoning**: Needs to create a macOS plist file (launch daemon/agent) and Windows Task Scheduler task to run this script automatically. Similar to the `win/ping_mudd.ps1` implementation pattern, but requires OS-specific configuration files.

---

## Checkbox Items (1 item)

### 1. `obslink.ps1:22` - Windows symlink behavior note
**File**: `obslink.ps1`  
**Line**: 22  
**Checkbox**: `- [ ] on Windows symlink to File doesn't show, but symlink to shows and is deleted just fine.`  
**Category**: Documentation/observation - Not a TODO  
**Reasoning**: This is an unchecked item in the documentation describing Windows-specific behavior. It's more of a known issue note than something to implement. The checkbox format might be meant for tracking testing or documenting quirks rather than work to be done.

---

## Recommendations

### High Priority (Easy wins)
1. Move `ocr.ps1` to `win/` directory
2. Add `.jpeg` support to `compress-jpg.ps1`
3. Remove TODO from `mac/brewdump.ps1` (already functioning as intended)
4. Change URL encoding in `obslink.ps1` to use `[uri]::EscapeDataString`
5. Update `win/Microsoft.PowerShell_profile.ps1` to use mainstream PSCommandNotFoundSuggestion

### Medium Priority (Good improvements)
6. Implement Windows support in `tmpobs.ps1`
7. Fix `win/ping_mudd.ps1` WindowStyle parameter
8. Fix path issues in `win/winocr.ps1` and `hard_disk_copy.ps1`
9. Write to log file in `bak.ps1` instead of STDOUT

### Low Priority (Requires design/research)
- Most other TODOs require significant work, design decisions, or research
- Consider whether `c.ps1` should be completed or removed if unused
- Many TODOs are enhancement requests rather than bugs, so prioritize based on user needs

### Won't Fix / Working As Intended
- `gitodo.ps1:29` - Already handles untracked files, suggestion is just an alternative approach
- `obslink.ps1:22` - Documentation of Windows behavior, not a task
