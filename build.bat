@echo off
rem Builds the interpreter (BazzBasic.exe) and the IDE (BazzBasic-IDE.exe)
rem into the same release folder.
cd /d "%~dp0"
set PUBLISH=bin\Release\net10.0-windows\win-x64\publish

echo === Interpreter: BazzBasic.exe (trimmed) ===
dotnet publish BazzBasic.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -o "%PUBLISH%"
if errorlevel 1 goto :fail

echo === IDE: BazzBasic-IDE.exe ===
dotnet publish IDE\BazzBasic-IDE.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -o "%PUBLISH%"
if errorlevel 1 goto :fail

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
