<#
.SYNOPSIS
Prints the URL for default branch protection settings in a GitHub repository
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$id = gh api graphql -F owner='{owner}' -F name='{repo}' -f query='
  query($name: String!, $owner: String!) {
    repository(owner: $owner, name: $name) {
      defaultBranchRef {
        name
        branchProtectionRule {
          pattern
          databaseId
        }
      }
    }
  }
' --jq .data.repository.defaultBranchRef.branchProtectionRule.databaseId

$url = gh repo view --json url --jq '.url'
"$url/settings/branch_protection_rules/$id"
