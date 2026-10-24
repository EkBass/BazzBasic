## Creating Standalone Executables

BazzBasic can package your BASIC program into a standalone .exe file.

### Usage

```
bazzbasic.exe -exe yourprogram.bas
```

This creates *yourprogram.exe* in the same folder as the .bas file. In the IDE, use **Run → Compile as Exe**.

### Size

The packaged exe is a copy of the BazzBasic interpreter with your program inside, so it is about **15 MB** regardless of how short your program is.

> Before version 1.6 the interpreter and the IDE were the same program, and packaged programs were about 111 MB. Since 1.6 the IDE is a separate program and is not included in your packaged exe.

### No .NET installation needed

The packaged exe contains the .NET runtime it needs. The target machine does not need .NET installed.

### Required Files for Distribution

| File | Required | Purpose |
|------|----------|---------|
| yourprogram.exe | Yes | Your packaged program |
| SDL2.dll | Yes | Graphics and input |
| SDL2_mixer.dll | If sound is used | Audio |
| SDL2_ttf.dll | If fonts are used | TrueType fonts |

`BazzBasic-IDE.exe` and the `runtimes` folder are **not** needed: they belong to the IDE only.

#### Your assets:

| File | Required | Purpose |
|------|----------|---------|
| *.png, *.bmp | If used | Image files |
| *.wav, *.mp3 | If used | Sound files |
| *.ttf | If used | Font files |

### Minimal Distribution

```
mygame/
├── yourprogram.exe
└── SDL2.dll
```

### Distribution with Assets recommendation

```
mygame/
├── yourprogram.exe
├── SDL2.dll
├── SDL2_mixer.dll
├── SDL2_ttf.dll
├── images/
│   ├── player.png
│   └── enemy.png
└── sounds/
    ├── shoot.wav
    └── music.mp3
```

### Where to Find SDL2.dll

**Binary download:**

The SDL2 dll files are in the same folder as __bazzbasic.exe__.

**If you build from the source:**

After running _build.bat_, they are in:

```
BazzBasic\bin\Release\net10.0-windows\win-x64\publish\
```

Copy them alongside your packaged exe.

### Console Window

The standalone exe runs with a console window visible. This is intentional for showing error messages.

### Notes

- The packaged exe contains the full BazzBasic interpreter, but not the IDE
- File paths in your BASIC code are relative to the exe location
- INCLUDE files are processed at packaging time (embedded in exe)
- After an error, the packaged exe exits with code 1
