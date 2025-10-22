# 🛠️ Troubleshooting Guide

This document covers common errors and solutions when running the scripts in this repository.  
It will be updated as new issues are discovered.

---

### 1) Module not found

**Error**
```
Import-Module : The specified module 'PSWindowsUpdate' was not loaded...

```

**Fix**
```powershell
# Run PowerShell as Administrator
Install-Module -Name PSWindowsUpdate -Force -Scope AllUsers
Import-Module PSWindowsUpdate
```
> If you are prompted about an untrusted repository, choose **Y** to continue.

---

### 2) Running scripts is disabled (Execution Policy)

**Error**
```
... cannot be loaded because running scripts is disabled on this system.
See about_Execution_Policies ...
```

**Fix**
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
Import-Module PSWindowsUpdate
```

---

### 3) NuGet provider / PSGallery trust prompts

**Error**
- “NuGet provider is required to continue…”
- “Untrusted repository: PSGallery”

**Fix**
```powershell
Install-PackageProvider -Name NuGet -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module PSWindowsUpdate -Force
```

---
