<# 
.SYNOPSIS
  Quick network diagnostics: adapter state, IP/DNS, gateway reachability, DNS resolution and ping tests.

.DESCRIPTION
  Designed for IT support use. Runs safe read-only checks by default and writes a concise report to screen.
  Optionally, a report can be saved to a log file with -ReportPath.

.PARAMETER Targets
  Hostnames or IPs to test reachability (default: 8.8.8.8, 1.1.1.1, www.microsoft.com).

.PARAMETER DnsNames
  Hostnames to test DNS resolution (default: www.microsoft.com, www.github.com).

.PARAMETER ReportPath
  Write a text report to the given path. If the directory doesn’t exist, it will be created.

.PARAMETER AdapterName
  Filter to a specific network adapter (friendly name). If not provided, active up adapters are inspected.

.PARAMETER TimeoutMs
  Timeout in milliseconds for Test-Connection pings (default: 1000).

.EXAMPLE
  .\scripts\Network-Diagnose.ps1

.EXAMPLE
  .\scripts\Network-Diagnose.ps1 -Targets "8.8.8.8","www.qualcomm.com" -ReportPath "C:\Temp\netdiag.txt"

.EXAMPLE
  .\scripts\Network-Diagnose.ps1 -AdapterName "Wi-Fi" -Verbose
#>

[CmdletBinding()]
param(
    [string[]]$Targets   = @("8.8.8.8","1.1.1.1","www.microsoft.com"),
    [string[]]$DnsNames  = @("www.microsoft.com","www.github.com"),
    [string]  $ReportPath,
    [string]  $AdapterName,
    [int]     $TimeoutMs = 1000
)

function Write-Section {
    param([string]$Title)
    Write-Output ("`n=== {0} ===" -f $Title)
}

function Add-ReportLine {
    param([string]$Line)
    $script:Report += ($Line + [Environment]::NewLine)
}

function Save-ReportIfRequested {
    if ([string]::IsNullOrWhiteSpace($ReportPath)) { return }
    try {
        $folder = Split-Path -Path $ReportPath -Parent
        if (-not (Test-Path $folder)) { New-Item -ItemType Directory -Path $folder | Out-Null }
        $script:Report | Out-File -FilePath $ReportPath -Encoding UTF8
        Write-Output ("[Saved] Report → {0}" -f $ReportPath)
    } catch {
        Write-Warning ("Could not save report: {0}" -f $_.Exception.Message)
    }
}

# Collect summary in-memory
$script:Report = ""

# 1) Adapter & IP basics
Write-Section "Adapter & IP Information"
try {
    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and $_.HardwareInterface -eq $true }
    if ($AdapterName) {
        $adapters = $adapters | Where-Object { $_.Name -like $AdapterName -or $_.InterfaceDescription -like $AdapterName }
    }
    if (-not $adapters) {
        Write-Warning "No active (Up) adapter found. Check airplane mode, cable, or driver status."
        Add-ReportLine "Adapters: none (Up)"
    } else {
        foreach ($ad in $adapters) {
            $ip = Get-NetIPAddress -InterfaceIndex $ad.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue
            $dns = Get-DnsClientServerAddress -InterfaceIndex $ad.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue
            $line = "{0} | IPv4: {1} | DNS: {2}" -f $ad.Name,
                ($ip | Where-Object {$_.IPAddress} | Select-Object -ExpandProperty IPAddress -ErrorAction SilentlyContinue -First 1),
                (($dns.ServerAddresses -join ", "))
            Write-Output $line
            Add-ReportLine $line
        }
    }
} catch {
    Write-Warning ("Adapter query error: {0}" -f $_.Exception.Message)
}

# 2) Default gateway reachability
Write-Section "Default Gateway"
try {
    $gws = Get-NetRoute -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue | Sort-Object -Property RouteMetric
    if (-not $gws) {
        Write-Warning "No default gateway found."
        Add-ReportLine "Gateway: not found"
    } else {
        $gw = $gws[0].NextHop
        $ok = Test-Connection -ComputerName $gw -Count 1 -Quiet -TimeoutMilliseconds $TimeoutMs
        $msg = "Gateway {0} reachable: {1}" -f $gw, ($ok)
        Write-Output $msg
        Add-ReportLine $msg
    }
} catch {
    Write-Warning ("Gateway test error: {0}" -f $_.Exception.Message)
}

# 3) DNS resolution checks
Write-Section "DNS Resolution"
foreach ($name in $DnsNames) {
    try {
        $res = Resolve-DnsName -Name $name -ErrorAction Stop
        $ips = ($res | Where-Object {$_.IPAddress} | Select-Object -ExpandProperty IPAddress) -join ", "
        $msg = "{0} → {1}" -f $name, ($ips -ne "" ? $ips : "resolved (no A record shown)")
        Write-Output $msg
        Add-ReportLine $msg
    } catch {
        $msg = "{0} → resolution FAILED: {1}" -f $name, $_.Exception.Message
        Write-Warning $msg
        Add-ReportLine $msg
    }
}

# 4) Ping tests (targets)
Write-Section "Ping Tests"
foreach ($t in $Targets) {
    try {
        $ok = Test-Connection -ComputerName $t -Count 1 -Quiet -TimeoutMilliseconds $TimeoutMs
        $msg = "{0} reachable: {1}" -f $t, $ok
        Write-Output $msg
        Add-ReportLine $msg
    } catch {
        $msg = "{0} → test FAILED: {1}" -f $t, $_.Exception.Message
        Write-Warning $msg
        Add-ReportLine $msg
    }
}

# 5) Quick adapter health (optional extra signal)
Write-Section "Adapter Health Signals"
try {
    $wmi = Get-WmiObject -Class Win32_NetworkAdapter -ErrorAction SilentlyContinue | Where-Object { $_.NetEnabled -eq $true }
    if ($AdapterName) {
        $wmi = $wmi | Where-Object { $_.Name -like $AdapterName }
    }
    foreach ($a in $wmi) {
        $msg = "{0} | Speed: {1} | MAC: {2}" -f $a.Name, $a.Speed, $a.MACAddress
        Write-Output $msg
        Add-ReportLine $msg
    }
} catch {
    Write-Warning ("Adapter health query error: {0}" -f $_.Exception.Message)
}

# Save report if asked
Save-ReportIfRequested

