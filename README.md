# BazzBasic

BazzBasic is a BASIC interpreter built to work with the .NET10 Framework.

It supports many of the features of BASIC interpreters from the 80s, but also offers something modern.

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

### SDL2

BazzBasic already offers a reasonable sampling of SDL2 features and I intend to add more.

[Graphics-Documentation](https://github.com/EkBass/BazzBasic/wiki/h.-Graphics-Documentation)

### Sounds

BazzBasic includes a comprehensive sound system built on NAudio, supporting audio playback with both background and blocking modes.

[Sounds](https://github.com/EkBass/BazzBasic/wiki/l.-Sounds)


### Source Control

With the INCLUDE function, you can split the source code into different files and folders.

[Source-Control](https://github.com/EkBass/BazzBasic/wiki/a.-Source-Control)

### Arrays

BazzBasic arrays are fully dynamic and support numeric, string, or mixed indexing.

[Arrays](https://github.com/EkBass/BazzBasic/wiki/c.-Arrays)

### Typeless variables and Constants
Variables automatically hold either numbers or strings:

```basic
LET num$ = 42            ' Number
LET text$ = "Hello"      ' String
LET mixed$ = "123"       ' String (quoted)
```
[Variables-and-Constants9(https://github.com/EkBass/BazzBasic/wiki/b.-Variables-and-Constants)

### Tons of classic and modern BASIC features.

Have a look at the [wiki](https://github.com/EkBass/BazzBasic/wiki)
