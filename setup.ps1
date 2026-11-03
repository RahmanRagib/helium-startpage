# SimpleStart portable setup - run with: powershell -ExecutionPolicy Bypass -File setup.ps1
# or double-click run-setup.cmd
# Installs the startpage to a stable per-user location and wires Helium's own
# custom-ntp flag onto every Helium shortcut found on this PC.

$ErrorActionPreference = 'Stop'
$here      = Split-Path -Parent $MyInvocation.MyCommand.Path
$src       = Join-Path $here 'startpage'
$pageDir   = Join-Path $env:LOCALAPPDATA 'Helium-Start'
$pageUrl   = ('file:///' + ($pageDir -replace '\\', '/') + '/index.html') -replace ' ', '%20'
$flag      = '--custom-ntp="' + $pageUrl + '"'

Write-Host '== SimpleStart portable setup =='
Write-Host "page source : $src"
Write-Host "page target : $pageDir"

# 1. install the page (mirror = removes stale files from previous versions)
if (-not (Test-Path $src)) { throw "startpage folder not found next to this script: $src" }
robocopy $src $pageDir /MIR /R:1 /W:1 /NFL /NDL /NJH /NJS | Out-Null
Write-Host '[ok] startpage files copied'

# 2. find every Helium shortcut on this PC (start menu, desktop, taskbar pin, public desktop)
$linkRoots = @(
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs",
    "$env:USERPROFILE\Desktop",
    "$env:PUBLIC\Desktop",
    "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch"
)
$links = @()
foreach ($root in $linkRoots) {
    if (-not (Test-Path $root)) { continue }
    $links += Get-ChildItem $root -Filter '*.lnk' -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match 'helium' -and $_.FullName -notmatch 'uninstall' }
}
if ($links.Count -eq 0) { throw 'no Helium shortcuts found - launch Helium once and pin it, then rerun' }

# 3. patch each shortcut idempotently (strip any previous custom-ntp, then append)
$shell = New-Object -ComObject WScript.Shell
foreach ($link in $links) {
    $sc = $shell.CreateShortcut($link.FullName)
    $args2 = ($sc.Arguments -replace '--custom-ntp="[^"]*"', '').Trim()
    if ($args2 -match 'custom-ntp=') { throw "shortcut has unquoted custom-ntp arg: $($link.FullName)" }
    $sc.Arguments = ($args2 + ' ' + $flag).Trim()
    $sc.Save()
    Write-Host "[ok] $($link.FullName)"
}

# 4. sanity checks
$helium = Join-Path $env:LOCALAPPDATA 'imput\Helium\Application\chrome.exe'
if (-not (Test-Path $helium)) {
    Write-Warning 'Helium not found at its standard install path - shortcuts still patched; verify Helium is installed.'
}

if (-not (Get-Command robocopy -ErrorAction SilentlyContinue)) { }

Write-Host ''
Write-Host 'done. Fully quit and relaunch Helium - it will open this startpage natively as its new tab.'
Write-Host 'If you had the SimpleStart extension installed, remove it at chrome://extensions (no longer needed).'
