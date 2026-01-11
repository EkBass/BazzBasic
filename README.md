# BazzBasic

BazzBasic is a BASIC interpreter built to work with the .NET10 Framework.

It supports many of the features of BASIC interpreters from the 80s, but also offers something modern.

## About

BazzBasic is my vision of how to achieve the same feelings today as I did long ago when I was writing hundreds of lines of code on a Spectravideo 328.

BazzBasic does not allow line numbers, which I think is a bit outdated ways of programming, but it allows [label] tags, which make the familiar GOTO and GOSUB successful.  
This is my view, not a call to argue.

### Version

**Updated:** 9th Jan 2026  
**Current version:** 0.4  
**Platform:** win x64  
**Zip archive size:** 31.7Mb  
**License:** MIT  
_Binary file includes ALL dependencies except SDL2_

### Source or binary

See source at [github](https://github.com/EkBass/BazzBasic) or download binary from [Google Drive](https://drive.google.com/drive/folders/1vlOtfd6COIowDwRcK4IprBMPK1uCU3U7?usp=sharing)

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

If your BazzBasic program uses graphic features, the SDL2.dll file must be in the same directory.  
This does not apply to programs running on the console.  
[Graphics-Documentation](https://github.com/EkBass/BazzBasic/wiki/h.-Graphics-Documentation)

### Sounds

BazzBasic includes a comprehensive sound system built on NAudio, supporting audio playback with both background and blocking modes.

[Sounds](https://github.com/EkBass/BazzBasic/wiki/l.-Sounds)


### Source Control

With the INCLUDE function, you can split the source code into different files and folders.

[Source-Control](https://github.com/EkBass/BazzBasic/wiki/a.-Source-Controll)

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
[Variables-and-Constants](https://github.com/EkBass/BazzBasic/wiki/b.-Variables-and-Constants)

### Tons of classic and modern BASIC features.

Have a look at the [wiki](https://github.com/EkBass/BazzBasic/wiki) or study [example programs](https://github.com/EkBass/BazzBasic/tree/main/Examples)

# BazzBasic

BazzBasic is a BASIC interpreter built to work with the .NET10 Framework.

It supports many of the features of BASIC interpreters from the 80s, but also offers something modern.

### Version

**Updated:** 5th Jan 2026  
**Current version:** 0.4  
**Platform:** win x64  
**Zip archive size:** 31.7Mb  
**License:** MIT  
_Binary file includes ALL dependencies_

### Source or binary

See source at [github](https://github.com/EkBass/BazzBasic) or download binary from [Google Drive](https://drive.google.com/drive/folders/1vlOtfd6COIowDwRcK4IprBMPK1uCU3U7?usp=sharing)

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

If your BazzBasic program uses graphic features, the SDL2.dll file must be in the same directory.  
This does not apply to programs running on the console.  
[Graphics-Documentation](https://github.com/EkBass/BazzBasic/wiki/h.-Graphics-Documentation)

### Sounds

BazzBasic includes a comprehensive sound system built on NAudio, supporting audio playback with both background and blocking modes.

[Sounds](https://github.com/EkBass/BazzBasic/wiki/l.-Sounds)


### Source Control

With the INCLUDE function, you can split the source code into different files and folders.

[Source-Control](https://github.com/EkBass/BazzBasic/wiki/a.-Source-Controll)

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
[Variables-and-Constants](https://github.com/EkBass/BazzBasic/wiki/b.-Variables-and-Constants)

### Tons of classic and modern BASIC features.

Have a look at the [wiki](https://github.com/EkBass/BazzBasic/wiki) or study [example programs](https://github.com/EkBass/BazzBasic/tree/main/Examples)

## BazzBasic size

Currently BazzBasic requires about 70 megabytes + SDL2.dll

_PublishTrimmed=true_ would halve its size, but I won't do it before thorough testing.

It's good to note that BazzBasic includes .NET 10 assemblies during compilation, and even when trimmed, this easily makes the finished BazzBasic interpreter a few tens of megabytes.
