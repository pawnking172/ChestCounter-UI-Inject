# Rebuilds the modified ChestCounter and publishes it as a new release.
# Run after every UI change: it copies the live injector into the source, bumps
# the version, builds, uploads the exe, and syncs the addon files to the repo.
$ErrorActionPreference = 'Stop'
$repo = 'pawnking172/ChestCounter-UI-Inject'
$root = 'C:\Users\3bood\Tools\cc-build'
$dotnet = Join-Path $env:LOCALAPPDATA 'Microsoft\dotnet\dotnet.exe'
$liveInject = 'C:\Users\3bood\Tools\cc-ui-inject.ps1'
$liveManual = 'C:\Users\3bood\Tools\cc-prize-manual.json'

if (-not (Test-Path $dotnet)) { throw 'Local .NET SDK missing' }
Copy-Item $liveInject "$root\src\ChestCounter\Addon\cc-ui-inject.ps1" -Force
Copy-Item $liveManual "$root\src\ChestCounter\Addon\cc-prize-manual.json" -Force

$tag = (gh release view --repo $repo --json tagName --jq '.tagName' 2>$null)
if (-not $tag) { $tag = 'v1.5.1' }
$v = [version]$tag.TrimStart('v')
$new = '{0}.{1}.{2}' -f $v.Major, $v.Minor, ($v.Build + 1)

$csproj = "$root\src\ChestCounter\ChestCounter.csproj"
$text = Get-Content $csproj -Raw
$text = $text -replace '<Version>[^<]+</Version>', "<Version>$new</Version>"
Set-Content $csproj -Value $text -Encoding UTF8

$notes = @"
**English** — ChestCounter UI addon build $new. **Check for updates** follows this repository, so this build arrives through the button.

**What's new in $new**
- Latest UI addon changes (all treasure prizes table, last match line, related fixes).
- Your history and settings are kept.

---

**Français** — Version avec l'addon d'interface $new. Le bouton **Vérifier les mises à jour** suit ce dépôt.

---

**Español** — Versión con el addon de interfaz $new. El botón **Buscar actualizaciones** sigue este repositorio.
"@
Set-Content "$root\RELEASE_NOTES.md" -Value $notes -Encoding UTF8

Set-Location $root
& $dotnet publish src\ChestCounter\ChestCounter.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true -p:EnableCompressionInSingleFile=true -p:DebugType=none -o dist
if ($LASTEXITCODE -ne 0) { throw "Build failed ($LASTEXITCODE)" }

$exe = "$root\dist\ChestCounter.exe"
$newTag = "v$new"
if (gh release view $newTag --repo $repo 2>$null) {
    gh release upload $newTag $exe --repo $repo --clobber
} else {
    gh release create $newTag $exe --repo $repo --title "ChestCounter $new - UI addon build" --notes-file "$root\RELEASE_NOTES.md"
}

# sync addon files in the repo
foreach ($pair in @(@('README.md', "$root\README.md"), @('cc-ui-inject.ps1', $liveInject), @('cc-prize-manual.json', $liveManual))) {
    $name = $pair[0]; $path = $pair[1]
    $b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($path))
    $json = gh api "repos/$repo/contents/$name" 2>$null | ConvertFrom-Json
    $args = @('--method','PUT',"repos/$repo/contents/$name",'-f','message=Sync addon files','-f',"content=$b64")
    if ($json.sha) { $args += @('-f', "sha=$($json.sha)") }
    gh api @args | Out-Null
}

"RELEASE=$newTag"
"URL=https://github.com/$repo/releases/latest"
