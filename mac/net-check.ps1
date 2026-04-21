<#
.SYNOPSIS
Ping-tests all active network interfaces in parallel with live feedback #ai-slop
.DESCRIPTION
Discovers interfaces with assigned IPs, binds ping to each source IP via -S,
and reports pass/flaky/fail per interface. Works with VPN (utun) interfaces.

MAYBE in the future transform the output like this

    [09:37:27] Wi-Fi                     ping #1     6.6 ms
    [09:37:27] USB 10/100/1000 LAN       ping #1     2.0 ms
    [09:37:27] utun4 (VPN)               ping #1    80.5 ms

to columns:

    Turn | GATEWAY Wifi | Ethernet | VPN           | Google Wifi | Ethernet | VPN |
         | 192.168.1.1 | 192.168.1.1 | 10.183.31.84 | 8.8.8.8 | 8.8.8.8 | 8.8.8.8
09:37:27 | 6 | 2 | 80 | 18 | 12 | 83

Or, maybe a more-TUI like display:

                    09:37:27 :28
    Wi-Fi                 🟢  🟢
    USB 10/100/1000 LAN   🔴  🔴
    utun4 (VPN)           🟡  🟢
<WIPE-SCREEN-THEN-RERENDER>
                    09:37:27 :28 :29
    Wi-Fi                 🟢  🟢  🟢
    USB 10/100/1000 LAN   🔴  🔴  🔴
    utun4 (VPN)           🟡  🟢  🟢

And adding a second connectivity check for google dns?

MAYBE stop early once it's healthy for a bit?

TODOmmrewrite this for windows/linux connectivity?ve to mac/ve to mac/ve to mac/ve to mac/ve to mac/ve to mac/ve to mac/ve to mac/ve to mac/ve to mac/
.PARAMETER Count
Number of pings per interface. Default 10.
.PARAMETER Interval
Seconds between pings. Default 1.
.EXAMPLE
PS> net-check
PS> net-check -Count 20 -Interval 2
#>

param(
    [int] $Count = 10,
    [int] $Interval = 1
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# --- Discover active interfaces ---

function Get-HardwarePortNames {
    # Returns hashtable: device name (e.g. "en0") -> human label (e.g. "Wi-Fi")
    $map = @{}
    $raw = networksetup -listallhardwareports
    $currentLabel = $null
    foreach ($line in $raw) {
        if ($line -match '^Hardware Port:\s*(.+)') {
            $currentLabel = $Matches[1].Trim()
        }
        elseif ($line -match '^Device:\s*(\S+)') {
            $map[$Matches[1]] = $currentLabel
        }
    }
    $map
}

function Get-VpnInterfaces {
    # Returns hashtable: utun device name -> VPN peer IP to ping
    # Uses the UGHS host route via the tunnel as the real remote peer.
    # The "default" route gateway is often the tunnel's own IP (unping-able); UGHS is the actual peer.
    $vpnPeers = @{}
    $raw = netstat -rn -f inet
    foreach ($line in $raw) {
        # "10.183.29.1   10.183.31.84   UGHS   utun4"
        # Destination=col1, Gateway=col2. Destination is the reachable VPN peer IP.
        if ($line -match '^(\d+\.\d+\.\d+\.\d+)\s+\d+\.\d+\.\d+\.\d+\s+UGHS\s+(utun\d+)') {
            # Only record the first UGHS route per interface (the primary VPN peer)
            if (-not $vpnPeers.ContainsKey($Matches[2])) {
                $vpnPeers[$Matches[2]] = $Matches[1]
            }
        }
    }
    $vpnPeers
}

function Get-ActiveInterfaces {
    $portNames = Get-HardwarePortNames
    $vpnPeers  = Get-VpnInterfaces

    # Parse `ifconfig` output: group blocks by interface name, extract inet lines
    $raw = ifconfig
    $ifaces = @()
    $currentIface = $null

    foreach ($line in $raw) {
        if ($line -match '^(\S+):') {
            $currentIface = $Matches[1]
        }
        elseif ($line -match '^\s+inet (\d+\.\d+\.\d+\.\d+).*broadcast (\d+\.\d+\.\d+\.\d+)') {
            $label = if ($portNames.ContainsKey($currentIface)) { $portNames[$currentIface] } else { $currentIface }
            $ifaces += [pscustomobject]@{
                Name    = $currentIface
                Label   = $label
                IP      = $Matches[1]
                Gateway = $Matches[2] -replace '\d+$', '1'  # broadcast -> .1 heuristic
                IsVPN   = $false
            }
        }
        elseif ($line -match '^\s+inet (\d+\.\d+\.\d+\.\d+)') {
            # P2P tunnel (utun). Only include if it has a UGHS host route (real VPN peer reachable).
            if (-not $vpnPeers.ContainsKey($currentIface)) { continue }
            $localIP = $Matches[1]
            $label   = if ($portNames.ContainsKey($currentIface)) { $portNames[$currentIface] } else { $currentIface }
            $ifaces += [pscustomobject]@{
                Name    = $currentIface
                Label   = "$label (VPN)"
                IP      = $localIP
                Gateway = $vpnPeers[$currentIface]  # ping the VPN peer via UGHS host route
                IsVPN   = $true
            }
        }
    }

    # Skip loopback
    $ifaces | Where-Object { $_.IP -ne '127.0.0.1' }
}

$ifaces = Get-ActiveInterfaces

if ($ifaces.Count -eq 0) {
    Write-Error "No active non-loopback interfaces found."
    exit 1
}

Write-Host ""
Write-Host "Network interfaces found:" -ForegroundColor Cyan
foreach ($iface in $ifaces) {
    $typeLabel = if ($iface.IsVPN) { "VPN    " } else { "LAN    " }
    Write-Host "  [$typeLabel] $($iface.Name): $($iface.IP)  $($iface.Label)  target=$($iface.Gateway)"
}
Write-Host ""
Write-Host "Sending $Count pings ($Interval s interval) per interface..." -ForegroundColor Cyan
Write-Host ""

# --- Spawn one job per interface ---

$jobs = @()
foreach ($iface in $ifaces) {
    $pingTarget = $iface.Gateway
    $srcIP      = $iface.IP
    $ifaceName  = $iface.Name

    $ifaceLabel = $iface.Label

    $job = Start-Job -Name $ifaceName -ScriptBlock {
        param($srcIP, $pingTarget, $count, $interval, $ifaceName, $ifaceLabel)

        $results = @()
        for ($i = 1; $i -le $count; $i++) {
            $ts = Get-Date -Format 'HH:mm:ss'
            $outStr = ""
            try {
                # ping -S binds to source IP (interface); -c 1 single packet; -W 2s timeout
                $out = ping -S $srcIP -c 1 -W 2000 $pingTarget 2>&1
                $outStr = $out -join " "

                if ($outStr -match '(\d+(?:\.\d+)?)\s*ms') {
                    $ms = [double]$Matches[1]
                    $results += "ok"
                    [pscustomobject]@{ iface = $ifaceName; label = $ifaceLabel; seq = $i; status = "ok"; ms = $ms; ts = $ts }
                }
                elseif ($outStr -match 'Request timeout|100\.0% packet loss|No route to host|sendto: No route') {
                    $results += "fail"
                    [pscustomobject]@{ iface = $ifaceName; label = $ifaceLabel; seq = $i; status = "timeout"; ms = $null; ts = $ts }
                }
                else {
                    $results += "fail"
                    [pscustomobject]@{ iface = $ifaceName; label = $ifaceLabel; seq = $i; status = "unknown"; ms = $null; ts = $ts; raw = $outStr }
                }
            }
            catch {
                # ping exits non-zero on packet loss — check the captured output first
                $errStr = $_.ToString()
                if ($outStr -match '(\d+(?:\.\d+)?)\s*ms') {
                    $ms = [double]$Matches[1]
                    $results += "ok"
                    [pscustomobject]@{ iface = $ifaceName; label = $ifaceLabel; seq = $i; status = "ok"; ms = $ms; ts = $ts }
                }
                elseif ($outStr -match '100\.0% packet loss|No route to host|sendto: No route|Request timeout' -or
                        $errStr -match '100\.0% packet loss|No route to host|sendto: No route') {
                    $results += "fail"
                    [pscustomobject]@{ iface = $ifaceName; label = $ifaceLabel; seq = $i; status = "timeout"; ms = $null; ts = $ts }
                }
                else {
                    $results += "fail"
                    [pscustomobject]@{ iface = $ifaceName; label = $ifaceLabel; seq = $i; status = "error"; ms = $null; ts = $ts; raw = $errStr }
                }
            }

            if ($i -lt $count) {
                Start-Sleep -Seconds $interval
            }
        }

        # Return summary as last item
        $ok    = ($results | Where-Object { $_ -eq "ok" }).Count
        $total = $results.Count
        [pscustomobject]@{ iface = $ifaceName; label = $ifaceLabel; seq = -1; ok = $ok; total = $total }

    } -ArgumentList $srcIP, $pingTarget, $Count, $Interval, $ifaceName, $ifaceLabel

    $jobs += $job
}

# --- Live output: poll jobs until all done ---

$done = @{}
$seenLines = @{}

while ($done.Count -lt $jobs.Count) {
    foreach ($job in $jobs) {
        if ($done.ContainsKey($job.Name)) { continue }

        $items = Receive-Job -Job $job -Keep 2>$null
        foreach ($item in $items) {
            $key = "$($item.iface)-$($item.seq)"
            if ($seenLines.ContainsKey($key)) { continue }
            $seenLines[$key] = $true

            if ($item.seq -eq -1) {
                # Summary line — printed after loop
                continue
            }

            $displayName = $item.label.PadRight(24)
            $prefix = "[$($item.ts)] $displayName"
            switch ($item.status) {
                "ok"      {
                    $msStr = ("{0,6:F1}" -f $item.ms) + " ms"
                    Write-Host "$prefix  ping #$($item.seq)  $msStr" -ForegroundColor Green
                }
                "timeout" {
                    Write-Host "$prefix  ping #$($item.seq)  TIMEOUT" -ForegroundColor Yellow
                }
                default   {
                    $extra = if ($item.raw) { "  ($($item.raw))" } else { "" }
                    Write-Host "$prefix  ping #$($item.seq)  $($item.status.ToUpper())$extra" -ForegroundColor Red
                }
            }
        }

        if ($job.State -in 'Completed', 'Failed', 'Stopped') {
            $done[$job.Name] = $true
        }
    }

    if ($done.Count -lt $jobs.Count) {
        Start-Sleep -Milliseconds 300
    }
}

# --- Final summary ---

Write-Host ""
Write-Host "── Summary ──────────────────────────────────" -ForegroundColor Cyan

foreach ($job in $jobs) {
    $items = Receive-Job -Job $job 2>$null
    $summary = $items | Where-Object { $_.seq -eq -1 } | Select-Object -Last 1
    $allPings = $items | Where-Object { $_.seq -ge 1 }

    if (-not $summary) {
        Write-Host "  $($job.Name)  no data" -ForegroundColor DarkGray
        continue
    }

    $ok    = $summary.ok
    $total = $summary.total
    $loss  = [int](($total - $ok) / [Math]::Max($total, 1) * 100)

    $iface = $ifaces | Where-Object { $_.Name -eq $job.Name }
    $label = "$($summary.label.PadRight(24))  src=$($iface.IP)  target=$($iface.Gateway)"

    if ($ok -eq $total) {
        $avgMs = ($allPings | Where-Object { $_.ms } | Measure-Object -Property ms -Average).Average
        $avgStr = if ($avgMs) { " avg $([int]$avgMs) ms" } else { "" }
        Write-Host "  $label  PASS  ($ok/$total ok$avgStr)" -ForegroundColor Green
    }
    elseif ($ok -eq 0) {
        Write-Host "  $label  FAIL  (0/$total — no route or host unreachable)" -ForegroundColor Red
    }
    else {
        Write-Host "  $label  FLAKY  ($ok/$total ok, $loss% loss)" -ForegroundColor Yellow
    }

    Remove-Job -Job $job -Force
}

Write-Host ""
