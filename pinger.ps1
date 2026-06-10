
# ---------------------------------------------------------------
# pinger.ps1
# Pings all hostnames in hostnames.txt and logs results to
# .\logs\pinger_<timestamp>.txt
# ---------------------------------------------------------------
 
$scriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$hostFile   = Join-Path $scriptDir "computers.txt"
$logsDir    = Join-Path $scriptDir "logs\pinger"
$timestamp  = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$logFile    = Join-Path $logsDir "pinger_$timestamp.txt"
 
# Ensure logs directory exists
if (-not (Test-Path $logsDir)) {
    New-Item -ItemType Directory -Path $logsDir | Out-Null
}
 
# Load hostnames
$hostnames = Get-Content $hostFile | Where-Object { $_ -match '\S' -and $_ -notmatch '^\s*#' }
 
$lines = @()
$lines += "Ping Check - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$lines += "-------------------------------"
 
foreach ($h in $hostnames) {
    $h = $h.Trim()
    try {
        Test-Connection -ComputerName $h -Count 1 -ErrorAction Stop | Out-Null
        $status = "ONLINE"
    } catch {
        $status = "OFFLINE"
    }
    $line = "$h - $status"
    $lines += $line
    Write-Host $line -ForegroundColor $(if ($status -eq "ONLINE") { "Green" } else { "Red" })
}
 
$lines += "-------------------------------"
$lines | Out-File -FilePath $logFile -Encoding UTF8
 
Write-Host "`nLog saved to: $logFile"
