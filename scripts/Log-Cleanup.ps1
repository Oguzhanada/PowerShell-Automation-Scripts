

param(
  [Parameter(Mandatory=$true)]
  [string[]]$Paths,                # Folders to check
  [int]$DaysOld = 7,               # Files older than X days will be removed
  [switch]$WhatIf                 # Optional safety flag
)

$DateLimit = (Get-Date).AddDays(-$DaysOld)
$LogFile = "C:\Users\LogCleanup_Report_{0:yyyyMMdd_HHmmss}.txt" -f (Get-Date)
$DeletedCount = 0
$lines = @()

$lines += "Log Cleanup started: $(Get-Date)"
$lines += "Folders checked: $($Paths -join ', ')"
$lines += "Removing files older than $DaysOld days"
$lines += ""

foreach ($Path in $Paths) {
    if (Test-Path $Path) {
        $OldFiles = Get-ChildItem -Path $Path -Recurse -Include *.log, *.txt `
                    | Where-Object { $_.LastWriteTime -lt $DateLimit }
        foreach ($File in $OldFiles) {
            $lines += "Deleting: $($File.FullName)"
            if (-not $WhatIf) {
                Remove-Item $File.FullName -Force -ErrorAction SilentlyContinue
            }
            $DeletedCount++
        }
    } else {
        $lines += "Path not found: $Path"
    }
}

$lines += ""
$lines += "Total deleted: $DeletedCount"
$lines += "Completed: $(Get-Date)"
$lines | Out-File -FilePath $LogFile -Encoding UTF8

Write-Host "Cleanup done. Report saved as $LogFile"
