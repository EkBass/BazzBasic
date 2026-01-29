## Math Functions


### ABS(n)
Returns the absolute value.
```vb
PRINT ABS(1.5)	' 1.5
PRINT ABS(-1.5)	' 1.5
```


### ATAN(n)
Returns the arc tangent of a number
```vb
PRINT ATAN(1.5)	' 0.982793723247329
PRINT ATAN(-1.5)	' -0.982793723247329
```


### CINT(n)
The Cint function converts an expression to type Integer.
```vb
PRINT CINT(3.7)      ' Output: 4
PRINT CINT(3.3)		' Output: 3
PRINT CINT(-3.7)     ' Output: -4
```


### CEIL(n)
Returns the smallest integer that is greater than or equal to a given number
```vb
PRINT CEIL(3.7)      ' Output: 4
PRINT CEIL(3.3)		' Output: 4
PRINT CEIL(-3.7)     ' Output: -3
```


### COS(n)
Returns the cosine of an angle
```vb
PRINT COS(0)    ' Output: 1
PRINT COS(45)	' Output 0.5253219888177297
PRINT COS(90)   ' Output: -0.4480736161291701
```


### EXP(n)
Exponential (e^n).
```vb
PRINT EXP(1)        ' Output: 2.718...
PRINT EXP(0)        ' Output: 1
```


### FLOOR(n)
Rounds down and returns the largest integer
```vb
PRINT FLOOR(1.1)      ' Output: 1
PRINT FLOOR(1.95)       ' Output: 1
PRINT FLOOR(300)       ' Output: 300
```


### INT(n)
Returns the integer part (truncates toward zero).
```vb
PRINT INT(3.7)     ' Output: 3
PRINT INT(-3.7)    ' Output: -3
```


### LOG(n)
Natural logarithm (base e).
```vb
PRINT LOG(2.718)    ' Output: 0.999896315728952
```


### MAX(n, n)
Return higher one from two numbers
```vb
LET A# = 1
LET A$ = 9.8
PRINT MAX(A#, A$)    ' Output: 9.8
```


### MIN(n, n)
Return smaller one from two numbers
```vb
LET A# = 1
LET A$ = 9.8
PRINT MIN(A#, A$)    ' Output: 1
```


### MOD(n, n)
Return modulus (remainder) of the two numbers
```vb
PRINT MOD(10, 3)    ' Output: 1
PRINT MOD(100, 20)	' Output: 0
```


### POW(n, n)
Return a number raised to the power of another number
```vb
PRINT POW(3, 3)    	' Output: 27
PRINT POW(2, 2)		' Output: 4
```


### RND(n)
Returns a random integer from 0 to n-1.
```vb
PRINT RND(10)      ' Output: 0-9
PRINT RND(100)     ' Output: 0-99

' Random number between 1 and 6 (dice roll)
LET dice$ = RND(6) + 1
```


### ROUND(n)
Rounds a number according to standard rules
```vb
PRINT ROUND(1.1)    ' Output: 1
PRINT ROUND(1.5)	   ' Output: 2
PRINT ROUND(1.9)    ' Output: 2
```


### SGN(n)
Returns the sign: -1, 0, or 1.
```vb
PRINT SGN(-5)      ' Output: -1
PRINT SGN(0)       ' Output: 0
PRINT SGN(5)       ' Output: 1
```


### SIN(n)
Returns the sine of a number
```vb
PRINT SIN(-5)      ' Output: 0.9589242746631385
PRINT SIN(0)       ' Output: 0
PRINT SIN(5)       ' Output: -0.9589242746631385
```


### SQR(n)
Returns the square root.
```vb
PRINT SQR(0)      ' Output: 0
PRINT SQR(5)       ' Output: 2.23606797749979
PRINT SQR(9)       ' Output: 3
```


### TAN(n)
Returns the tangent of the given angle
```vb
PRINT TAN(0)      ' Output: 0
PRINT TAN(5)       ' Output: -3.380515006246586
PRINT TAN(9)       ' Output: -0.45231565944180985
```


## String Functions


### ASC(s$)
Returns ASCII code of first character.
```vb
PRINT ASC("A")      ' Output: 65
PRINT ASC("Hello")  ' Output: 72 (H)
```


### CHR(n)
Returns character for ASCII code.
```vb
PRINT CHR(65)      ' Output: A
PRINT CHR(10)      ' Output: (newline)
```


### INSTR(s$, search$) or INSTR(start, s$, search$)
Finds position of substring (1-based, 0 if not found).
```vb
PRINT INSTR("Hello World", "World")    ' Output: 7
PRINT INSTR("Hello World", "xyz")      ' Output: 0
PRINT INSTR(8, "Hello World", "o")     ' Output: 8
```


### INVERT(s$)
Inverts a string
```vb
PRINT INVERT("Hello World")      ' Output: dlroW olleH
```


### LCASE(s$)
Converts to lowercase.
```vb
PRINT LCASE("Hello")  ' Output: hello
```


### LEFT(s$, n)
Returns first n characters.
```vb
PRINT LEFT("Hello World", 5)  ' Output: Hello
```


### LEN(s$)
Returns string length.
```vb
PRINT LEN("Hello")  ' Output: 5
PRINT LEN("")       ' Output: 0
```


### LTRIM(s$)
Removes blank characters from the left of the text
```vb
PRINT LTRIM("        Hello World") ' Output: Hello World
```


### MID(s$, start) or MID(s$, start, length)
Returns substring starting at position (1-based).
```vb
PRINT MID("Hello World", 7)     ' Output: World
PRINT MID("Hello World", 7, 3)  ' Output: Wor
PRINT MID("Hello World", 1, 5)  ' Output: Hello
```


### REPEAT(s$, n)
Repeats the text requested times
```vb
LET a$ = REPEAT("Foo", 10)
PRINT a$ ' Output: FooFooFooFooFooFooFooFooFooFoo
```


### REPLACE(s$,a$, b$)
Replaces a$ with b$ from s$
```vb
LET text$ = "Hello World"
LET result$ = REPLACE(text$, "World", "BazzBasic")
PRINT result$  ' "Hello BazzBasic"
```


### RIGHT(s$, n)
Returns last n characters.
```vb
PRINT RIGHT$("Hello World", 5) ' Output: World
```


### RTRIM(s$)
Removes blank characters from the right of the text
```vb
LET a$ = "Foo     "
LET b$ = "Bar"
a$ = RTRIM(a$)
PRINT a$ + b$ ' Output: FooBar
```


### SPLIT(s$, a$, b$)
Splits string in to array according seperator
```vb
DIM parts$
REM Split with ","
LET count$ = SPLIT(parts$, "apple,banana,orange", ",")
PRINT "Parts: "; count$
PRINT parts$(0)  ' "apple"
PRINT parts$(1)  ' "banana"
PRINT parts$(2)  ' "orange"
```


### SRAND(n)
Returns random string lenght of <n> from allowed chars.
**Allowed chars:**  *ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456780_*
```vb
PRINT SRAND(10)  ' Output example: noAR1S-Qw1
```


### STR(n)
Converts number to string.
```vb
LET s$ = STR(42)
PRINT "Value: " + s$  ' Output: Value: 42
```


### TRIM(s$)
Removes blank characters from start and end of text
```vb
LET a$ = "    Foo     "
LET b$ = "    Bar     "
a$ = TRIM(a$)
b$ = TRIM(b$)
PRINT a$ + b$ ' Output: FooBar
```


### UCASE$(s$)
Converts to uppercase.
```vb
PRINT UCASE$("Hello")  ' Output: HELLO
```


### VAL(s$)
Converts string to number.
```vb
LET n$ = VAL("42")
PRINT n$ + 8        ' Output: 50
```


## Array Functions


### LEN(array$())
Returns number of elements in array.
```vb
DIM items$
items$(0) = "a"
items$(1) = "b"
items$(2) = "c"
PRINT LEN(items$())  ' Output: 3
```


### HASKEY(array$(key))
Returns 1 if key exists, 0 otherwise.
```vb
DIM data$
data$("name") = "Alice"

PRINT HASKEY(data$("name"))   ' Output: 1
PRINT HASKEY(data$("age"))    ' Output: 0
```


### DELKEY - Remove Element
Removes an element from the array:

```vb
DIM cache$
cache$("temp") = "value"
PRINT HASKEY(cache$("temp"))  ' Output: 1

DELKEY cache$("temp")
PRINT HASKEY(cache$("temp"))  ' Output: 0
```


### DELARRAY - Remove Entire Array
Removes the entire array and all its elements:
```vb
DIM arr$
arr$("name") = "Test"
arr$(0) = "Zero"

PRINT LEN(arr$())             ' Output: 2

DELARRAY arr$

' Array no longer exists, can be re-declared
DIM arr$
PRINT LEN(arr$())             ' Output: 0
```


## Input Functions


### INKEY
Returns current key press (non-blocking). Returns 0 if no key pressed.
```vb
[loop]
    LET k$ = INKEY
    IF k$ = 0 THEN GOTO [loop]
    IF k$ = KEY_ESC# THEN END
    PRINT "Key code: "; k$
    GOTO [loop]
```


Special keys return values > 256:
- Arrow keys: KEY_UP#, KEY_DOWN#, KEY_LEFT#, KEY_RIGHT#
- Function keys: KEY_F1# through KEY_F12#


### MOUSEX, MOUSEY
**Note: Only available when graphics screen is open.**

Returns mouse cursor position.
```vb
SCREEN 12
[loop]
    LOCATE 1, 1
    PRINT "X:"; MOUSEX; " Y:"; MOUSEY; "   "
    GOTO [loop]
```


### MOUSEB
**Note: Only available when graphics screen is open.**

Returns mouse button state (bitmask).
```vb
' MOUSE_LEFT# = 1, MOUSE_RIGHT# = 2, MOUSE_MIDDLE# = 4
LET buttons$ = MOUSEB
IF buttons$ AND MOUSE_LEFT# THEN PRINT "Left clicked"
IF buttons$ AND MOUSE_RIGHT# THEN PRINT "Right clicked"
```


## Color Functions


### RGB(r, g, b)

Creates a color value from red, green, and blue components.

**Parameters:**
- `r` - Red component (0-255)
- `g` - Green component (0-255)
- `b` - Blue component (0-255)

**Returns:** A combined color value for use with graphics commands.

```vb
LET red$ = RGB(255, 0, 0)
LET green$ = RGB(0, 255, 0)
LET blue$ = RGB(0, 0, 255)
LET white$ = RGB(255, 255, 255)
LET black$ = RGB(0, 0, 0)
LET purple$ = RGB(128, 0, 128)

' Use with graphics commands
PSET 100, 100, RGB(255, 128, 0)   ' Orange pixel
LINE (0, 0)-(100, 100), RGB(0, 255, 0)  ' Green line
CIRCLE 200, 200, 50, RGB(255, 0, 0)     ' Red circle
```

**Tip:** Store frequently used colors in constants for better performance:

```vb
LET COLOR_PLAYER# = RGB(0, 128, 255)
LET COLOR_ENEMY# = RGB(255, 64, 64)
LET COLOR_BACKGROUND# = RGB(32, 32, 48)
```


## Logical Values


### TRUE, FALSE
Boolean constants.
```vb
LET gameOver$ = FALSE

WHILE NOT gameOver$
    ' game loop
    IF lives$ = 0 THEN gameOver$ = TRUE
WEND
```


## Time Functions


### TIME(format$)
Returns current date/time as a formatted string. Uses .NET DateTime format strings.

```vb
PRINT TIME()                ' Default: "16:30:45"
PRINT TIME("HH:mm:ss")      ' "16:30:45"
PRINT TIME("dd.MM.yyyy")    ' "09.01.2026"
PRINT TIME("yyyy-MM-dd")    ' "2026-01-09"
PRINT TIME("dddd")          ' "Friday"
PRINT TIME("MMMM")          ' "January"
PRINT TIME("dd MMMM yyyy")  ' "09 January 2026"
PRINT TIME("HH:mm")         ' "16:30"
```

**Common format codes:**

| Code | Description | Example | 
|------|-------------|--------| 
| HH | Hour (00-23) | 16 | 
| mm | Minutes | 30 | 
| ss | Seconds | 45 | 
| dd | Day | 09 | 
| MM | Month (number) | 01 | 
| MMM | Month (short) | Jan | 
| MMMM | Month (full) | January | 
| yy | Year (2 digits) | 26 | 
| yyyy | Year (4 digits) | 2026 | 
| ddd | Weekday (short) | Fri | 
| dddd | Weekday (full) | Friday | 


### TICKS
Returns milliseconds elapsed since program started. Useful for timing, animations, and game loops.

```vb
LET start$ = TICKS

' Do some work
FOR i$ = 1 TO 10000
    LET x$ = x$ + 1
NEXT

LET elapsed$ = TICKS - start$
PRINT "Time taken: "; elapsed$; " ms"
```

**Game loop timing example:**
```vb
SCREEN 12
LET lastFrame$ = TICKS
LET frameTime# = 16  ' ~60 FPS

[gameloop]
    LET now$ = TICKS
    IF now$ - lastFrame$ >= frameTime# THEN
        ' Update game logic here
        lastFrame$ = now$
    ENDIF
    
    IF INKEY = KEY_ESC# THEN END
    GOTO [gameloop]
```
