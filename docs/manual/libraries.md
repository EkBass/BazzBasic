# Creating Libraries

BazzBasic supports pre-compiled libraries (`.bb` files) for code reuse. Libraries contain tokenized functions that load faster than source files and use automatic namespace prefixes to prevent naming conflicts.

## What is a Library?

A library is a collection of user-defined functions compiled into a binary format. When you create a library:
- Source code is tokenized (converted to internal format)
- Function names get a prefix based on the filename
- The result is saved as a `.bb` file

## Creating a Library

### Step 1: Write your library source

Libraries can only contain `DEF FN` functions. No variables, constants, or executable code outside functions.

```vb
REM MathLib.bas - A simple math library

DEF FN add$(x$, y$)
  RETURN x$ + y$
END DEF

DEF FN multiply$(x$, y$)
  RETURN x$ * y$
END DEF
```

### Step 2: Compile the library

```
bazzbasic.exe -lib MathLib.bas
```

Output:
```
Created library: MathLib.bb
Library name: MATHLIB
Size: {size} bytes
```

The library name is derived from the filename (uppercase, without extension).

## Using a Library

Include the library and call library functions with the `FN` keyword using the library prefix:

```vb
INCLUDE "MathLib.bb"

[inits]
	LET a$ = 5
	LET b$ = 3

[main]
	PRINT "5 + 3 = "; FN MATHLIB_add$(a$, b$)
	PRINT "5 * 3 = "; FN MATHLIB_multiply$(a$, b$)
END
```

Output:
```
5 + 3 = 8
5 * 3 = 15
```

## Naming Convention

| Source file       | Library name  | Function prefix  |
|-------------------|---------------|------------------|
| MathLib.bas       | MATHLIB.bb       | MATHLIB_         |
| StringUtils.bas   | STRINGUTILS.bb   | STRINGUTILS_     |
| MyGame.bas        | MYGAME.bb        | MYGAME_          |

Original function `add$()` becomes `MATHLIB_add$()` when compiled from MathLib.bas.

## Accessing Main Program Constants

Libraries cannot define constants, but library functions can access constants defined in the main program:

```vb
INCLUDE "Utils.bb"

[inits]
	LET APP_NAME# = "MyApp"
	LET APP_VERSION# = "1.0"

[main]
	PRINT FN UTILS_getAppInfo$()   ' Can use APP_NAME# and APP_VERSION#
END
```

```vb
REM Utils.bas - Library source
DEF FN getAppInfo$()
  RETURN APP_NAME# + " v" + APP_VERSION#
END DEF
```

## Library Rules

- **Functions only** — Libraries cannot contain variables, constants, or loose code
- **Automatic prefix** — All functions get the library name as prefix
- **No conflicts** — Multiple libraries can have functions with the same base name
- **Binary format** — `.bb` files are not human-readable
- **Constant access** — Library functions can read constants from the main program

## Error Handling

**Invalid library content:**
```
bazzbasic.exe -lib BadLib.bas
Library validation failed: Line 5: Libraries can only contain DEF FN functions. Found: TOK_LET
```

**Library not found:**
```
Error: Line 1: Library not found: missing.bb
```

## Benefits of Libraries

- **Faster loading** — Pre-tokenized code loads instantly
- **No name conflicts** — Automatic prefixes prevent collisions
- **Code organization** — Separate reusable code from main program
- **Smaller files** — Binary format is typically 30–50% smaller than source for larger files

> **Note:** For small files with only a few functions, the `.bas` file may be smaller than the tokenized `.bb` file due to metadata overhead. The size advantage shifts to the tokenized format as file size grows.

## Distributing Libraries

When distributing your program with libraries:

```
MyGame/
├── MyGame.exe  (or MyGame.bas)
├── MathLib.bb
├── StringLib.bb
└── SDL2.dll
```

Libraries must be in the same directory as the main program, or in a path relative to it.
