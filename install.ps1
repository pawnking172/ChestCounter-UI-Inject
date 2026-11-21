# One-time installer: start the watcher now and add it to Startup.
$script = Join-Path $PSScriptRoot 'cc-ui-inject.ps1'
if (-not (Test-Path $script)) { throw "Missing cc-ui-inject.ps1 next to install.ps1" }

$startup = [Environment]::GetFolderPath('Startup')
$link = Join-Path $startup 'ChestCounter UI Inject.lnk'
$ws = New-Object -ComObject WScript.Shell
$sc = $ws.CreateShortcut($link)
$sc.TargetPath = 'powershell.exe'
$sc.Arguments = '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "' + $script + '"'
$sc.WorkingDirectory = $PSScriptRoot
$sc.Description = 'ChestCounter UI injector (prizes table + last match line)'
$sc.Save()

Start-Process powershell.exe -ArgumentList '-NoProfile', '-ExecutionPolicy', 'Bypass', '-WindowStyle', 'Hidden', '-File', ('"' + $script + '"')
"Installed: $link"
