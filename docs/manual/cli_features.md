# More Command Line Features

These options are for the interpreter, `bazzbasic.exe`.

## Overview

| Command | What it does |
|---------|--------------|
| `bazzbasic.exe` | Opens the IDE (`BazzBasic-IDE.exe` in the same folder). If the IDE is not there, shows the usage below. |
| `bazzbasic.exe file.bas [args...]` | Runs a program. Extra arguments are passed to the program. |
| `bazzbasic.exe -exe file.bas` | Creates a standalone executable. See [Creating EXE](packaging.md). |
| `bazzbasic.exe -lib file.bas` | Creates a library (`.bb`). See [Creating Libraries](libraries.md). |
| `bazzbasic.exe -v` | Shows the version. |
| `bazzbasic.exe -guide` | Shows a link to the Beginner's Guide. |
| `bazzbasic.exe -checkupdate` | Checks for a new release. |

After an error, `bazzbasic.exe` exits with code 1, so scripts and `.bat` files can detect it. A program that ends normally exits with code 0.

## Get a link to the BazzBasic Beginner's Guide

```
bazzbasic.exe -guide
```

**or**

```
bazzbasic.exe -help
```

## Get Version of Your Current BazzBasic

```
bazzbasic.exe -version
```

**or**

```
bazzbasic.exe -v
```

## Check For New Version Release

```
bazzbasic.exe -checkupdate
```

`-checkupdates` works too. The result is one of:

- a newer version is available, with a download link
- you are running the latest version
- you are running a version newer than the latest release (for example a build made from the source code)
