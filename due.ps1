<#
.SYNOPSIS
Lists tasks that are due soon from Obsidian vault
.DESCRIPTION
Queries Obsidian tasks, mirroring the logic of ~/notes/MyNotes/inbox/Tasks.Daily.md

MAYBE include the subsection like Obsidian Tasks, but that is not returned by @jfim/obsidian-tasks-mcp query_tasks today

TODO file feature requests or look for workarounds for Programmatic filtering below
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

throw "BLOCKED BY: tasks in ~/notes/MyNotes/inbox/*.md are not found. (Related to symlinks?)"

<#
Original query criteria (not all supported by Obsidian Tasks query syntax):
path does not include "OneDrive/"
has due date
not done
due on or before 5 days from now
(starts on or before today OR due on or before tomorrow)
sort by due date
group by due date
#>

$vaultPath = gi ~/notes | fn
$today = ymd

# Supported query filters (AND logic between lines)
$query = @"
not done
has due date
path does not include OneDrive
due before $(ymd -Days +5)
"@

$params = @{
    query = $query
} | ConvertTo-Json -Compress

$jsonResult = mcptools call query_tasks `
    --params $params `
    --format json `
    npx -y @jfim/obsidian-tasks-mcp $vaultPath

# Parse JSON response - MCP returns content array with text
$responseObj = $jsonResult | ConvertFrom-Json
if ($responseObj.PSObject.Properties.Name -contains "isError" -and $responseObj.isError) {
    throw $responseObj.content[0].text
}

# Extract tasks from response (content[0].text contains the JSON array)
$tasksJson = $responseObj.content[0].text

$tasks = $tasksJson | ConvertFrom-Json

# Programmatic filtering:
# 1. Exclude cancelled tasks (query syntax "not done" includes cancelled)
# 2. Apply OR condition: https://github.com/jfim/obsidian-tasks-mcp/pull/7
$filteredTasks = $tasks | Where-Object {
    $task = $_
    $task.status -eq "incomplete" -and
    $task.dueDate -and
    (
        ($task.PSObject.Properties.Name -contains "startDate" -and $task.startDate -le $today) -or
        ($task.dueDate -le (ymd -Days +1))
    )
}

$sortedTasks = $filteredTasks | Sort-Object -Property dueDate
foreach ($task in $sortedTasks) {
    $dueDateObj = [DateTime]$task.dueDate
    $dayOfWeek = $dueDateObj.ToString("ddd").ToUpper()
    
    $daysUntilDue = ($dueDateObj - (Get-Date)).Days
    # Today is 1.5 (orange), getting greener in the future
    $metric = 1.5 - ($daysUntilDue * 0.25)
    $coloredDate = metric-ansi "$dayOfWeek $($task.dueDate)" $metric
    
    # MAYBE this could use OSC8 escape sequences to shorten the path, making it clickable in the terminal? See quotation.ps1 too 
    $relativePath = $task.filePath -replace [regex]::Escape($vaultPath), "~/notes"
    
    # MAYBE is +1 a bug? lineNumber is off by one, should be $task.lineNumber but using +1 as workaround
    $lineNumber = $task.lineNumber + 1
    
    "$coloredDate $($task.description) $relativePath`:$lineNumber"
}
