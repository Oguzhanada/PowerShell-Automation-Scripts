# PowerShell Automation Scripts ⚡

This repo contains simple PowerShell scripts I wrote to make daily tasks easier.  
👉 It is also one of the first steps in my **Back to Tech Challenge** journey.  

## 🎯 Purpose
- Speed up daily system checks  
- Automate repetitive tasks  
- Share what I learn along the way  

---

## 📂 Contents
- `scripts/System-Health-Check.ps1` → Check CPU, memory, and disk usage with alerts and logging  
- `scripts/Windows-Update-Check.ps1` → Check pending Windows updates  
- `scripts/Log-Cleanup.ps1` → (coming soon) clean up old log files in given folders  

---

## 🔧 Usage

Open PowerShell as Administrator and run the script:  

```powershell
# Run with default thresholds: CPU 80%, RAM 85%, Disk free space 5GB
.\scripts\System-Health-Check.ps1

# Custom thresholds
.\scripts\System-Health-Check.ps1 -CpuThreshold 70 -MemThreshold 80 -DiskFreeThresholdGB 10

# Custom log file path
.\scripts\System-Health-Check.ps1 -LogPath "C:\Temp\healthcheck.log"


```markdown
For common errors and fixes, see [TROUBLESHOOTING.md](./TROUBLESHOOTING.md).
