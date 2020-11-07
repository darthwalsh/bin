<#
.SYNOPSIS
Outputs i.e. master or main
#>

(git symbolic-ref refs/remotes/origin/HEAD) -replace 'refs/remotes/origin/',''
