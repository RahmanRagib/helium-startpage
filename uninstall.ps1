# SimpleStart portable uninstall - reverts what setup.ps1 did.
$ErrorActionPreference = 'SilentlyContinue'
$here    = Split-Path -Parent $MyInvocation.MyCommand.Path
$flagRemoval = '--custom-ntp="[^"]*"'

Write-Host '== SimpleStart portable uninstall =='

# 1. unpatch every Helium shortcut
$linkRoots = @(
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs",
    "$env:USERPROFILE\Desktop",
    "$env:PUBLIC\Desktop",
    "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch"
)
$shell = New-Object -ComObject WScript.Shell
foreach ($root in $linkRoots) {
    Get-ChildItem $root -Filter '*.lnk' -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match 'helium' -and $_.FullName -notmatch 'uninstall' } |
        ForEach-Object {
            $sc = $shell.CreateShortcut($_.FullName)
            $sc.Arguments = ($sc.Arguments -replace $flagRemoval, '').Trim()
            $sc.Save()
            Write-Host "[reverted] $($_.FullName)"
        }
}

# 2. remove the installed page (leave $here\startpage untouched - that is the source of truth)
Remove-Item (Join-Path $env:LOCALAPPDATA 'Helium-Start') -Recurse -Force
Write-Host '[removed] %LOCALAPPDATA%\Helium-Start'
Write-Host 'done. Helium returns to its stock new tab page on next full restart.'
