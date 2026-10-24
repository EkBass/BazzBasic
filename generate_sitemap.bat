$base    = "https://ekbass.github.io/BazzBasic/"
$root    = "C:\Users\ekvir\source\repos\BazzBasic\docs"
$exclude = @('index.html', '_sidebar.md', 'README.md')

# Juuren HTML-sivut (ei rekursiota: manual/index.html on docsifyn kuori)
# Extension -eq vertailu varmistaa, ettei *.html_bu -varmuuskopioita tule mukaan
$html = Get-ChildItem $root -File |
        Where-Object { $_.Extension -eq '.html' -and $exclude -notcontains $_.Name }

# Manuaalin sivut
$md = Get-ChildItem "$root\manual" -Recurse -File |
      Where-Object { $_.Extension -eq '.md' -and $exclude -notcontains $_.Name }

$entries = @([pscustomobject]@{ Loc = $base; Mod = (Get-Item "$root\index.html").LastWriteTime })
foreach ($f in @($html) + @($md)) {
    $rel = $f.FullName.Substring($root.Length + 1) -replace '\\', '/'
    $entries += [pscustomobject]@{ Loc = $base + $rel; Mod = $f.LastWriteTime }
}

$sb = [System.Text.StringBuilder]::new()
[void]$sb.AppendLine('<?xml version="1.0" encoding="UTF-8"?>')
[void]$sb.AppendLine('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">')
foreach ($e in $entries) {
    $loc = [System.Security.SecurityElement]::Escape($e.Loc)
    [void]$sb.AppendLine('  <url>')
    [void]$sb.AppendLine("    <loc>$loc</loc>")
    [void]$sb.AppendLine("    <lastmod>$($e.Mod.ToString('yyyy-MM-dd'))</lastmod>")
    [void]$sb.AppendLine('  </url>')
}
[void]$sb.Append('</urlset>')

# UTF-8 ilman BOMia
[System.IO.File]::WriteAllText("$root\sitemap.xml", $sb.ToString(), [System.Text.UTF8Encoding]::new($false))
Write-Host "sitemap.xml: $($entries.Count) URLs"