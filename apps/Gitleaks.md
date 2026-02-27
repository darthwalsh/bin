#ai-slop

Gitleaks is a static analysis tool designed to detect and prevent secrets (API keys, tokens, passwords) from being committed to Git repositories.

## The "Hybrid Config" Strategy
The most effective way to use Gitleaks is to extend the default community rules while refining them for your specific environment.

### 1. Extend Defaults
Use `useDefault = true` to inherit patterns for 100+ common services (AWS, Stripe, etc.).

### 2. Refine with Allowlists
Reduce noise by ignoring high-entropy strings that aren't secrets (e.g., `package-lock.json`, `node_modules`, or specific test mocks).

### 3. Secure with Internal Rules
Add custom regex patterns for proprietary internal tokens (e.g., `CORP-PROD-[A-Z0-9]{16}`).

## Usage Patterns
- **Pre-commit (`protect --staged`)**: Runs locally to prevent secrets from entering history.
- **CI/CD Pipeline**: Acts as a safety net to block PRs containing secrets.
- **Historical Audit**: Scans the entire commit history to find legacy leaks.

## Configuration Files

| File | Purpose |
| :--- | :--- |
| `.gitleaks.toml` | **Patterns**: Define rules and global path/regex allowlists. |
| `.gitleaksignore` | **Fingerprints**: Ignore specific, verified instances of a leak without changing global rules. |
## Out of Scope
- **Verification**: Gitleaks does not check if a key is active/valid.
- **Remediation**: It alerts you to leaks but does not rewrite history (use `git-filter-repo` for that).

## Global Setup (macOS)

To run Gitleaks on every commit without interfering with existing repo-specific `pre-commit` hooks, use a centralized hooks directory.

### 1. Install Gitleaks
```bash
brew install gitleaks
```

### 2. Create Centralized Hooks Directory
```bash
mkdir -p ~/.githooks
git config --global core.hooksPath ~/.githooks
```

### 3. Create the Hook Script
Create `~/.githooks/prepare-commit-msg`:

```bash
#!/bin/bash

set -euo pipefail

# --- Global Secret Scanner ---
# Runs alongside existing hooks. Only scans actual commits.
# Bail on merge/squash templates; only scan real commits
if [ "$2" = "message" ] || [ "$2" = "template" ] || [ -z "$2" ]; then
    if command -v gitleaks &> /dev/null; then
        # --staged: check what is currently in the index
        gitleaks protect --staged --verbose
        
        EXIT_CODE=$?
        if [ $EXIT_CODE -ne 0 ]; then
            echo "-------------------------------------------------------"
            echo "❌ GITLEAKS DETECTED SECRETS"
            echo "Commit blocked for security. Remove secrets and try again."
            echo "-------------------------------------------------------"
            exit $EXIT_CODE
        fi
    fi
fi
```

### 4. Make Executable
```bash
chmod +x ~/.githooks/prepare-commit-msg
```

## Co-existing with `pre-commit`
The `pre-commit` framework (Python) typically manages the `.git/hooks/pre-commit` file. By using the `prepare-commit-msg` hook slot, Gitleaks runs independently.

> **Warning**: Setting `core.hooksPath` globally disables all local hooks in `.git/hooks/` for all repositories. To support local hooks alongside this global hook, your global script must explicitly call the local equivalent if it exists.

### Supporting Local Hooks
Update your `~/.githooks/prepare-commit-msg` to include:
```bash
LOCAL_HOOK=".git/hooks/prepare-commit-msg"
if [ -f "$LOCAL_HOOK" ] && [ ! -L "$LOCAL_HOOK" ]; then
    "$LOCAL_HOOK" "$@"
fi
```

## Testing the Setup
```bash
echo "pi_token = 'SG.5p3k_this_is_a_fake_token_long_enough_to_trigger_entropy'" > test_leak.txt
git add test_leak.txt
git commit -m "Test"
```
