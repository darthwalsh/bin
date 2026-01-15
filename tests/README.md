# Testing

## Prerequisites

- PowerShell Core (pwsh) - required to run tests on all platforms
- Pester 5.x - PowerShell testing framework

### Installing Prerequisites

#### Linux/macOS
```bash
# Install PowerShell Core
# For Ubuntu/Debian:
wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y powershell

# For macOS with Homebrew:
brew install --cask powershell

# Install Pester
pwsh -Command "Install-Module -Name Pester -Force -SkipPublisherCheck"
```

#### Windows
```powershell
# PowerShell Core is recommended but Windows PowerShell 5.1 should also work
# Install Pester
Install-Module -Name Pester -Force -SkipPublisherCheck
```

## Running Tests

### From the tests directory
```bash
cd tests
pwsh -Command "Invoke-Pester -Output Detailed"
```

### From the repository root
```bash
pwsh -Command "Invoke-Pester ./tests -Output Detailed"
```

### Running specific test files
```bash
pwsh -Command "Invoke-Pester ./tests/rgg.Tests.ps1 -Output Detailed"
```

## Notes

- Tests assume that PowerShell scripts from the repository are in the `PATH`
- To add the scripts to PATH before running tests:
  ```bash
  export PATH="$(pwd):$PATH"
  pwsh -Command "Invoke-Pester ./tests -Output Detailed"
  ```
- The tests use local fixture data in `tests/rgg-data/`

## Future Support

Might add python / nodejs / etc. support later.
