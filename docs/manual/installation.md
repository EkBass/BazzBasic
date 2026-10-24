# Installation

## Download binary
- Download BazzBasic binary from [GitHub Releases](https://github.com/EkBass/BazzBasic/releases).
- Extract the _".zip"_ package to a folder of your choice.

## What's in the package

| File | What it is |
|------|------------|
| _BazzBasic.exe_ | The interpreter. Runs and compiles your `.bas` files. Used from the command line, from other editors and by the IDE. |
| _BazzBasic-IDE.exe_ | The BazzBasic code editor (IDE). |
| _SDL2.dll_, _SDL2_mixer.dll_, _SDL2_ttf.dll_ | Graphics, sound and fonts. Needed by the interpreter. |
| _runtimes\win-x64\native\_ | _Scintilla.dll_ and _Lexilla.dll_. Needed by the IDE. |
| _Examples_, _extras_ | Example programs and syntax highlighting files for other editors. |

Keep the files together in the same folder.

> **Since version 1.6** the IDE and the interpreter are two separate programs. Earlier, _BazzBasic.exe_ was both. Nothing changes in how you use them: double-clicking _BazzBasic.exe_ still opens the IDE, and all commands work as before.

If you only use another editor or the command line, you can leave out _BazzBasic-IDE.exe_ and the _runtimes_ folder.

## Firewall issues
Since BazzBasic is built around .NET 10 and it is still a fairly recent project, Windows Firewall or third-party security programs may give a warning about it the first time you use it.

However, by switching to the GitHub release and providing the correct metadata during the compilation phase, these warnings can be reduced in the future.

The truth is, however, that open source projects that use .NET platforms will always suffer from this problem to some extent.

## Run BazzBasic IDE
- Browse to folder where you extracted BazzBasic.
- Double-click _BazzBasic-IDE.exe_. Double-clicking _BazzBasic.exe_ opens the IDE too.
- The IDE which comes with BazzBasic is very basic and simple.

In order you to run your BazzBasic code with the IDE, you must save your file first and then press _F5_ to run it.

The IDE runs your programs with _BazzBasic.exe_ from its own folder. See [IDE Usage](ide-usage.md) for how to use another copy.

## Use external IDE
- BazzBasic syntax highlighting is also available for _notepad++_, _Geany_ and _Visual Studio Code_.
- Get config files for syntax support from [here](https://github.com/EkBass/BazzBasic/tree/main/extras).
- Adjust your editor to launch _bazzbasic.exe <filename.bas>_

## Use with terminal
- _bazzbasic.exe_ without arguments opens the IDE (_BazzBasic-IDE.exe_ in the same folder). If the IDE is not there, it shows the command line usage.
- _bazzbasic.exe <filename.bas>_ runs your BazzBasic code
- _bazzbasic.exe -exe <filename.bas>_ generates an executable from _filename.bas_
- _bazzbasic.exe -lib <filename.bas>_ generates a tokenized library from _filename.bas_
- More options: [More CLI features](cli_features.md)

## Source
- BazzBasic source code is released under **MIT license** and it is available at [github](https://github.com/EkBass/BazzBasic/tree/main)
- Repository is a _Visual Studio 2026_ solution with two projects: _BazzBasic.csproj_ (interpreter) and _IDE\BazzBasic-IDE.csproj_ (IDE).
- _build.bat_ builds both into _bin\Release\net10.0-windows\win-x64\publish_.
