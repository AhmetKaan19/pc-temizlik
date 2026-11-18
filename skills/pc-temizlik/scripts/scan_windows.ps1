# pc-temizlik: Windows scan. READ ONLY, changes nothing.
# Usage: powershell -NoProfile -ExecutionPolicy RemoteSigned -File scan_windows.ps1 > tarama.txt
# Works on Windows PowerShell 5.1 and PowerShell 7. Does not need admin rights.
# Text is ASCII on purpose: PowerShell 5.1 misreads UTF-8 files without BOM.

$ErrorActionPreference = 'SilentlyContinue'
$H = $env:USERPROFILE; $LA = $env:LOCALAPPDATA; $RA = $env:APPDATA

function Get-SizeGB([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    $sum = (Get-ChildItem -LiteralPath $Path -Recurse -Force -File -ErrorAction SilentlyContinue |
            Measure-Object -Property Length -Sum).Sum
    return [math]::Round(($sum / 1GB), 2)
}
function Show-Top([string]$Path, [int]$N = 12) {
    if (-not (Test-Path -LiteralPath $Path)) { return }
    Get-ChildItem -LiteralPath $Path -Force -Directory -ErrorAction SilentlyContinue |
        ForEach-Object { [pscustomobject]@{ GB = (Get-SizeGB $_.FullName); Path = $_.FullName } } |
        Where-Object { $_.GB -ge 0.05 } | Sort-Object GB -Descending | Select-Object -First $N |
        ForEach-Object { "{0,7} GB  {1}" -f $_.GB, $_.Path }
}
function Test-Exe([string]$Cmd) {
    # Extract the executable path from a command line and check that it exists.
    if (-not $Cmd) { return $true }
    $c = [Environment]::ExpandEnvironmentVariables($Cmd.Trim())
    if ($c.StartsWith('"')) { $exe = $c.Substring(1, $c.IndexOf('"', 1) - 1) }
    elseif ($c -match '^(.+?\.(exe|bat|cmd|com|ps1|dll))') { $exe = $Matches[1] }
    else { $exe = ($c -split ' ')[0] }
    if ($exe -notmatch '[\\/]') { return $true }   # bare name like rundll32: assume system tool
    return (Test-Path -LiteralPath $exe)
}

"== SUMMARY =="
Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
    "Disk {0}  size {1} GB, free {2} GB, used {3}%" -f $_.DeviceID, [math]::Round($_.Size/1GB),
        [math]::Round($_.FreeSpace/1GB), [math]::Round(100 - 100*$_.FreeSpace/$_.Size)
}
$os = Get-CimInstance Win32_OperatingSystem
"Windows: {0} ({1})" -f $os.Caption, $os.Version
"RAM: {0} GB" -f [math]::Round($os.TotalVisibleMemorySize/1MB)
$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
"Running as admin: $admin"
try { $rb = (New-Object -ComObject Shell.Application).NameSpace(10).Items() | Measure-Object -Property Size -Sum
      "Recycle Bin: {0} GB" -f [math]::Round($rb.Sum/1GB, 2) } catch { "Recycle Bin: could not measure" }

""; "== USER FOLDER (largest) =="; Show-Top $H
""; "== APPDATA LOCAL =="; Show-Top $LA
""; "== APPDATA ROAMING =="; Show-Top $RA
""; "== PERSONAL FILES (group D, report only) =="
foreach ($p in 'Desktop','Documents','Videos','Pictures','Downloads','Music') { Show-Top (Join-Path $H $p) 6 }

""; "== CACHES AND TEMP (group A candidates) =="
$cand = @(
  $env:TEMP, "$LA\Temp", "$LA\CrashDumps", "$LA\D3DSCache",
  "$LA\Google\Chrome\User Data\Default\Cache", "$LA\Google\Chrome\User Data\Default\Code Cache",
  "$LA\Microsoft\Edge\User Data\Default\Cache", "$LA\BraveSoftware\Brave-Browser\User Data\Default\Cache",
  "$RA\discord\Cache", "$RA\Spotify\Data", "$LA\Spotify\Data", "$RA\Code\Cache", "$RA\Code\CachedData",
  "$LA\npm-cache", "$RA\npm-cache", "$LA\pip\Cache", "$LA\uv\cache", "$H\.gradle\caches", "$H\.nuget\packages",
  "$LA\NVIDIA\DXCache", "$LA\AMD\DxCache", "$LA\Steam\htmlcache",
  "C:\Windows\SoftwareDistribution\Download", "C:\Windows\Temp"
)
foreach ($p in $cand) { $g = Get-SizeGB $p; if ($g -ne $null -and $g -ge 0.05) { "{0,7} GB  {1}" -f $g, $p } }

""; "== INSTALLED PROGRAMS (name | GB | install date | publisher | uninstall cmd) =="
$keys = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
Get-ItemProperty $keys | Where-Object { $_.DisplayName -and -not $_.SystemComponent } |
  Sort-Object EstimatedSize -Descending | ForEach-Object {
    "{0} | {1} | {2} | {3} | {4}" -f $_.DisplayName, [math]::Round(($_.EstimatedSize/1MB), 2),
        $_.InstallDate, $_.Publisher, $_.UninstallString
  }
""; "== STORE APPS (non-Microsoft) =="
Get-AppxPackage | Where-Object { $_.Publisher -notmatch 'Microsoft' -and -not $_.IsFramework } |
  ForEach-Object { "{0} | {1}" -f $_.Name, $_.Version }

""; "== LAST USE (Prefetch, needs admin; empty if not admin) =="
Get-ChildItem C:\Windows\Prefetch\*.pf | Sort-Object LastWriteTime |
  Select-Object -First 40 | ForEach-Object { "{0:yyyy-MM-dd} {1}" -f $_.LastWriteTime, $_.BaseName }

""; "== STARTUP ITEMS =="
Get-CimInstance Win32_StartupCommand | ForEach-Object {
    $st = if (Test-Exe $_.Command) { 'OK' } else { 'ORPHAN' }
    "{0} | {1} | {2} | {3}" -f $st, $_.Name, $_.Location, $_.Command
}

""; "== SERVICES (non-Windows) =="
"Status: OK = program exists, ORPHAN = program deleted (group C candidate)"
Get-CimInstance Win32_Service | Where-Object { $_.PathName -and $_.PathName -notmatch '\\Windows\\(system32|SysWOW64|servicing)\\' } |
  ForEach-Object {
    $st = if (Test-Exe $_.PathName) { 'OK' } else { 'ORPHAN' }
    "{0} | {1} | {2} | start={3} | {4}" -f $st, $_.Name, $_.State, $_.StartMode, $_.PathName
  }

""; "== SCHEDULED TASKS (non-Microsoft) =="
Get-ScheduledTask | Where-Object { $_.TaskPath -notlike '\Microsoft\*' } | ForEach-Object {
    $exe = ($_.Actions | Select-Object -First 1).Execute
    $st = if (Test-Exe $exe) { 'OK' } else { 'ORPHAN' }
    "{0} | {1}{2} | {3} | {4}" -f $st, $_.TaskPath, $_.TaskName, $_.State, $exe
}

""; "== SIGNATURES OF RUNNING NON-WINDOWS PROGRAMS =="
Get-Process | Where-Object { $_.Path -and $_.Path -notlike 'C:\Windows\*' } | Sort-Object Path -Unique |
  ForEach-Object {
    $s = Get-AuthenticodeSignature -FilePath $_.Path
    $who = if ($s.SignerCertificate) { ($s.SignerCertificate.Subject -split ',')[0] -replace '^CN=' } else { '-' }
    "{0} | {1} | {2}" -f $s.Status, $who, $_.Path
  }

""; "== VPN / BROWSER EXTENSIONS (privacy) =="
Get-VpnConnection | ForEach-Object { "VPN: {0} -> {1}" -f $_.Name, $_.ServerAddress }
foreach ($b in "$LA\Google\Chrome\User Data\Default\Extensions", "$LA\Microsoft\Edge\User Data\Default\Extensions") {
  if (Test-Path $b) {
    Get-ChildItem $b -Directory | ForEach-Object {
      $m = Get-ChildItem $_.FullName -Recurse -Filter manifest.json | Select-Object -First 1
      if ($m) { $j = Get-Content $m.FullName -Raw | ConvertFrom-Json; "Extension: {0} ({1})" -f $j.name, $_.Name }
    }
  }
}

""; "Scan finished. Nothing was changed."
