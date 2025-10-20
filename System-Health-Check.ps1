# System-Health-Check.ps1
# First Part of Back to Tech Challenge
# Checks CPU, Memory and Disk usage and raises simple alerts.

param(
    [int]$CpuThreshold = 50,                    # % CPU (>= alert)
    [int]$MemThreshold = 60,                    # % Memory used (>= alert)
    [int]$DiskFreeThresholdGB = 10,              # Per drive: free space in GB (<= alert)
    [string]$LogPath = ".\healthcheck.log"      # Simple log file
)

function Write-Alert {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Red
    try { [console]::beep(1000, 350) } catch { }  # may not work in all terminals
    Add-Content -Path $LogPath -Value ("{0} {1}" -f (Get-Date -Format s), $Message)
}

function Get-CpuUsage {
    (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
}

function Get-MemoryInfo {
    $os = Get-CimInstance Win32_OperatingSystem
    $totalMB = [double]($os.TotalVisibleMemorySize/1KB) # KB -> MB
    $freeMB  = [double]($os.FreePhysicalMemory/1KB)
    $usedMB  = $totalMB - $freeMB
    $pctUsed = if ($totalMB -gt 0) { ($usedMB / $totalMB) * 100 } else { 0 }
    [pscustomobject]@{
        TotalMB = [math]::Round($totalMB,2)
        UsedMB  = [math]::Round($usedMB,2)
        FreeMB  = [math]::Round($freeMB,2)
        PctUsed = [math]::Round($pctUsed,2)
    }
}

function Get-DiskInfo {
    Get-PSDrive -PSProvider FileSystem | ForEach-Object {
        $usedGB = [math]::Round(($_.Used/1GB),2)
        $freeGB = [math]::Round(($_.Free/1GB),2)
        $totalGB = $usedGB + $freeGB
        [pscustomobject]@{
            Name    = $_.Name
            UsedGB  = $usedGB
            FreeGB  = $freeGB
            TotalGB = $totalGB
        }
    }
}

Write-Host "=== System Health Check ==="

# CPU
$cpu = [math]::Round((Get-CpuUsage), 2)
Write-Host "CPU Usage: $cpu%"
if ($cpu -ge $CpuThreshold) {
    Write-Alert "ALERT: CPU usage high: $cpu% (threshold $CpuThreshold%)"
}

# Memory
$mem = Get-MemoryInfo
Write-Host ("Memory Usage: {0} MB used / {1} MB total ({2}% used)" -f $mem.UsedMB, $mem.TotalMB, $mem.PctUsed)
if ($mem.PctUsed -ge $MemThreshold) {
    Write-Alert ("ALERT: Memory usage high: {0}% (threshold {1}%)" -f $mem.PctUsed, $MemThreshold)
}

# Disks
$disks = Get-DiskInfo
foreach ($d in $disks) {
    Write-Host ("Drive {0}: {1} GB used / {2} GB free / {3} GB total" -f $d.Name, $d.UsedGB, $d.FreeGB, $d.TotalGB)
    if ($d.FreeGB -le $DiskFreeThresholdGB) {
        Write-Alert ("ALERT: Low free space on drive {0}: {1} GB free (threshold {2} GB)" -f $d.Name, $d.FreeGB, $DiskFreeThresholdGB)
    }
}

Write-Host "=== Check Completed ==="
