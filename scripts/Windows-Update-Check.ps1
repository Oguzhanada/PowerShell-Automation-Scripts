# Windows-Update-Check.ps1
# Part of Back to Tech Challenge
# Checks for available Windows updates

Write-Host "=== Windows Update Check ==="

# Import the Windows Update module
try {
    Import-Module PSWindowsUpdate -ErrorAction Stop
}
catch {
    Write-Host "PSWindowsUpdate module not found. Installing..." -ForegroundColor Yellow
    Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser
    Import-Module PSWindowsUpdate
}

# Get list of available updates
$updates = Get-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot

if ($updates) {
    Write-Host "Pending updates found:" -ForegroundColor Yellow
    $updates | Format-Table KB, Size, Title
}
else {
    Write-Host "No pending updates. System is up to date." -ForegroundColor Green
}

Write-Host "=== Check Completed ==="
