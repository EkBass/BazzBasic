# BazzBasic — Release Checklist

## 1. Päivitä versio
Tiedosto: `src/Version.cs`
```csharp
public const string Version = "1.1x";  // esim. "1.1c"
```

## 2. Tyhjennä publish-kansio
```
bin\Release\net10.0-windows\win-x64\publish\
```
Poista kaikki tiedostot ja kansiot.

## 3. Buildaa
Aja: `build.bat`  
Tai: `dotnet publish BazzBasic.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true`

## 4. Testaa
Aja muutama testi publish-kansiosta:
```
bin\Release\net10.0-windows\win-x64\publish\BazzBasic.exe
```

## 5. Poista duplikaatti-DLL:t publish-juuresta
Poista nämä kaksi — ne löytyvät jo `runtimes/`-kansiosta:
- [ ] `Lexilla.dll`
- [ ] `Scintilla.dll`

## 6. Kopioi lisätiedostot publish-kansioon
- [ ] Kansio `Examples\`
- [ ] `changes.md`
- [ ] `license.txt`

## 7. Pakkaa zip
Pakkaa koko publish-kansio:  
`BazzBasic_win_x64_1.1x.zip`  
(korvaa `x` versiolla, esim. `1.1c`)

## 8. GitHub Releases — poista vanha
Avaa: https://github.com/EkBass/BazzBasic/releases  
Poista edellinen release.

## 9. GitHub Releases — lisää uusi
- Tag: `v1.1x`
- Title: `BazzBasic 1.1x`
- Lataa zip
- Kirjoita release notes (voi kopioida changes.md:stä)

## 10. Push lähdekoodi
```
C:\Users\ekvir\source\repos\push-all.sh "Release 1.1x"
```

## 11. Mainosta
- [ ] GitHub Discussions
- [ ] ThinBasic forum: https://www.thinbasic.com/community/forumdisplay.php?401-BazzBasic
- [ ] Discord: https://discord.com/channels/682603735515529216/1464283741919907932
- [ ] Päivitä BazzBasic-AI-guide.md (jos isompi versio)
