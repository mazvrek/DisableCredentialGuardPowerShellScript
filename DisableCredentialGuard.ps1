function Ensure-RunAsAdmin {

    $isAdmin = ([Security.Principal.WindowsPrincipal] `
        [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if ($isAdmin) {
        return
    }
    try {
        Start-Process powershell `
            -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
            -Verb RunAs `
            -ErrorAction Stop
    }
    catch {
        Write-Host "Script was not launch as an Administrator." -ForegroundColor Red
        Write-Host "The UAC window was cancelled or provided user has insufficient privileges" -ForegroundColor Yellow
        Pause
        exit 1
    }
    exit
}

Ensure-RunAsAdmin

Write-Host "Disable Credential Guard Script`nThis script will restart computer, press Enter to continue..." -ForegroundColor Yellow
Pause

reg export "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" "C:\Temp\LSA_Backup.reg" /y

if (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name 'LsaCfgFlagsDefault' -ErrorAction SilentlyContinue) {
    Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name 'LsaCfgFlagsDefault' -ErrorAction SilentlyContinue
    Write-Host "`nLsaCfgFlagsDefault key was deleted." -ForegroundColor Green
}

if (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name 'LsaCfgFlags' -ErrorAction SilentlyContinue) {
    Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name 'LsaCfgFlags' -ErrorAction SilentlyContinue
    Write-Host "`nLsaCfgFlags key was deleted." -ForegroundColor Green
}

New-ItemProperty `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" `
    -Name 'LsaCfgFlags' `
    -Value 0 `
    -PropertyType DWord `
    -Force

Write-Host "`nNew LsaCfgFlags key was created." -ForegroundColor Green

$scriptPath = $MyInvocation.MyCommand.Path
$command = "powershell -NoProfile -WindowStyle Hidden -Command `"Remove-Item -Path '$scriptPath' -Force`""

New-ItemProperty `
    -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" `
    -Name "DeleteThisScript" `
    -Value $command `
    -PropertyType String `
    -Force

Write-Host "`nAutomaticScriptCleanup key was created." -ForegroundColor Green

Write-Host "`nComputer will restart in 10 seconds..."
Start-Sleep -Seconds 10

Restart-Computer -Force
