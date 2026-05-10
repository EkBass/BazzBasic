# BazzBasic
BazzBasic is a BASIC interpreter built to work with the [.NET10](https://dotnet.microsoft.com/en-us) Framework.

It supports many of the features of [BASIC interpreters](https://en.wikipedia.org/wiki/BASIC_interpreter) from the 80s, but also offers something modern.


## Development
So far, [EkBass](https://github.com/EkBass) has been responsible for the development of BazzBasic.

BazzBasic is released under the [open source MIT license](https://github.com/EkBass/BazzBasic/blob/main/LICENSE.txt).

Its source code is available and visible to everyone in the project's [GitHub repository](https://github.com/EkBass/BazzBasic).

Currently, the development work is done in the Windows 11 operating system, but with quite a bit of effort it can also be translated to Linux or MacOS.

## Main functionalities
Most familiar BASIC features work either completely or almost completely as users of traditional BASIC languages ​​are used to using them.


### User-Defined Functions
With or without recursion.

```vb
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

### Data types
Unlike many traditional BASIC interpreters, which required strong typing and often separated different data types with suffixes such as *$* or *%*, BazzBasic copes smoothly with untyped data.

#### Typeless Variables and Constants
Variables automatically hold either numbers or strings:

```vb
LET num$ = 42            ' Number
LET text$ = "Hello"      ' String
LET mixed$ = "123"       ' String (quoted)
```
See [Variables & Constants](variables-and-constants.md)

#### Arrays
BazzBasic arrays are fully dynamic and support numeric, string, or mixed indexing.

```basic
DIM MyArray$
MyArray$("name") = "John Smith"
MyArray$("age") = 42
```
See [Arrays](arrays.md)

## Getting Started

- [Installation](installation.md)
- [IDE Usage](ide-usage.md)
- [Hello World Tutorial](tutorial-hello-world.md)

## More Resources
- [Example programs on GitHub](https://github.com/EkBass/BazzBasic/tree/main/Examples)
- [BazzBasic Homepage](https://ekbass.github.io/BazzBasic/)

## BazzBasic size
Currently, BazzBasic requires about 70 megabytes + SDL2.dll

_PublishTrimmed=true_ would reduce its size, but thorough testing is needed first.

BazzBasic includes .NET 10 assemblies during compilation, which affects the file size.

.NET 10, although a bit bulky, still offers compatibility far into the future.,
