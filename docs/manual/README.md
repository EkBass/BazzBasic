# BazzBasic

BazzBasic is a BASIC interpreter built to work with the .NET10 Framework.

It supports many of the features of BASIC interpreters from the 80s, but also offers something modern.

## Source or binary

See source at [GitHub](https://github.com/EkBass/BazzBasic) or download binary from [Google Drive](https://drive.google.com/drive/folders/1vlOtfd6COIowDwRcK4IprBMPK1uCU3U7?usp=sharing)

## Main functionalities

### User-Defined Functions

With or without recursion.

```basic
DEF FN factorial$(n$) 
	IF n$ <= 1 THEN 
		RETURN 1 
	END IF 
	RETURN n$ * FN factorial$(n$ - 1)
END DEF

PRINT FN factorial$(5) ' Output: 120
PRINT FN factorial$(10) ' Output: 3628800
```

### SDL2 Graphics

BazzBasic offers a reasonable sampling of SDL2 features.

If your program uses graphic features, SDL2.dll must be in the same directory. This does not apply to console-only programs.

See [Graphics Commands](graphics.md)

### Sounds

BazzBasic includes a sound system built on SDL2_mixer, supporting audio playback with both background and blocking modes.

See [Sound Commands](sounds.md)

### Source Control

With the INCLUDE function, you can split the source code into different files and folders or generate tokenized libraries.

See [Preprocessor](preprocessor.md) or [Generating libraries](libraries.md)

### Arrays

BazzBasic arrays are fully dynamic and support numeric, string, or mixed indexing.

See [Arrays](arrays.md)

### Typeless Variables and Constants

Variables automatically hold either numbers or strings:

```basic
LET num$ = 42            ' Number
LET text$ = "Hello"      ' String
LET mixed$ = "123"       ' String (quoted)
```

See [Variables & Constants](variables-and-constants.md)

## Getting Started

- [Installation](installation.md)
- [IDE Usage](ide-usage.md)
- [Hello World Tutorial](tutorial-hello-world.md)

## More Resources

- [Example programs on GitHub](https://github.com/EkBass/BazzBasic/tree/main/Examples)
- [BazzBasic Homepage](https://ekbass.github.io/BazzBasic/)

## BazzBasic size

Currently BazzBasic requires about 70 megabytes + SDL2.dll

_PublishTrimmed=true_ would halve its size, but thorough testing is needed first.

BazzBasic includes .NET 10 assemblies during compilation, which contributes to the file size.
