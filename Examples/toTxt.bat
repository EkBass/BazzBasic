@echo off
setlocal

cd /d "%~dp0"

REM Luo txt-kansio varmasti
mkdir "%~dp0txt" 2>nul

for %%f in ("%~dp0*.bas") do (
echo Kopioidaan %%~nxf -> "%~dp0txt%%~nf.txt"
copy "%%f" "%~dp0txt%%~nf.txt" >nul
)

echo.
echo Valmis!
pause
