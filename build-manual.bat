@echo off
REM ============================================================
REM  BazzBasic Manual Builder
REM  Generates offline HTML (and optionally CHM) from markdown
REM  Requires: Pandoc  https://pandoc.org/installing.html
REM ============================================================

set MANUAL_DIR=docs\manual
set DIST_DIR=dist
set OUTPUT_HTML=%DIST_DIR%\BazzBasic-Manual.html
set OUTPUT_CHM_DIR=%DIST_DIR%\chm

REM -- Tarkista että Pandoc löytyy --
where pandoc >nul 2>&1
if errorlevel 1 (
    echo [VIRHE] Pandoc ei löydy. Asenna: https://pandoc.org/installing.html
    pause
    exit /b 1
)

REM -- Luo dist-hakemisto jos puuttuu --
if not exist "%DIST_DIR%" mkdir "%DIST_DIR%"

echo.
echo  Generoidaan offline HTML-manuaali...
echo  Kohde: %OUTPUT_HTML%
echo.

REM -- Sivujen järjestys _sidebar.md:n mukaan --
pandoc ^
  %MANUAL_DIR%\README.md ^
  %MANUAL_DIR%\contact.md ^
  %MANUAL_DIR%\installation.md ^
  %MANUAL_DIR%\ide-usage.md ^
  %MANUAL_DIR%\packaging.md ^
  %MANUAL_DIR%\libraries.md ^
  %MANUAL_DIR%\cli_features.md ^
  %MANUAL_DIR%\ai-assist.md ^
  %MANUAL_DIR%\rosetta-code.md ^
  %MANUAL_DIR%\beginners-guide.md ^
  %MANUAL_DIR%\variables-and-constants.md ^
  %MANUAL_DIR%\arrays_and_json.md ^
  %MANUAL_DIR%\operators.md ^
  %MANUAL_DIR%\comments.md ^
  %MANUAL_DIR%\user-defined-functions.md ^
  %MANUAL_DIR%\control-flow.md ^
  %MANUAL_DIR%\statements.md ^
  %MANUAL_DIR%\functions.md ^
  %MANUAL_DIR%\math_functions.md ^
  %MANUAL_DIR%\string_functions.md ^
  %MANUAL_DIR%\input_functions.md ^
  %MANUAL_DIR%\fast_trigonomy.md ^
  %MANUAL_DIR%\other_functions.md ^
  %MANUAL_DIR%\file-io.md ^
  %MANUAL_DIR%\graphics.md ^
  %MANUAL_DIR%\sounds.md ^
  %MANUAL_DIR%\network.md ^
  %MANUAL_DIR%\preprocessor.md ^
  %MANUAL_DIR%\keywords.md ^
  -f markdown-tex_math_dollars-tex_math_single_backslash ^
  -o %OUTPUT_HTML% ^
  --template tools\manual-template.html ^
  --toc --toc-depth=2 ^
  --embed-resources --standalone ^
  --metadata title="BazzBasic Manual" ^
  --metadata lang="en" ^
  --highlight-style=tango

if errorlevel 1 (
    echo [VIRHE] HTML-generointi epäonnistui.
    pause
    exit /b 1
)

echo  [OK] HTML luotu: %OUTPUT_HTML%

REM ============================================================
REM  CHM-generointi (valinnainen)
REM  Vaatii: HTML Help Workshop
REM  https://web.archive.org/web/2024/https://www.microsoft.com/en-us/download/details.aspx?id=21138
REM  tai: choco install html-help-workshop
REM ============================================================

REM Poista kommentti seuraavasta REM-rivistä jos HTML Help Workshop on asennettu:
REM goto :build_chm

goto :done

:build_chm
echo.
echo  Valmistellaan CHM-rakenne...

if not exist "%OUTPUT_CHM_DIR%" mkdir "%OUTPUT_CHM_DIR%"

REM -- Aja Pandoc uudelleen erillisiin tiedostoihin CHM-projektia varten --
set PAGES=README contact installation ide-usage packaging libraries cli_features ai-assist rosetta-code beginners-guide variables-and-constants arrays_and_json operators comments user-defined-functions control-flow statements functions math_functions string_functions input_functions fast_trigonomy other_functions file-io graphics sounds network preprocessor keywords

for %%P in (%PAGES%) do (
    pandoc %MANUAL_DIR%\%%P.md ^
      -f markdown-tex_math_dollars-tex_math_single_backslash ^
      -o %OUTPUT_CHM_DIR%\%%P.html ^
      --embed-resources --standalone ^
      --metadata title="BazzBasic Manual" ^
      --highlight-style=tango
)

REM -- Generoi .hhp projekti- ja .hhc sisältötiedostot --
python tools\make-chm.py %OUTPUT_CHM_DIR%

REM -- Käännä CHM --
"C:\Program Files (x86)\HTML Help Workshop\hhc.exe" %OUTPUT_CHM_DIR%\BazzBasic.hhp

if errorlevel 1 (
    echo [VAROITUS] CHM-käännös palautti virheen (hhc.exe palauttaa usein 1 vaikka onnistuu).
)

if exist "%OUTPUT_CHM_DIR%\BazzBasic.chm" (
    copy "%OUTPUT_CHM_DIR%\BazzBasic.chm" "%DIST_DIR%\BazzBasic-Manual.chm" >nul
    echo  [OK] CHM luotu: %DIST_DIR%\BazzBasic-Manual.chm
) else (
    echo [VIRHE] CHM-tiedostoa ei löydy.
)

:done
echo.
echo  Valmis.
echo  Tiedostot dist\-hakemistossa:
dir /b "%DIST_DIR%"
echo.
pause
