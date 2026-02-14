# Variables & Constants
- Variables store values that can change during program execution.
- Constants store value that can not be changed during execution

## Declaration
- Variables and constants must be initialized with `LET` before they can be used
- BazzBasic variables are not typed, but work the same way as in JavaScript, for example.
- A variable needs the suffix **$**
- A constant needs the suffix **#**

## Variables
```vb
' Basic init for variables
LET a$ = "Foo"
PRINT a$ ' Output: "Foo"
LET b$ = 1
PRINT b$ ' Output: 1
LET c$ = 1 + 2
PRINT c$ ' Output: 3
```

## Constants
```vb
' Basic init for constants'
LET PI# = 3.14159
LET MAX_PLAYERS# = 4
LET GAME_TITLE# = "Space Invaders"
```

## LET only when init
```vb
' Once variable is initialized, you do not need LET anymore
LET a$ = 1
a$ = 3
PRINT a$ ' Output: 3
```

## Unsigned data type
```vb
' Variable stores either a number or a text.
' It is ok to change the type of data.
LET a$ = 1
PRINT a$ ' Output: 1
a$ = "Foo"
PRINT a$ ' Output: Foo
```

## Versatile usage
```vb
' Math with variables and multiple inits in single line
LET a$ = 1, b$ = 2
LET c$ = a$ + b$
LET MyConst# = c$ * b$
```

## Error situation examples
```vb
' Some errors
a$ = 1 ' error: a$ not initialized

LET b# = 1
b# = b# + 3 ' error: Constant b# had value 1 when initialized, not allowed to change anymore
```

## Init with out a value
```vb
' If you want just to init var and not give value yet
LET a$ ' declares variable
a$ = 1 ' inits value 1 to variable

LET b# ' works, but is a bit stupid since now b# is constant with value of nothing
```

## Exceptions

### FOR and INPUT
When a variable is introduced with a `FOR...NEXT` or `INPUT` command, it does not need to be initialized with `LET`:
```vb
REM Ok to use without prior LET
INPUT "What is your name? ", name$

FOR i$ = 1 TO 10
    PRINT i$
NEXT
```

## Comparing variables
A comparison is true if:
- two string variables are equal
- two number variables are equal
- the value of the number in the string variable is the same as the number variable

```vb
LET a$, b$
a$ = "123"              ' a$ has now value "123"
b$ = 123                ' b$ has now value 123
LET c$ = "321"          ' c$ is now "321"

' Output of this IF...THEN: Same
IF a$ = b$ then
	print "Same"
ELSE
	print "Different"
ENDIF

' Output of this IF...THEN: Different
IF a$ = c$ then
	print "Same"
ELSE
	print "Different"
ENDIF

c$ = 123
' Output of this IF...THEN: Same
IF c$ = b$ then
	print "Same"
ELSE
	print "Different"
ENDIF
```

**Note:** Although 123 and "123" produce TRUE in an IF...THEN comparison, it is best to keep numeric variables as numeric and string variables as string.

A comparison between a numeric and string variable is only made if the data type of the variable contents is not the same. This slows down the comparison process if it is done significantly.

## Built-in Constants
BazzBasic provides a full range of automatically initialized constants

**Keyboard:**

## Built-in Constants

### Arrow Keys
| | | |
|---|---|---|
| `KEY_UP#` | `KEY_DOWN#` | `KEY_LEFT#` |
| `KEY_RIGHT#` | | |

### Special Keys
| | | |
|---|---|---|
| `KEY_ESC#` | `KEY_TAB#` | `KEY_BACKSPACE#` |
| `KEY_ENTER#` | `KEY_SPACE#` | `KEY_INSERT#` |
| `KEY_DELETE#` | `KEY_HOME#` | `KEY_END#` |
| `KEY_PGUP#` | `KEY_PGDN#` | |

### Modifier Keys
| | | |
|---|---|---|
| `KEY_LSHIFT#` | `KEY_RSHIFT#` | `KEY_LCTRL#` |
| `KEY_RCTRL#` | `KEY_LALT#` | `KEY_RALT#` |
| `KEY_LWIN#` | `KEY_RWIN#` | |

### Function Keys
| | | |
|---|---|---|
| `KEY_F1#` | `KEY_F2#` | `KEY_F3#` |
| `KEY_F4#` | `KEY_F5#` | `KEY_F6#` |
| `KEY_F7#` | `KEY_F8#` | `KEY_F9#` |
| `KEY_F10#` | `KEY_F11#` | `KEY_F12#` |

### Numpad Keys
| | | |
|---|---|---|
| `KEY_NUMPAD0#` | `KEY_NUMPAD1#` | `KEY_NUMPAD2#` |
| `KEY_NUMPAD3#` | `KEY_NUMPAD4#` | `KEY_NUMPAD5#` |
| `KEY_NUMPAD6#` | `KEY_NUMPAD7#` | `KEY_NUMPAD8#` |
| `KEY_NUMPAD9#` | | |

### Punctuation Keys
| | | |
|---|---|---|
| `KEY_COMMA#` | `KEY_DOT#` | `KEY_MINUS#` |
| `KEY_EQUALS#` | `KEY_SLASH#` | `KEY_BACKSLASH#` |
| `KEY_SEP#` | `KEY_GRAVE#` | `KEY_LBRACKET#` |
| `KEY_RBRACKET#` | | |

### Alphabet Keys
| | | |
|---|---|---|
| `KEY_A#` | `KEY_B#` | `KEY_C#` |
| `KEY_D#` | `KEY_E#` | `KEY_F#` |
| `KEY_G#` | `KEY_H#` | `KEY_I#` |
| `KEY_J#` | `KEY_K#` | `KEY_L#` |
| `KEY_M#` | `KEY_N#` | `KEY_O#` |
| `KEY_P#` | `KEY_Q#` | `KEY_R#` |
| `KEY_S#` | `KEY_T#` | `KEY_U#` |
| `KEY_V#` | `KEY_W#` | `KEY_X#` |
| `KEY_Y#` | `KEY_Z#` | |

### Number Keys
| | | |
|---|---|---|
| `KEY_0#` | `KEY_1#` | `KEY_2#` |
| `KEY_3#` | `KEY_4#` | `KEY_5#` |
| `KEY_6#` | `KEY_7#` | `KEY_8#` |
| `KEY_9#` | | |


**Mouse:**
### Mouse
| | | |
|---|---|---|
| `MOUSE_LEFT#` | `MOUSE_RIGHT#` | `MOUSE_MIDDLE#` |

> **Note:** `MOUSE_MIDDLE#` detects button press only, not scroll wheel.


**Example:**
```vb
[loop]
    LET key$ = INKEY
    IF key$ = KEY_ESC# THEN END
    IF key$ = KEY_UP# THEN PRINT "Up pressed!"
    SLEEP 15
GOTO [loop]
```

## Naming Rules
1. Must end with `$` (variable) or `#` (constant)
2. Can contain letters, numbers, and underscores
3. Cannot start with a number
4. Case-insensitive

### Valid names:
```vb
LET score$
LET player1_name$
LET MAX_VALUE#
LET x$
```

### Invalid names:
```vb
LET score       ' Missing suffix
LET 1player$    ' Starts with number
```

## Errors
In case of error, BazzBasic stops with proper error message.
```vb
LET a$ = 100 ' ok
b$ = 200     ' Error at line 2: Undefined variable: B$ (use LET for first assignment)
```

## Scope
Variables initialized within the main code belong to the same scope.
```vb
IF 1 = 1 THEN
    LET x$ = 10
END IF
PRINT x$                 ' Output: 10 (x$ is still accessible)
```

- Variables initialized and modified in user-defined functions do not belong to the same scope.
- However, global constants are available.

```vb
LET a$ = 1
LET b$ = 100              ' Global variable
LET C# = "Foo"            ' Global constant

DEF FN test$(a$)           ' Local parameter a$ is initialized here
    LET b$ = 2             ' Local b$ (separate from global b$)
    PRINT b$               ' Output: 2
    PRINT C#               ' Output: Foo
    a$ = a$ * b$           ' Uses local a$ (100) and local b$ (2)
    RETURN a$              ' Returns 200
END DEF

PRINT FN test$(b$)         ' Output: 200
PRINT a$                   ' Output: 1
PRINT b$                   ' Output: 100
```