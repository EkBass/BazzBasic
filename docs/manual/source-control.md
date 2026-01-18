# Source Control

BassBasic allows you to use multiple files as your source code.  
This allows for decentralization in program structure design, which is a very convenient feature, especially with large programs.

## Loading the code

BazzBasic takes a single filename as a parameter and extracts the code contained there into tokens before executing the program.

## INCLUDE

- Code inherited from another file via INCLUDE is read at the exact point in the file where the INCLUDE is.
- Basically you could say, that the line where INCLUDE was called is replaced by the data from other file.

### test.bas

```basic
INCLUDE "test2.bas"
PRINT a$
```

### test2.bas
```basic
LET a$ = "Foo"
LET b$ = "Bar"
LET PI# = 3.14
```

### Result
BazzBasic reads these directly as a continuation of each other

```basic
LET a$ = "Foo"
LET b$ = "Bar"
LET PI# = 3.14
PRINT a$ ' Output: Foo
```