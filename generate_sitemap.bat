$base = "https://ekbass.github.io/BazzBasic/"
$root = "C:\Users\ekvir\source\repos\BazzBasic\docs"
$urls = @($base) + (Get-ChildItem $root -Recurse -Filter *.md | ForEach-Object {
    $base + ($_.FullName.Substring($root.Length + 1) -replace '\\','/')
})
$xml = '<?xml version="1.0" encoding="UTF-8"?>' + "`n" +
       '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' + "`n" +
       ($urls | ForEach-Object { "  <url><loc>$_</loc></url>" }) -join "`n" +
       "`n</urlset>"
Set-Content "$root\sitemap.xml" $xml -Encoding UTF8