# PowerShell Automation Scripts

A small collection of PowerShell scripts for everyday Windows IT support and system maintenance: health checks, update checks, log cleanup, and network diagnostics.

## Scripts

All scripts live in the `scripts/` folder.

| Script | What it does |
|--------|--------------|
| `System-Health-Check.ps1` | Reports current CPU, memory, and per-drive disk usage. Prints a red alert, sounds a console beep, and appends to a log file when a value crosses its threshold. Thresholds and the log path are parameters. |
| `Windows-Update-Check.ps1` | Lists pending Windows updates using the PSWindowsUpdate module. If the module is missing, it installs it first, then shows the patches or reports that the system is up to date. |
| `Log-Cleanup.ps1` | Deletes `.log` and `.txt` files older than a set number of days in the folders you pass in, then writes a timestamped report of what it did. A `-WhatIf` switch lets you preview the list without deleting. |
| `Network-Diagnose.ps1` | Runs read-only network checks: active adapter and IP, default gateway reachability, DNS resolution, ping tests, and basic adapter health. Can save a text report when `-ReportPath` is given. No configuration is changed. |

## Requirements

- Windows 10/11 or Windows Server 2016 or newer
- PowerShell 5.1 or newer for most scripts
- PowerShell 7 or newer for `Network-Diagnose.ps1` (it uses syntax that needs PowerShell 7)
- Administrator rights for protected system folders and for some update operations

## How to use

Open PowerShell, ideally as Administrator, and run a script from the project folder.

```powershell
# Health check with default thresholds (CPU 80%, memory 85%, disk free 5 GB)
.\scripts\System-Health-Check.ps1

# Health check with custom thresholds and log path
.\scripts\System-Health-Check.ps1 -CpuThreshold 70 -MemThreshold 80 -DiskFreeThresholdGB 10 -LogPath "C:\Temp\healthcheck.log"

# Preview a log cleanup without deleting anything
.\scripts\Log-Cleanup.ps1 -Paths "C:\Logs","C:\Temp" -DaysOld 30 -WhatIf

# Run the cleanup for real
.\scripts\Log-Cleanup.ps1 -Paths "C:\Logs","C:\Temp" -DaysOld 30

# List pending Windows updates
.\scripts\Windows-Update-Check.ps1

# Network diagnostics with a saved report
.\scripts\Network-Diagnose.ps1 -ReportPath "C:\Temp\netdiag_report.txt"

# Network diagnostics with custom ping targets and DNS names
.\scripts\Network-Diagnose.ps1 -Targets "8.8.8.8","8.8.4.4" -DnsNames "www.microsoft.com","www.github.com"
```

If running scripts is blocked by execution policy, allow them for your user:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Config file

`confings/cleanup-config.json` holds a sample cleanup configuration (a `DaysOld` value and a list of `Paths`). It is included as a reference for a future version. The current `Log-Cleanup.ps1` does not read this file yet, so for now pass `-Paths` and `-DaysOld` on the command line.

## Project structure

```text
PowerShell-Automation-Scripts/
├─ scripts/
│  ├─ System-Health-Check.ps1
│  ├─ Windows-Update-Check.ps1
│  ├─ Log-Cleanup.ps1
│  └─ Network-Diagnose.ps1
├─ confings/
│  └─ cleanup-config.json
├─ docs/
│  └─ Troubleshooting.md
└─ .github/
   └─ workflows/
      └─ pssa.yml
```

## Continuous integration

A GitHub Actions workflow (`.github/workflows/pssa.yml`) runs PSScriptAnalyzer over the `scripts/` folder on every push and pull request that touches a `.ps1` file.

## Troubleshooting

Common errors and fixes (module not found, execution policy, PSGallery trust prompts) are documented in [docs/Troubleshooting.md](docs/Troubleshooting.md).

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
