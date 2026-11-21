# Adds to ChestCounter's generated report.html:
#  1) last match line: "Last: <chests> chests @ <time> | Team: <team>"
#  2) "All treasure prizes" table: every prize of every week (not only the current week)
#     with its odds and what the player already got (own find, team find, or manual).
# Also adds the last-match line to overlay.html. Re-injects after each program rewrite.
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

while ($true) {
    try {
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

        # Last match: exact opened/broken for you, and every teammate by username.
        $lastOpened = 0; $lastBroken = 0
        if ($last) {
            foreach ($c in @($last.Chests)) {
                if ($c.Destroyed) { $lastBroken++ } else { $lastOpened++ }
            }
        }
        $lastTime = if ($last) { [datetime]::Parse($last.MatchStartUtc).ToLocalTime().ToString('HH:mm') } else { '--:--' }
        $friendRows = New-Object System.Text.StringBuilder
        $friendBits = New-Object System.Collections.Generic.List[string]
        foreach ($tm in @($last.TeamChests)) {
            $tmName = Html ([string]$tm.Name)
            $tmOpened = [math]::Max(0, [int]$tm.Chests - [int]$tm.Destroyed)
            [void]$friendRows.AppendLine("<tr><td>$tmName</td><td>$tmOpened</td><td>$($tm.Destroyed)</td></tr>")
            [void]$friendBits.Add("$tmName $tmOpened")
        }
        if ($friendRows.Length -eq 0) {
            [void]$friendRows.AppendLine('<tr><td colspan="3" class="muted">No teammates in this replay</td></tr>')
            $friendText = '<span class="muted">no teammates</span>'
        } else {
            $friendText = $friendBits -join ' &middot; '
        }

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
            $changed = $false

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
                $stripOpenedSpan = '<span ' + $openedMarker + '[^>]*>[\s\S]*?</span>'
                $stripReplaySpan = '<span ' + $replayMarker + '[^>]*>[\s\S]*?</span>'
                $h = $h -replace $stripOpenedSpan, ''
                $h = $h -replace $stripReplaySpan, ''
                $numPattern = '(<div class="k">Chests in total</div><div class="v num">)[\d,]+(</div>)'
                if ($h -match $numPattern) {
                    $h = $h -replace $numPattern, ('${1}' + $confirmedText + '${2}')
                    $lblPattern = '(<div class="k">Chests in total</div><div class="v num">[\d,]+</div><div class="l">)([^<]*)'
                    if ($h -match $lblPattern) {
                        $confirmedLine = "<br><span $openedMarker>Confirmed: Treasure $($counts.treasure) &middot; Rare $($counts.rare) &middot; Sprite $($counts.sprite) = <b>$confirmedText</b></span>"
                        $replayLine = "<br><span $replayMarker>Replays: $openedText opened &middot; $brokenText broken/destroyed</span>"
                        $h = $h -replace $lblPattern, ('${1}${2}' + $confirmedLine + $replayLine)
                    }
                    $changed = $true
                }
            }

            # Last match: you vs squad, with every teammate's username and count.
            if ($last) {
                $lastSection = @"
<section class="card" $lastMatchMarker style="padding:16px 18px;margin-top:18px">
<h2>Last match &mdash; you &amp; squad</h2>
<p class="muted">$lastTime &middot; You opened <b>$lastOpened</b> &middot; Team opened <b>$($last.TeamChestsOpened)</b></p>
<table class="ctable" style="width:100%;table-layout:auto">
<thead><tr><th>Player</th><th style="width:110px">Opened</th><th style="width:110px">Broken</th></tr></thead>
<tbody>
<tr><td><b>$(Html $last.PlayerName) (you)</b></td><td>$lastOpened</td><td>$lastBroken</td></tr>
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
                    $nameCell = if ($thumb) { "<div class=`"tflex`">$thumb<div><b>$(Html $p.name)</b></div></div>" } else { "<b>$(Html $p.name)</b>" }
                    [void]$rows.AppendLine("<tr><td$labelTitle>$label</td><td>$nameCell</td><td>$kindName</td><td>$oddsTxt</td><td>$status</td></tr>")
                }
            }

            $newSection = @"
<section class="card" $prizeMarker style="padding:16px 18px;margin-top:18px">
<h2>All treasure prizes &mdash; every week</h2>
<p class="muted">The whole season, not just this week. Got <b>$owned</b> of <b>$total</b>.</p>
<table class="ctable" style="width:100%;table-layout:auto">
<thead><tr><th style="width:72px">Week</th><th>Prize</th><th style="width:126px">Type</th><th style="width:92px">Each chest</th><th style="width:176px">Status</th></tr></thead>
<tbody>
$($rows.ToString())
</tbody></table>
</section>
"@

            # The prizes keep their original place in the program's own "collection"
            # and "treasures" sections. Drop our extra table so the page stays short.
            $existing = [regex]::Match($h, '<section class="card" ' + $prizeMarker + '[\s\S]*?</section>')
            if ($existing.Success) {
                $h = $h.Remove($existing.Index, $existing.Length)
                $changed = $true
            }
            if ($h -ne (Get-Content $reportPath -Raw)) { $changed = $true }

            if ($changed) { Write-Atomic $reportPath $h }
        }

        # ---- overlay.html: last match line + exact opened count ----
        if ((Test-Path $overlayPath) -and ($last -or $mine)) {
            $o = Get-Content $overlayPath -Raw
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
                $o = $o -replace $stripOpened, ''
                $o = $o -replace $stripReplay, ''
                $o = $o -replace $stripFriends, ''
                $o = $o -replace $stripLast, ''
                $numPattern = '(<div class="total"[^>]*>.*?</svg>)[\d,]+(</div>)'
                if ($o -match $numPattern) {
                    $o = $o -replace $numPattern, ('${1}' + $confirmedText + '${2}')
                    $divPattern = '(<div class="total"[^>]*>.*?</div>)'
                    if ($o -match $divPattern) {
                        # Only you + squad here. Prizes stay in their own report section.
                        $lastMatchDiv = "<div class=`"r`" $lastMatchMarker>You <b>$lastOpened</b> &middot; Team <b>$($last.TeamChestsOpened)</b> &middot; $lastTime</div>"
                        $friendDiv = "<div class=`"r`" $friendMarker>$friendText</div>"
                        $o = $o -replace $divPattern, ('${1}' + $lastMatchDiv + $friendDiv)
                    }
                    $oChanged = $true
                }
            }
            if ($oChanged) { Write-Atomic $overlayPath $o }
        }
    } catch {
        # ignore transient read/write races with ChestCounter
    }
    Start-Sleep -Milliseconds 900
}
