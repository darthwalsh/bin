<#
.SYNOPSIS
Gets all current AWS lambdas and URLs
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$table = @{}
foreach ($name in aws lambda list-functions | jq '.Functions[] | .FunctionName' -r) {
    $url = aws lambda get-function-url-config --function-name $name | jq '.FunctionUrl' -r
    if ($url) {
        $table[$name] = $url
    } else {
        write-host "$name has No URL" -ForegroundColor gray
    }
    
}
$table.GetEnumerator() | Sort-Object -property:Key | Format-Table -AutoSize
