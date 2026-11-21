# Adds to ChestCounter's generated report.html:
#  1) last match line: "Last: <chests> chests @ <time> | Team: <team>"
#  2) "All treasure prizes" table: every prize of every week (not only the current week)
#     with its odds and what the player already got (own find, team find, or manual).
# Also adds the last-match line to overlay.html. Re-injects after each program rewrite.
# Only one watcher per PC: every program restart used to add another one, and they rewrote
# the pages at the same time (flicker). The extra copies simply exit here.
$createdNew = $false
try { $single = New-Object System.Threading.Mutex($true, 'Local\ChestCounterUiInject', [ref]$createdNew) } catch { $createdNew = $true }
if (-not $createdNew) { exit }

$dir = "$env:APPDATA\ChestCounter"
$reportPath = Join-Path $dir 'report.html'
$overlayPath = Join-Path $dir 'overlay.html'
$dataFile = Join-Path $dir 'data.json'
$cfgFile = Join-Path $dir 'config.json'
$contentFile = Join-Path $dir 'content.json'
$manualFile = Join-Path $PSScriptRoot 'cc-prize-manual.json'
$countsFile = Join-Path $PSScriptRoot 'cc-counts.json'
$marker = 'data-cc-last'
$prizeMarker = 'data-cc-prizes'
$openedMarker = 'data-cc-opened'
$replayMarker = 'data-cc-replay'
$lastMatchMarker = 'data-cc-lastmatch'
$friendMarker = 'data-cc-friends'
$heroLastMarker = 'data-cc-hero-last'

$kindNames = @{
    'outfit' = 'Gold Outfit'
    'pirate-shop' = 'Pirate Shop Access'
    'car' = 'Vehicle &amp; Decal'
    'pickaxe' = 'Pickaxe / Back Bling'
    'jam' = 'Jam Track'
    'loading' = 'Loading Screen'
    'gizmo' = 'Gizmo'
}

function Write-Atomic([string]$path, [string]$content) {
    $tmp = "$path.cc-tmp"
    [System.IO.File]::WriteAllText($tmp, $content, [System.Text.Encoding]::UTF8)
    Move-Item $tmp $path -Force
}

function Html([string]$s) { $s -replace '&','&amp;' -replace '<','&lt;' -replace '>','&gt;' }
function UtcTime([string]$s) { [datetimeoffset]::Parse($s).UtcDateTime }

# prize id (content.json "id", e.g. w3-car) that the replay data misses.
# Entries are either a plain id (you got it) or { id, by: "squad"|"you", note }.
$manual = @{}
if (Test-Path $manualFile) {
    try {
        $parsed = Get-Content $manualFile -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
        foreach ($e in @($parsed)) {
            if ($null -eq $e) { continue }
            if ($e -is [string]) {
                $manual[[string]$e] = @{ By = 'you'; Note = 'you confirmed' }
            } elseif ($e.id) {
                $by = if ($e.by) { [string]$e.by } else { 'you' }
                $note = if ($e.note) { [string]$e.note } else { if ($by -eq 'squad') { 'teammate got it' } else { 'you confirmed' } }
                $manual[[string]$e.id] = @{ By = $by; Note = $note }
            }
        }
    } catch { $manual = @{} }
}

# Chest counts the player confirmed from Fortnite (treasure / rare / sprite).
$counts = @{ treasure = 0; rare = 0; sprite = 0 }
if (Test-Path $countsFile) {
    try {
        $parsedCounts = Get-Content $countsFile -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
        foreach ($k in @('treasure', 'rare', 'sprite')) {
            if ($null -ne $parsedCounts.$k) { $counts[$k] = [int]$parsedCounts.$k }
        }
    } catch { }
}
$confirmedTotal = [int]$counts.treasure + [int]$counts.rare + [int]$counts.sprite
$confirmedText = [string]::Format([Globalization.CultureInfo]::InvariantCulture, '{0:N0}', $confirmedTotal)

# Stay idle while nothing on disk changes: parsing data.json every second
# is wasted CPU/RAM on a weak machine. Only wake on a real file change.
$lastStamp = ''
while ($true) {
    try {
        $stamp = @($dataFile, $cfgFile, $contentFile, $reportPath, $overlayPath) | ForEach-Object {
            $f = Get-Item $_ -ErrorAction SilentlyContinue
            if ($f) { "$($f.LastWriteTimeUtc.Ticks)-$($f.Length)" } else { 'none' }
        }
        $stamp = $stamp -join '|'
        if ($stamp -eq $lastStamp) {
            Start-Sleep -Milliseconds 1500
            continue
        }
        $lastStamp = $stamp

        $d = Get-Content $dataFile -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
        $cfg = Get-Content $cfgFile -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
        $content = Get-Content $contentFile -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop

        $profile = $cfg.Profile
        $mine = @($d.Matches | Where-Object { $_.EpicId -eq $profile })
        $last = $mine | Sort-Object MatchStartUtc | Select-Object -Last 1
        if (-not $last) { $last = $d.Matches | Sort-Object MatchStartUtc | Select-Object -Last 1 }

        # The program counts opened AND broken (shot/destroyed) chests together.
        # Show the exact opened count separately, without guessing.
        $openedCount = 0; $brokenCount = 0
        foreach ($mm in $mine) {
            foreach ($c in @($mm.Chests)) {
                if ($c.Destroyed) { $brokenCount++ } else { $openedCount++ }
            }
        }
        $openedText = [string]::Format([Globalization.CultureInfo]::InvariantCulture, '{0:N0}', $openedCount)
        $brokenText = [string]::Format([Globalization.CultureInfo]::InvariantCulture, '{0:N0}', $brokenCount)

        # The program rewrites overlay.html on every live update but only rewrites report.html
        # after a full replay pass. Keep both pages in sync with data.json so the total really
        # moves when a chest is counted. Changes only when data changes, never on a timer: no flicker.
        $countedLive = 0; $teamLive = 0
        foreach ($mm in $mine) {
            $countedLive += [int]$mm.ChestsOpened
            $teamLive += [int]$mm.TeamChestsOpened
        }
        $manualAdj = 0
        if ($d.ManualChests -and $d.ManualChests.PSObject.Properties.Name -contains $profile) {
            $manualAdj = [int]$d.ManualChests.$profile
        }
        # Confirmed starting point (ChestBaselines): replays already there when it was read are
        # not added twice; only chests counted afterwards grow the counter.
        $baseTotal = $countedLive
        if ($d.ChestBaselines -and $d.ChestBaselines.PSObject.Properties.Name -contains $profile) {
            $b = $d.ChestBaselines.$profile
            $baseTotal = [int]$b.Total + [math]::Max(0, $countedLive - [int]$b.Counted)
        }
        $liveTotal = [math]::Max(0, $baseTotal + $manualAdj)
        $fmtNum = { param($x) [string]::Format([Globalization.CultureInfo]::InvariantCulture, '{0:N0}', $x) }
        $liveTotalText = & $fmtNum $liveTotal
        $liveSquadText = & $fmtNum ($liveTotal + $teamLive)

        # Last match: exact opened/broken for you, and every teammate by username.
        $lastOpened = 0; $lastBroken = 0
        if ($last) {
            foreach ($c in @($last.Chests)) {
                if ($c.Destroyed) { $lastBroken++ } else { $lastOpened++ }
            }
        }
        $lastTotal = $lastOpened + $lastBroken
        $lastTotalText = "<b>$lastTotal</b>"
        $lastTime = if ($last) { [datetime]::Parse($last.MatchStartUtc).ToLocalTime().ToString('HH:mm') } else { '--:--' }
        $friendRows = New-Object System.Text.StringBuilder
        $friendBits = New-Object System.Collections.Generic.List[string]
        foreach ($tm in @($last.TeamChests)) {
            $tmName = Html ([string]$tm.Name)
            $tmOpened = [math]::Max(0, [int]$tm.Chests - [int]$tm.Destroyed)
            [void]$friendRows.AppendLine("<tr><td>$tmName</td><td>$tmOpened</td><td>$($tm.Destroyed)</td><td><b>$($tm.Chests)</b></td></tr>")
            [void]$friendBits.Add("$tmName $tmOpened ($($tm.Chests) total)")
        }
        if ($friendRows.Length -eq 0) {
            [void]$friendRows.AppendLine('<tr><td colspan="4" class="muted">No teammates in this replay</td></tr>')
            $friendText = '<span class="muted">no teammates</span>'
        } else {
            $friendText = $friendBits -join ' &middot; '
        }

        # ---- Treasure Hour: live / next window and the boosted odds ----
        $nowUtc = [datetime]::UtcNow
        $oddsByKind = @{}
        foreach ($o in @($content.odds)) { $oddsByKind[[string]$o.kind] = [double]$o.oneIn }
        $hoursSorted = @($content.treasureHours | Sort-Object { UtcTime ([string]$_.start) })
        $liveHour = $hoursSorted | Where-Object { $nowUtc -ge (UtcTime ([string]$_.start)) -and $nowUtc -lt (UtcTime ([string]$_.end)) } | Select-Object -First 1
        $nextHour = $hoursSorted | Where-Object { $nowUtc -lt (UtcTime ([string]$_.start)) } | Select-Object -First 1
        $showHour = if ($liveHour) { $liveHour } else { $nextHour }
        $boostByKind = @{}
        $boostBits = New-Object System.Collections.Generic.List[string]
        foreach ($k in @('car', 'outfit', 'pirate-shop')) {
            $b = 0.0
            if ($showHour -and $showHour.boosts.PSObject.Properties.Name -contains $k) {
                $b = [double]$showHour.boosts.PSObject.Properties[$k].Value
            }
            if ($b -gt 0 -and $oddsByKind.ContainsKey($k)) {
                $boostByKind[$k] = $b
                $newOdds = [math]::Round($oddsByKind[$k] / $b)
                $label = if ($k -eq 'car') { 'Vehicle' } elseif ($k -eq 'outfit') { 'Gold outfit' } else { 'Pirate token' }
                [void]$boostBits.Add("$label &times;$([string]::Format([Globalization.CultureInfo]::InvariantCulture,'{0:0.#}',$b)) &rarr; 1 in $([string]::Format([Globalization.CultureInfo]::InvariantCulture,'{0:N0}',$newOdds))")
            }
        }
        # The report's own "Your chances" banner draws the live time/countdown itself.
        # Never write a ticking value into the HTML: it changes every second and makes the
        # watcher rewrite the file (and the browser reload it) over and over -> flicker.

        # prizeId -> own/team counts + last date (own finds first, then team finds)
        $got = @{}
        function Add-Find([string]$id, [bool]$team, $match) {
            if (-not $id) { return }
            if (-not $got.ContainsKey($id)) { $got[$id] = @{ Own = 0; Team = 0; Last = $null } }
            if ($team) { $got[$id].Team++ } else { $got[$id].Own++ }
            $ts = [datetime]::Parse($match.MatchStartUtc)
            if (-not $got[$id].Last -or $ts -gt $got[$id].Last) { $got[$id].Last = $ts }
        }
        foreach ($m in $d.Matches) {
            foreach ($f in @($m.TreasureFinds)) {
                if ($f.PrizeId -like 'DelilahPrize:*') { Add-Find $f.PrizeId $false $m }
            }
            foreach ($f in @($m.TeamTreasureFinds)) {
                if ($f.PrizeId -like 'DelilahPrize:*') { Add-Find $f.PrizeId $true $m }
            }
        }

        # ---- report.html: last line + all-prizes table ----
        if (Test-Path $reportPath) {
            $h = Get-Content $reportPath -Raw
            $originalReport = $h
            $changed = $false

            # Self-heal an older broken pass: prize rows and a run of <br> tags
            # could end up inside the hero tile and make the page grow forever.
            $tilesMatch = [regex]::Match($h, '<section class="tiles[\s\S]*?</section>')
            if ($tilesMatch.Success) {
                $brCount = [regex]::Matches($tilesMatch.Value, '<br>').Count
                if ($brCount -gt 8 -or $tilesMatch.Value -match '<tr>|<table') {
                    $pencil = [regex]::Match($tilesMatch.Value, '<button[^>]*class="editbtn"[\s\S]*?</button>').Value
                    $sessionTxt = [regex]::Match($tilesMatch.Value, '([\d,]+)\s+since the tool started').Groups[1].Value
                    if (-not $sessionTxt) { $sessionTxt = '0' }
                    $teamChests = 0; $ownFinds = 0; $teamFinds = 0; $bestMatch = 0
                    foreach ($mm in $mine) {
                        $teamChests += [int]$mm.TeamChestsOpened
                        $ownFinds += @($mm.TreasureFinds).Count
                        $teamFinds += @($mm.TeamTreasureFinds).Count
                        $n = @($mm.Chests | Where-Object { -not $_.Destroyed }).Count
                        if ($n -gt $bestMatch) { $bestMatch = $n }
                    }
                    $matchCount = @($mine).Count
                    $heroNum = $liveTotalText
                    $squadText = $liveSquadText
                    $teamText = & $fmtNum $teamChests
                    $bestText = & $fmtNum $bestMatch
                    $findText = & $fmtNum $ownFinds
                    $teamFindText = & $fmtNum $teamFinds
                    $avgText = if ($matchCount -gt 0) { [string]::Format([Globalization.CultureInfo]::InvariantCulture, '{0:0.0}', ($liveTotal / $matchCount)) } else { '0.0' }
                    $teamFindLine = if ($teamFinds -gt 0) { "<br>+$teamFindText by the team (estimate)" } else { '' }
                    $cleanTiles = @"
<section class="tiles hassquad">
  <div class="tile hero">$pencil<div class="k">Chests in total</div><div class="v num">$heroNum</div><div class="l">opened or destroyed by you &middot; $sessionTxt since the tool started<span style="display:block" $heroLastMarker>Last: You <b>$lastOpened</b> + $lastBroken broken = $lastTotalText total &middot; Team <b>$($last.TeamChestsOpened)</b> &middot; $lastTime &mdash; $friendText</span><span style="display:block" $openedMarker>Confirmed base: Treasure $($counts.treasure) &middot; Rare $($counts.rare) &middot; Sprite $($counts.sprite) = <b>$confirmedText</b></span><span style="display:block" $replayMarker>Replays: $openedText opened &middot; $brokenText broken/destroyed</span></div></div>
  <div class="tile squadtile"><div class="v num">$squadText</div><div class="l">squad total<br>you + $teamText by your teammates</div></div>
  <div class="tile"><div class="v num">$(& $fmtNum $matchCount)</div><div class="l">matches analyzed</div></div>
  <div class="tile"><div class="v num">$avgText</div><div class="l">chests per match</div></div>
  <div class="tile"><div class="v num">$bestText</div><div class="l">best match</div></div>
  <div class="tile"><div class="v num">$findText</div><div class="l">treasures found$teamFindLine</div></div>
</section>
"@
                    $h = $h.Remove($tilesMatch.Index, $tilesMatch.Length).Insert($tilesMatch.Index, $cleanTiles)
                    $changed = $true
                }
            }

            if ($last -and $h -notmatch $marker) {
                $t = [datetime]::Parse($last.MatchStartUtc).ToLocalTime().ToString('HH:mm')
                $tag = "Last: $($last.ChestsOpened) chests @ $t | Team: $($last.TeamChestsOpened)"
                if ($h -match '(<div class="k">Chests in total</div><div class="v num">[\d,]+</div><div class="l">)([^<]*)') {
                    $h = $h -replace '(<div class="k">Chests in total</div><div class="v num">[\d,]+</div><div class="l">)([^<]*)', "`${1}`${2}<br><span $marker>$tag</span>"
                    $changed = $true
                }
            }

            # Confirmed total from Fortnite (cc-counts.json) + replay breakdown.
            if ($mine) {
                $stripOpenedSpan = '(?:(?:<br>|\s)*)<span[^>]*' + $openedMarker + '[^>]*>[\s\S]*?</span>'
                $stripReplaySpan = '(?:(?:<br>|\s)*)<span[^>]*' + $replayMarker + '[^>]*>[\s\S]*?</span>'
                $stripHeroLast = '(?:(?:<br>|\s)*)<span[^>]*' + $heroLastMarker + '[^>]*>[\s\S]*?</span>'
                $stripThour = '(?:(?:<br>|\s)*)<span[^>]*data-cc-thour[^>]*>[\s\S]*?</span>'
                $h = $h -replace $stripHeroLast, ''
                $h = $h -replace $stripThour, ''
                $h = $h -replace $stripOpenedSpan, ''
                $h = $h -replace $stripReplaySpan, ''
                $numPattern = '(<div class="k">Chests in total</div><div class="v num">)[\d,]+(</div>)'
                if ($h -match $numPattern) {
                    # report.html can lag behind a live update. Refresh it from data.json only
                    # when the number differs, so the page is written once per real change.
                    if ($Matches[1] + $liveTotalText + $Matches[2] -ne [regex]::Match($h, $numPattern).Value) {
                        $h = $h -replace $numPattern, ('${1}' + $liveTotalText + '${2}')
                        $changed = $true
                    }
                    $squadPattern = '(<div class="v num">)[\d,]+(</div><div class="l">squad total)'
                    if ($h -match $squadPattern) {
                        if ($Matches[1] + $liveSquadText + $Matches[2] -ne [regex]::Match($h, $squadPattern).Value) {
                            $h = $h -replace $squadPattern, ('${1}' + $liveSquadText + '${2}')
                            $changed = $true
                        }
                    }
                    $lblPattern = '(<div class="k">Chests in total</div><div class="v num">[\d,]+</div><div class="l">)([^<]*)'
                    if ($h -match $lblPattern) {
                        $heroLastLine = "<span style=`"display:block`" $heroLastMarker>Last: You <b>$lastOpened</b> + $lastBroken broken = $lastTotalText total &middot; Team <b>$($last.TeamChestsOpened)</b> &middot; $lastTime &mdash; $friendText</span>"
                        $confirmedLine = "<span style=`"display:block`" $openedMarker>Confirmed base: Treasure $($counts.treasure) &middot; Rare $($counts.rare) &middot; Sprite $($counts.sprite) = <b>$confirmedText</b> (grows with new chests)</span>"
                        $replayLine = "<span style=`"display:block`" $replayMarker>Replays: $openedText opened &middot; $brokenText broken/destroyed</span>"
                        $h = $h -replace $lblPattern, ('${1}${2}' + $heroLastLine + $confirmedLine + $replayLine)
                    }
                    $changed = $true
                }
            }

            # Self-heal pages written by earlier builds: drop the injected ticker script.
            $oldThourScript = '<script[^>]*data-cc-thour-script[^>]*>[\s\S]*?</script>'
            $h = $h -replace $oldThourScript, ''

            # Last match: you vs squad, with every teammate's username and count.
            if ($last) {
                $lastSection = @"
<section class="card" $lastMatchMarker style="padding:16px 18px;margin-top:18px">
<h2>Last match &mdash; you &amp; squad</h2>
<p class="muted">$lastTime &middot; You opened <b>$lastOpened</b> + $lastBroken broken = <b>$lastTotal</b> total &middot; Team opened <b>$($last.TeamChestsOpened)</b></p>
<table class="ctable" style="width:100%;table-layout:auto">
<thead><tr><th>Player</th><th style="width:100px">Opened</th><th style="width:100px">Broken</th><th style="width:100px">Total</th></tr></thead>
<tbody>
<tr><td><b>$(Html $last.PlayerName) (you)</b></td><td>$lastOpened</td><td>$lastBroken</td><td><b>$lastTotal</b></td></tr>
$($friendRows.ToString())
</tbody></table>
</section>
"@
                $oldLast = [regex]::Match($h, '<section class="card" ' + $lastMatchMarker + '[\s\S]*?</section>')
                if ($oldLast.Success) { $h = $h.Remove($oldLast.Index, $oldLast.Length) }
                $tilesClose = $h.IndexOf('</section>')
                if ($tilesClose -ge 0) {
                    $h = $h.Insert($tilesClose + '</section>'.Length, $lastSection)
                } elseif ($h -match '</main>') {
                    $h = $h -replace '</main>', "$lastSection</main>"
                }
            }

            # build the section fresh (status changes as new finds arrive)
            $oddsMap = @{}
            foreach ($o in $content.odds) { $oddsMap[$o.kind] = $o.oneIn }
            $rows = New-Object System.Text.StringBuilder
            $total = 0; $owned = 0
            $weekList = @($content.weeks | Sort-Object number)
            $weekList += [pscustomobject]@{ number = 0; title = 'Season'; prizes = @($content.pirateShop) }
            foreach ($w in $weekList) {
                $label = if ($w.number -gt 0) { "Week $($w.number)" } else { 'All season' }
                $labelTitle = if ($w.number -gt 0) { " title=`"$(Html $w.title)`"" } else { " title=`"All season`"" }
                foreach ($p in $w.prizes) {
                    $total++
                    $oneIn = if ($oddsMap.ContainsKey($p.kind)) { $oddsMap[$p.kind] } else { $null }
                    $oddsTxt = if ($oneIn) { "1 in {0:N0}" -f $oneIn } else { '&mdash;' }
                    $ownCnt = 0; $teamCnt = 0; $when = $null
                    foreach ($prizeId in @($p.prizeIds)) {
                        if ($prizeId -and $got.ContainsKey($prizeId)) {
                            $ownCnt += $got[$prizeId].Own
                            $teamCnt += $got[$prizeId].Team
                            if ($got[$prizeId].Last) { $when = $got[$prizeId].Last }
                        }
                    }
                    $isManual = $manual.ContainsKey([string]$p.id)
                    $kindName = if ($kindNames.ContainsKey($p.kind)) { $kindNames[$p.kind] } else { Html $p.kind }
                    $thumb = ''
                    if ($p.image) {
                        try {
                            $uri = [uri]$p.image
                            $base = [System.IO.Path]::GetFileNameWithoutExtension($uri.AbsolutePath)
                            $suffix = ''
                            if ($uri.Query) { $suffix = '-' + ($uri.Query.TrimStart('?') -replace '[^A-Za-z0-9]', '') }
                            $rel = "images/$base$suffix.webp"
                            if (Test-Path (Join-Path $dir $rel)) { $thumb = "<img class=`"thumb`" src=`"$rel`" alt=`"`" onerror=`"this.remove()`">" }
                        } catch { }
                    }
                    if ($ownCnt -gt 0) {
                        $owned++
                        $src = "&times;$ownCnt"
                        if ($teamCnt -gt 0) { $src += " +team" }
                        if ($when) { $src += " &middot; " + $when.ToLocalTime().ToString('d MMM HH:mm') }
                        $status = "<span style=`"color:#1f8a4c;font-weight:700`">&#10003; Got it</span> <span class=`"muted`">$src</span>"
                    } elseif ($teamCnt -gt 0) {
                        $owned++
                        $src = "&times;$teamCnt"
                        if ($when) { $src += " &middot; " + $when.ToLocalTime().ToString('d MMM HH:mm') }
                        $status = "<span style=`"color:#2c5d8a;font-weight:700`">&#10003; Squad got it</span> <span class=`"muted`">$src</span>"
                    } elseif ($isManual) {
                        $owned++
                        $m = $manual[[string]$p.id]
                        $note = Html $m.Note
                        if ($m.By -eq 'squad') {
                            $status = "<span style=`"color:#2c5d8a;font-weight:700`">&#10003; Squad got it</span> <span class=`"muted`">$note</span>"
                        } else {
                            $status = "<span style=`"color:#b9821c;font-weight:700`">&#10003; Got it</span> <span class=`"muted`">$note</span>"
                        }
                    } else {
                        $status = '<span class="muted">&mdash;</span>'
                    }
                    $boostCell = '<span class="muted">&mdash;</span>'
                    if ($boostByKind.ContainsKey([string]$p.kind) -and $oddsMap.ContainsKey([string]$p.kind)) {
                        $b = [double]$boostByKind[[string]$p.kind]
                        $boostOdds = [math]::Round([double]$oddsMap[[string]$p.kind] / $b)
                        $boostCell = "<span style=`"color:#b4410f;font-weight:700`">&times;$([string]::Format([Globalization.CultureInfo]::InvariantCulture,'{0:0.#}',$b)) &rarr; 1 in $([string]::Format([Globalization.CultureInfo]::InvariantCulture,'{0:N0}',$boostOdds))</span>"
                    }
                    $nameCell = if ($thumb) { "<div class=`"tflex`">$thumb<div><b>$(Html $p.name)</b></div></div>" } else { "<b>$(Html $p.name)</b>" }
                    [void]$rows.AppendLine("<tr><td$labelTitle>$label</td><td>$nameCell</td><td>$kindName</td><td>$oddsTxt</td><td>$boostCell</td><td>$status</td></tr>")
                }
            }

            $newSection = @"
<section class="card" $prizeMarker style="padding:16px 18px;margin-top:18px">
<h2>All treasure prizes &mdash; every week</h2>
<p class="muted">The whole season, not just this week. Got <b>$owned</b> of <b>$total</b>. Treasure Hour column = better odds during the next (or live) window.</p>
<table class="ctable" style="width:100%;table-layout:auto">
<thead><tr><th style="width:72px">Week</th><th>Prize</th><th style="width:126px">Type</th><th style="width:92px">Each chest</th><th style="width:160px">Treasure Hour</th><th style="width:176px">Status</th></tr></thead>
<tbody>
$($rows.ToString())
</tbody></table>
</section>
"@

            # Put the standalone prize list back at the bottom of the report,
            # with the prizes the player actually got marked. Rebuild it each pass
            # so new finds show up, but never stack duplicates.
            $existing = [regex]::Match($h, '<section class="card" ' + $prizeMarker + '[\s\S]*?</section>')
            if ($existing.Success) { $h = $h.Remove($existing.Index, $existing.Length) }
            $mainClose = $h.LastIndexOf('</main>')
            if ($mainClose -ge 0) {
                $h = $h.Insert($mainClose, $newSection)
                $changed = $true
            }
            # Write only when the bytes really changed. Rewriting an identical
            # page every pass makes ChestCounter's WebView reload and flicker.
            if ($h -cne $originalReport) { $changed = $true } else { $changed = $false }

            if ($changed) { Write-Atomic $reportPath $h }
        }

        # ---- overlay.html: last match line + exact opened count ----
        if ((Test-Path $overlayPath) -and ($last -or $mine)) {
            $o = Get-Content $overlayPath -Raw
            $originalOverlay = $o
            $oChanged = $false
            if ($last -and $o -notmatch $marker -and $o -match '(<div class="r "><span>Last</span>.*?<b>[\d,]+</b>)(</div>)') {
                $t = [datetime]::Parse($last.MatchStartUtc).ToLocalTime().ToString('HH:mm')
                $overlayTag = "@ $t | Team: $($last.TeamChestsOpened)"
                $o = $o -replace '(<div class="r "><span>Last</span>.*?<b>[\d,]+</b>)(</div>)', "`${1}<span class=`"sep`" $marker>$overlayTag</span>`${2}"
                $oChanged = $true
            }
            if ($mine) {
                # Strip every old injected row first. The pattern must be built in a
                # variable: inline `+` concatenation makes -replace miss the match,
                # which stacks duplicate rows on every watcher pass.
                $stripOpened = '<div class="r" ' + $openedMarker + '[^>]*>[\s\S]*?</div>'
                $stripReplay = '<div class="r" ' + $replayMarker + '[^>]*>[\s\S]*?</div>'
                $stripFriends = '<div class="r" ' + $friendMarker + '[^>]*>[\s\S]*?</div>'
                $stripLast = '<div class="r" ' + $lastMatchMarker + '[^>]*>[\s\S]*?</div>'
                $stripThourOverlay = '(?:(?:<br>|\s)*)<span[^>]*data-cc-thour[^>]*>[\s\S]*?</span>'
                $o = $o -replace $stripOpened, ''
                $o = $o -replace $stripReplay, ''
                $o = $o -replace $stripFriends, ''
                $o = $o -replace $stripLast, ''
                $o = $o -replace $stripThourOverlay, ''
                $numPattern = '(<div class="total"[^>]*>.*?</svg>)[\d,]+(</div>)'
                if ($o -match $numPattern) {
                    # Leave the number alone: the program refreshes overlay.html with the live
                    # match included. Only the report (rewritten less often) is synced above.
                    $divPattern = '(<div class="total"[^>]*>.*?</div>)'
                    if ($o -match $divPattern) {
                        # Only you + squad here. Prizes stay in their own report section.
                        $lastMatchDiv = "<div class=`"r`" $lastMatchMarker>You <b>$lastOpened</b> + $lastBroken broken = <b>$lastTotal</b> total &middot; Team <b>$($last.TeamChestsOpened)</b> &middot; $lastTime</div>"
                        $friendDiv = "<div class=`"r`" $friendMarker>$friendText</div>"
                        $o = $o -replace $divPattern, ('${1}' + $lastMatchDiv + $friendDiv)
                    }
                    # Self-heal: drop the injected ticker script from earlier builds.
                    $o = $o -replace '<script[^>]*data-cc-thour-script[^>]*>[\s\S]*?</script>', ''
                    $oChanged = $true
                }
            }
            if ($o -cne $originalOverlay) { $oChanged = $true } else { $oChanged = $false }
            if ($oChanged) { Write-Atomic $overlayPath $o }
        }
    } catch {
        # ignore transient read/write races with ChestCounter
    }
    Start-Sleep -Milliseconds 900
}
