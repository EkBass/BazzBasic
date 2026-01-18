## Creating Standalone Executables

BazzBasic can package your BASIC program into a standalone .exe file.

### Usage

```
bazzbasic.exe -exe yourprogram.bas
```

This creates `yourprogram.exe` in the same folder as the .bas file.

### Example

```
bazzbasic.exe -exe C:\Games\mygame.bas
```

Creates: `C:\Games\mygame.exe`

### Required Files for Distribution

The standalone exe needs only one additional file:

| File | Required | Purpose |
|------|----------|---------|
| yourprogram.exe | Yes | Your packaged program |
| SDL2.dll | Yes | Graphics and input |

NAudio (sound library) is bundled inside BazzBasic.exe, so no additional DLLs are needed for sound.

#### Your assets:

| File | Required | Purpose |
|------|----------|---------|
| *.png, *.bmp | If used | Image files |
| *.wav, *.mp3 | If used | Sound files |

### Minimal Distribution

```
mygame/
├── mygame.exe
└── SDL2.dll
```

### Distribution with Assets recommendation

```
mygame/
├── mygame.exe
├── SDL2.dll
├── images/
│   ├── player.png
│   └── enemy.png
└── sounds/
    ├── shoot.wav
    └── music.mp3
```

### Where to Find SDL2.dll

After building BazzBasic, SDL2.dll is in:

```
BazzBasic\bin\Debug\net10.0-windows\
```

Or after publishing:

```
BazzBasic\bin\Release\net10.0-windows\publish\
```

Copy SDL2.dll alongside your packaged exe.

### Console Window

The standalone exe runs with a console window visible. This is intentional for showing error messages.  
A feature with what to hide console is coming on version 0.7

### Notes

- The packaged exe contains the full BazzBasic interpreter
- File paths in your BASIC code are relative to the exe location
- INCLUDE files are processed at packaging time (embedded in exe)

### .NET Runtime Requirement

The packaged exe inherits the same runtime requirements as the BazzBasic.exe used to create it:

- **If using release build**: Target machine needs .NET 10 runtime
- **If using self-contained publish**: No runtime needed (larger file size)

To create a fully self-contained BazzBasic for packaging:

```
dotnet publish -c Release -r win-x64 --self-contained true
```

Then use that published BazzBasic.exe for packaging your programs.
