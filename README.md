# 🛡️ Credential Guard Disable Script

This PowerShell script disables **Credential Guard** on Windows systems by modifying LSA registry settings.
It enforces Administrator privileges, creates a registry backup, updates required registry values,
schedules automatic self-deletion, and restarts the computer.

---

## ⚡ Features

- 🔐 Enforces Administrator privileges
- 📦 Creates a backup of the LSA registry key
- 🧹 Removes existing LSA registry values if present
- 📝 Creates a new `LsaCfgFlags` registry value set to `0`
- 🗑️ Automatically removes the script after reboot
- 🔄 Restarts the computer automatically

---

## 🛠️ How It Works

### 1️⃣ Administrator Privilege Check

The script checks whether it is running with Administrator privileges:

```powershell
$isAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
```

If not elevated, the script relaunches itself with Administrator rights:

```powershell
Start-Process powershell `
    -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
    -Verb RunAs
```

If the UAC prompt is cancelled, the script exits safely.

---

### 2️⃣ User Confirmation

A warning message is displayed:

```powershell
Write-Host "Disable Credential Guard Script`nThis script will restart computer, press Enter to continue..."
```

The script waits for user input:

```powershell
Pause
```

---

### 3️⃣ LSA Registry Backup

The script creates a backup of the LSA registry key:

```powershell
reg export "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" "C:\Temp\LSA_Backup.reg" /y
```

📁 Backup location:
C:\Temp\LSA_Backup.reg

---

### 4️⃣ Removal of Existing Registry Values

If present, the following values are removed:

```powershell
Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name 'LsaCfgFlagsDefault'
Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name 'LsaCfgFlags'
```

---

### 5️⃣ Create New Registry Value

A new registry value is created to disable Credential Guard:

```powershell
New-ItemProperty `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" `
    -Name 'LsaCfgFlags' `
    -Value 0 `
    -PropertyType DWord `
    -Force
```

---

### 6️⃣ Automatic Script Cleanup

The script schedules its own deletion after reboot:

```powershell
$scriptPath = $MyInvocation.MyCommand.Path
$command = "powershell -NoProfile -WindowStyle Hidden -Command `"Remove-Item -Path '$scriptPath' -Force`""

New-ItemProperty `
    -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" `
    -Name "DeleteThisScript" `
    -Value $command `
    -PropertyType String `
    -Force
```

🗑️ The script will be deleted automatically after the system restarts.

---

### 7️⃣ System Restart

The script waits 10 seconds:

```powershell
Start-Sleep -Seconds 10
```

Then forces a restart:

```powershell
Restart-Computer -Force
```

---

## ▶️ Usage

1. 📂 Double-click the PowerShell script file.
2. 🔐 Accept the UAC prompt.
3. ⏎ Press Enter when prompted.
4. 🔄 The computer will restart automatically.

---

## 📦 Files & Registry Changes

- 📁 C:\Temp\LSA_Backup.reg
  Backup of the LSA registry key
  
- 🗂️ HKLM\SYSTEM\CurrentControlSet\Control\Lsa
  Modified Credential Guard configuration

- 🗂️ HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce
  Temporary entry for script self-deletion

---

## ⚠️ Important Notes

- ❗ Restart is forced and will close all running applications

---

## 👨‍💻 Author

Kamil (mazvrek) – Junior IT Support Engineer  
LinkedIn: https://www.linkedin.com/in/mazvrek/  
GitHub: https://github.com/MAZVREK 
