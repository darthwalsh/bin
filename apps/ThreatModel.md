#ai-slop

This article defines my preferred threat model for personal development and security tool configuration.

## Core Philosophy

The primary goal is to balance strong cryptographic security with developer productivity. This model assumes a high level of trust in the local environment and focuses on protecting against remote extraction and impersonation.

## Trust Assumptions

- **Trusted Host**: The local machine is assumed to be free of malware. Any process running as the current user is considered benign and authorized.
- **Trusted UX**: Protection against UI confusion or "click-jacking" (where a user is tricked into clicking one thing when they intended another) is not a primary concern. In web browser, only applies to **Trusted User Interface**.
- **Remote Web Compromise**: If a Relying Party (RP), Identity Provider (IdP), or browser has vulnerabilities that allow unauthorized background authentication, it is treated as a bug in that specific platform, not a failure of this threat model.
- **Automation is Allowed**: Scripts and automated processes using SSH or cryptographic signing without manual prompts are acceptable and desired.
- **Login-as-you is not inherently harmful**: Being signed into a personal account is not considered a security-relevant event by itself.

## Security Priorities

| Priority | Description |
| :--- | :--- |
| **Non-extractability** | Private keys must never be stored in a way that they can be easily copied or exported from the secure storage (e.g., hardware token, Secure Enclave, or encrypted vault). |
| **Anti-impersonation** | Remote attackers should not be able to authenticate or sign operations without physical access to the key or the specific authorized session. |
| **Origin Binding** | Protection against phishing via mechanisms like WebAuthn that bind credentials to specific domains. |

## What is Deprioritized

- **User Presence (UP)**: Physical "touch" requirements for every operation are often seen as unnecessary friction if the host is trusted.
- **User Verification (UV)**: Frequent PIN or biometric prompts for every sub-operation are deprioritized in favor of session-based or application-based authorization.
- **Proof of Intent**: Proving that a human understood and intended a specific cryptographic operation (e.g., "I am signing this specific git commit") is not required for every action.

## Application-Specific Semantics

### SSH & Git
- **Goal**: Silent authentication for known hosts and tools.
- **Acceptable Risk**: Any process that can reach the SSH agent can authenticate.

The [[1Password]] SSH agent can set up a different socket (`SSH_AUTH_SOCK`). Need to select "Always Allow" on system startup; so causes extra friction.

### Local Secrets (Tokens/API Keys)
- **Goal**: Prevent accidental exposure (e.g., git push) and ensure non-extractability.
- **Philosophy**: macOS Keychain's "Always Allow" model is considered "security theater" because it is easily subverted by malicious child processes (like `npm` scripts) in an authorized terminal.
- **CLI Secret Manager Comparison**:
    - **macOS Keychain (`security`)**: Built-in but relies on "Trusted App" model. "Always Allow" bypasses UP/UV entirely after the first click, making it vulnerable to "confused deputy" attacks.
    - **1Password CLI (`op`)**: Preferred for developer-friendly biometric (Touch ID) unlock. Supports configurable session timeouts (UV via biometrics, UP via Touch ID).
    - **Keeper Commander (`keeper`)**: Open-source CLI/SDK. Supports Master Password, MFA, SSO, and biometrics. Highly automatable but requires a "session" login (UV via master password/SSO). [Source](https://docs.keeper.io/en/keeperpam/commander-cli/overview)
    - **pass (The Standard Unix Password Manager)**: GPG-based. UP/UV depends on GPG agent configuration (PIN entry/Touch on YubiKey). Extremely minimal, but requires managing a GPG key.
- **Acceptable Risk**: Plaintext files are acceptable for low-stakes automation *if* combined with robust local scanning (Gitleaks) to prevent remote leakage.

### WebAuthn / FIDO2
- **Goal**: Phishing resistance and hardware-backed credentials.
- **Acceptable Risk**: Silent login to accounts once the initial "ceremony" is completed, if the platform allows.

### OpenPGP / GPG
- **Goal**: Secure signing and decryption with minimal friction.
- **Acceptable Risk**: Ambient signing/decryption by authorized local processes.

