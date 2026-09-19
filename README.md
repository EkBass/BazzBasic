# ABOUT
BazzBasic is built around one simple idea: starting programming should feel nice and even fun.

Ease of learning, comfort of exploration and small but important moments of success. Just like the classic BASICs of decades past, but with a fresh and modern feel.

It's easy to get started with and offers a rewarding experience with little effort. Simple syntax, modern features, and you'll be creating your first little game in a couple of evenings — hours perhaps.

Check [this few lines long example game](https://github.com/EkBass/BazzBasic/blob/main/Examples/graphics/Egg_Catcher.bas) to see it yourself!

## Development
BazzBasic is released under the [open source MIT license](https://github.com/EkBass/BazzBasic/blob/main/LICENSE.txt).

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

### SDL2 Graphics & sounds
BazzBasic offers a reasonable sampling of SDL2 features.

If your program uses graphic features, SDL2.dll must be in the same directory. This does not apply to console-only programs.

See [Graphics Commands](https://ekbass.github.io/BazzBasic/manual/#/graphics)

BazzBasic includes a sound system built on SDL2_mixer, supporting audio playback with both background and blocking modes.

See [Sound Commands](https://ekbass.github.io/BazzBasic/manual/#/sounds)

### Source Control
With the INCLUDE function, you can split the source code into different files and folders or generate tokenized libraries.

See [Preprocessor](https://ekbass.github.io/BazzBasic/manual/#/preprocessor) or [Generating libraries](https://ekbass.github.io/BazzBasic/manual/#/libraries)

### Data types
Unlike many traditional BASIC interpreters, which required strong typing and often separated different data types with suffixes such as *$* or *%*, BazzBasic copes smoothly with untyped data.

#### Typeless Variables and Constants
Variables automatically hold either numbers or strings:

```vb
LET num$ = 42            ' Number
LET text$ = "Hello"      ' String
LET mixed$ = "123"       ' String (quoted)
```
See [Variables & Constants](https://ekbass.github.io/BazzBasic/manual/#/variables-and-constants)

#### Arrays
BazzBasic arrays are fully dynamic and support numeric, string, or mixed indexing.

```basic
DIM MyArray$
MyArray$("name") = "John Smith"
MyArray$("age") = 42
```
See [Arrays & JSON](https://ekbass.github.io/BazzBasic/manual/#/arrays_and_json)

## Getting Started

- [Installation](https://ekbass.github.io/BazzBasic/manual/#/installation)
- [IDE Usage](https://ekbass.github.io/BazzBasic/manual/#/ide-usage)
- [Beginners Guide](https://ekbass.github.io/BazzBasic/manual/#/beginners-guide)

## More Resources
- [Rosetta Code examples](https://ekbass.github.io/BazzBasic/manual/#/rosetta-code)
- [Show & Tell discussion forum](https://github.com/EkBass/BazzBasic/discussions/categories/show-and-tell)
- [BazzBasic Cookbook](https://bbcookbook.miraheze.org/wiki/Main_Page)
- [BazzBasic Example codes](https://github.com/EkBass/BazzBasic/tree/main/Examples)
- [BazzBasic AI-guide](https://huggingface.co/datasets/EkBass/BazzBasic_AI_Guide)

## BazzBasic size
Currently, BazzBasic requires about 70 megabytes + SDL2.dll

_PublishTrimmed=true_ would reduce its size, but thorough testing is needed first.

BazzBasic includes .NET 10 assemblies during compilation, which affects the file size.

.NET 10, although a bit bulky, still offers compatibility far into the future.,
