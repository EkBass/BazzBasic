# Installation

## Download binary
- Download BazzBasic binary from [Google Drive](https://drive.google.com/drive/folders/1vlOtfd6COIowDwRcK4IprBMPK1uCU3U7?usp=drive_link).
- Extract the _".zip"_ package to a folder of your choice.

## Firewall issues
Since BazzBasic is built around .NET 10 and it is still a fairly recent project, Windows Firewall or third-party security programs may give a warning about it the first time you use it.

However, by switching to the GitHub release and providing the correct metadata during the compilation phase, these warnings can be reduced in the future.

The truth is, however, that open source projects that use .NET platforms will always suffer from this problem to some extent.

## Run BazzBasic IDE
- Browse to folder where you extracted _bazzbasic.exe_
- Double-click _bazzbasic.exe_ and IDE opens.
- The integrated IDE which comes with BazzBasic is very basic and simple.

In order you to run your BazzBasic code with built-in IDE, you must save your file first and then press _F5_ to run it.

## Use external IDE
- BazzBasic syntax highlighting is also available for _notepad++_, _Geany_ and _Visual Studio Code_.
- Get config files for syntax support from [here](https://github.com/EkBass/BazzBasic/tree/main/extras).
- Adjust your editor to launch _bazzbasic.exe <filename.bas>_

## Use with terminal
- _bazzbasic.exe_ launches BazzBasic IDE
- _bazzbasic.exe <filename.bas>_ launches your BazzBasic code
- _bazzbasic.exe -exe <filename.bas>_ generates executable from _filename.bas_
- _bazzbasic.exe -lib <filename.bas> generates a tokenized library from _filename.bas_

## Source
- BazzBasic source code is released under **MIT license** and it is available at [github](https://github.com/EkBass/BazzBasic/tree/main)
- Repository is a _Visual Studio 2026_ project.