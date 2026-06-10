# ---------------------------------------------------------------
# parallelPinger.ps1
# Pings all hostnames in computers.txt and logs results to
# .\logs\pinger\pinger_<timestamp>.txt
# ---------------------------------------------------------------

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$hostFile  = Join-Path $scriptDir "computers.txt"
$logsDir   = Join-Path $scriptDir "logs\pinger"
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$logFile   = Join-Path $logsDir "pinger_$timestamp.txt"

# Ensure logs directory exists
if (-not (Test-Path $logsDir)) {
    New-Item -ItemType Directory -Path $logsDir | Out-Null
}

# Load hostnames
$hostnames = Get-Content $hostFile | Where-Object { $_ -match '\S' -and $_ -notmatch '^\s*#' }

# Ping in parallel
$results = $hostnames | ForEach-Object -Parallel {
    $h = $_.Trim()
    try {
        Test-Connection -ComputerName $h -Count 1 -ErrorAction Stop | Out-Null
        $status = "ONLINE"
    } catch {
        $status = "OFFLINE"
    }
    [PSCustomObject]@{ Hostname = $h; Status = $status }
} -ThrottleLimit 50

# Output and collect log lines
$lines = @()
$lines += "Ping Check - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$lines += "-------------------------------"

foreach ($r in $results) {
    $line = "$($r.Hostname) - $($r.Status)"
    $lines += $line
    Write-Host $line -ForegroundColor $(if ($r.Status -eq "ONLINE") { "Green" } else { "Red" })
}

$lines += "-------------------------------"
$lines | Out-File -FilePath $logFile -Encoding UTF8

Write-Host "`nLog saved to: $logFile"
