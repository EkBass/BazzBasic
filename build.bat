@echo off
rem Builds the interpreter (BazzBasic.exe) and the IDE (BazzBasic-IDE.exe)
rem into the same release folder.
cd /d "%~dp0"
set PUBLISH=bin\Release\net10.0-windows\win-x64\publish
set LIBS=bin\Release\net10.0-windows\win-x64\publish\libs

echo === Interpreter: BazzBasic.exe (trimmed) ===
dotnet publish BazzBasic.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -o "%PUBLISH%"
if errorlevel 1 goto :fail

echo === IDE: BazzBasic-IDE.exe ===
dotnet publish IDE\BazzBasic-IDE.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -o "%PUBLISH%"
if errorlevel 1 goto :fail

rem SDL*.dll kopioidaan LIBS kansioon tässä kohtaa
rem ne ovat samassa hakemistossa kuin tämä batch
rem if not exist "%LIBS%" mkdir "%LIBS%"
rem echo Kopioidaan SDL-kirjastot...
rem copy /y "%~dp0SDL*.dll" "%LIBS%" >nul

rem Copy the newest exes to the local install used by bb.bat (PATH) and the AI agents.
rem A failed copy (e.g. IDE open, exe locked) is only a warning, not a build failure.
set LOCAL_BB=C:\Users\ekvir\BazzBasic
echo === Copy to %LOCAL_BB% ===
copy /y "%PUBLISH%\BazzBasic.exe" "%LOCAL_BB%\" >nul || echo   WARNING: BazzBasic.exe not copied ^(in use?^)
copy /y "%PUBLISH%\BazzBasic-IDE.exe" "%LOCAL_BB%\" >nul || echo   WARNING: BazzBasic-IDE.exe not copied ^(in use?^)

echo.
echo Build OK: %PUBLISH%
dir /b "%PUBLISH%"
pause
exit /b 0

:fail
echo.
echo *** BUILD FAILED ***
pause
exit /b 1