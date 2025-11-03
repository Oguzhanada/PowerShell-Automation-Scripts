# ⚡ PowerShell Automation Scripts  

This repository contains simple PowerShell scripts I wrote to make daily IT support and system maintenance tasks easier.  
👉 It is also one of the first steps in my **Back to Tech Challenge** journey, where I rebuild my hands-on skills and share my progress.

---

## 🎯 Purpose
- Speed up daily system checks  
- Automate repetitive or manual tasks  
- Improve troubleshooting and documentation habits  
- Share what I learn while preparing for IT Support and Security roles  

---

## 📂 Contents

| Script | Description |
|--------|--------------|
| `scripts/System-Health-Check.ps1` | Check CPU, memory, and disk usage with alerts and logging|
| `scripts/Windows-Update-Check.ps1` | Check pending Windows updates and show patch status |
| `scripts/Log-Cleanup.ps1` | Clean up old log or text files and generate a cleanup report |
| `scripts/Network-Diagnose.ps1` | Test network connectivity, DNS, and adapter status |


---

## 🔧 Usage

Open PowerShell **as Administrator** and run the scripts from the project folder.

### System Health Check
```powershell
# Run with default thresholds (CPU 80%, RAM 85%, Disk free 5GB)
.\scripts\System-Health-Check.ps1

# Custom thresholds
.\scripts\System-Health-Check.ps1 -CpuThreshold 70 -MemThreshold 80 -DiskFreeThresholdGB 10

# Custom log file path
.\scripts\System-Health-Check.ps1 -LogPath "C:\Temp\healthcheck.log"
```

### Log Cleanup
```powershell
# Test mode (no deletion)
.\scripts\Log-Cleanup.ps1 -Paths "C:\Logs","C:\Temp" -DaysOld 20 -WhatIf

# Real cleanup
.\scripts\Log-Cleanup.ps1 -Paths "C:\Logs","C:\Temp" -DaysOld 30
```
- Generates a report file like `LogCleanup_Report_20251022_2000.txt`
- Use `-WhatIf` first to confirm what will be deleted



### Network Diagnose
```powershell
# Save report to file
.\scripts\Network-Diagnose.ps1 -ReportPath "C:\Temp\netdiag_report.txt

# Custom targets and DNS names
.\scripts\Network-Diagnose.ps1 -Targets "8.8.8.8","8.8.4.4" -DnsNames "www.microsoft.com","www.github.com"

```
- Works with PowerShell 7+
- Runs safe, read-only connectivity checks (no configuration changes)
- Tests adapter, gateway, DNS resolution, and ping reachability.
- Displays live results and can generate a full text report when -ReportPath is specified.

---


## ⚙️ Requirements
- Windows 10/11 or Windows Server 2016+  
- PowerShell 5.1+ or PowerShell 7+  
- Admin rights for protected system folders  

---


## 🗺️ Roadmap (Coming Soon)
- `scripts/AD-User-Assist.ps1` → quick user management commands (reset, unlock, group check)  
- `scripts/Update-Remediation.ps1` → WSUS cleanup and Windows Update cache reset  
- `scripts/EventLog-Export.ps1` → export recent error and warning logs to CSV   

---

## 📘 Example Config File (for Log-Cleanup v2)
`configs/cleanup-config.json`
```json
{
  "DaysOld": 14,
  "Paths": [
    "C:\Logs",
    "C:\Temp",
    "C:\Windows\Temp"
  ]
}
```
*(Log-Cleanup v2 will read this file automatically to manage different folders.)*

---

## 🧰 Project Structure
```text
PowerShell-Automation/
├─ scripts/
│  ├─ System-Health-Check.ps1
│  ├─ Windows-Update-Check.ps1
│  ├─ Log-Cleanup.ps1
│  └─ Network-Diagnose.ps1
├─ configs/
│  └─ cleanup-config.json
├─ docs/
│  └─ TROUBLESHOOTING.md
└─ .github/
   └─ workflows/
      └─ pssa.yml
```

---
## 🧩 Troubleshooting
For common script errors and fixes, see [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md).

Typical issues:
- Missing PowerShell modules → install via `Install-Module -Name PSWindowsUpdate`
- Execution Policy → run `Set-ExecutionPolicy RemoteSigned`
- Permission errors → start PowerShell as Administrator  

---

## 🤝 Contributing
This is a learning and personal development project.  
Pull requests and suggestions are always welcome — please keep scripts safe, tested, and well-documented.

---

## 📜 License
This project is licensed under the **MIT License**.  
You are free to use and modify the scripts with proper credit.

---

## 💡 Notes
These scripts are part of my ongoing learning plan for IT Support, System Administration, and Security Operations.  
They help me stay close to technology while preparing for professional roles in Ireland’s tech industry.

---
