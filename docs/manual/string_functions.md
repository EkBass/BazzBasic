## String Functions

### ASC(s$) / ASC(s$, pos)
Returns ASCII code of first character, or of the character at 1-based position `pos`.
```vb
PRINT ASC("A")         ' Output: 65
PRINT ASC("Hello")     ' Output: 72 (H)
PRINT ASC("Hello", 2)  ' Output: 101 (e)
PRINT ASC("Hello", 9)  ' Output: 0 (out of range)
```

`ASC(s$, pos)` gives the same result as `ASC(MID(s$, pos, 1))` but is faster, because no temporary substring is created. Use it when looping through a string character by character:
```vb
LET text$ = "Hello"
LET sum$ = 0
FOR i$ = 1 TO LEN(text$)
    sum$ += ASC(text$, i$)
NEXT
PRINT sum$             ' Output: 500
```

Out of range (`pos` less than 1 or greater than `LEN(s$)`) returns `0`, as does an empty string.

### BASE64DECODE(s$) & BASE64ENCODE(s$)
Decodes and encodes Base64
```vb
LET encoded$ = BASE64ENCODE("Hello, World!")
PRINT encoded$              ' SGVsbG8sIFdvcmxkIQ==

LET decoded$ = BASE64DECODE(encoded$)
PRINT decoded$              ' Hello, World!
```

### CHR(n)
Returns character for ASCII code.
```vb
PRINT CHR(65)      ' Output: A
PRINT CHR(10)      ' Output: (newline)
```

### FSTRING(template$)
String interpolation. Substitutes `{{-name-}}` placeholders inside the template with the value of variables, constants, or array elements. Whitespace inside placeholders is trimmed (so `{{- name$ -}}` works the same as `{{-name$-}}`). Numbers are auto-converted to strings.

**Placeholder forms:**
- `{{-var$-}}` — variable
- `{{-CONST#-}}` — constant
- `{{-arr$(0)-}}` — array element with numeric index
- `{{-arr$(i$)-}}` or `{{-arr$(KEY#)-}}` — array element where the index comes from a variable / constant (must end in `$` or `#`)
- `{{-arr$(name)-}}` — array element with literal string key (matches what was set via `arr$("name") = ...`)
- `{{-arr$(0, i$)-}}` — multidimensional, mixed literal and variable indices

**Notes:**
- No expressions, arithmetic, or function calls are allowed inside placeholders. Pre-compute into a variable first.
- A bare identifier without `$` / `#` suffix inside an array index is treated as a literal string key.
- Unknown variable, missing `-}}`, or empty placeholder halts execution with a line-numbered error.
- The literal sequence `{{-...-}}` is reserved — FSTRING will always try to resolve it.

```vb
LET name$ = "Krisu"
LET LEVEL# = 5
PRINT FSTRING("Hello {{-name$-}}, level {{-LEVEL#-}}")
' Output: Hello Krisu, level 5

DIM player$
    player$("name")  = "Krisu"
    player$("level") = 99
PRINT FSTRING("{{-player$(name)-}} is level {{-player$(level)-}}")
' Output: Krisu is level 99

DIM grid$
    grid$(0, 0) = "X"
    grid$(0, 1) = "O"
LET row$ = 0
PRINT FSTRING("[{{-grid$(row$, 0)-}}{{-grid$(row$, 1)-}}]")
' Output: [XO]
```

### INSTR(s$, search$) or INSTR(start, s$, search$)
Finds position of substring (1-based, 0 if not found).
```vb
' In default mode, INSTR is case-sensitive
 PRINT INSTR("Hello World", "World") ' returns 7
 PRINT INSTR("Hello World", "HELLO") ' returns 0
 
' Case-insensitive mode.
PRINT INSTR("Hello World", "world", 0) ' returns 7

' Case-sensitive mode, same as default mode
PRINT INSTR("Hello World", "world", 1) ' returns 0
```
Note: `=` ignores case between strings. To compare two strings exactly, use `SAME(a$, b$)` (below), see also [Comparing text](operators.md?id=comparing-text).

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

### REPLACE(s$, a$, b$)
Replaces a$ with b$ from s$
```vb
LET text$ = "Hello World"
LET result$ = REPLACE(text$, "World", "BazzBasic")
PRINT result$  ' "Hello BazzBasic"
```

### RIGHT(s$, n)
Returns last n characters.
```vb
PRINT RIGHT("Hello World", 5) ' Output: World
```

### RTRIM(s$)
Removes blank characters from the right of the text
```vb
LET a$ = "Foo     "
LET b$ = "Bar"
a$ = RTRIM(a$)
PRINT a$ + b$ ' Output: FooBar
```

### SAME(a$, b$)
Returns `1` if the two texts are identical, character for character and case included, otherwise `0`. Added in version 1.7.
```vb
PRINT SAME("Secret1", "Secret1")  ' Output: 1
PRINT SAME("Secret1", "secret1")  ' Output: 0
PRINT SAME("", "")                ' Output: 1
```
`=` ignores case, `SAME` does not, so use `SAME` for passwords, keys and IDs. `INPUT` and `LINE INPUT` always store text, so `SAME` compares exactly what was typed:
```vb
LET pass$ = "Secret1"
LINE INPUT "Password: ", input$
IF SAME(pass$, input$) THEN PRINT "Welcome" ELSE PRINT "Wrong password"
' User types: secret1
' Output: Wrong password
```
Numbers are compared in their text form: `SAME(1, "1")` is `1`, but `SAME("1.0", 1)` and `SAME(-0, 0)` are `0`. For numbers use `=`.

### SHA256(s$)
Creates SHA256 hash from a string
```vb
LET hash$ = SHA256("password123")
PRINT hash$                 ' ef92b778... (64-char lowercase hex)
```

### SPLIT(arr$, s$, sep$)
Splits string into array according to separator
```vb
DIM parts$
LET count$ = SPLIT(parts$, "apple,banana,orange", ",")
PRINT "Parts: "; count$
PRINT parts$(0)  ' "apple"
PRINT parts$(1)  ' "banana"
PRINT parts$(2)  ' "orange"
```
Returns the number of parts and stores them at keys `0` to `count - 1`. The array is emptied first, so splitting again into the same array leaves no old parts behind.

### SRAND(n)
Returns random string length of *n* from allowed chars.  
**Allowed chars:** *ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%&/{([)]=}?+-_* (81 characters, each equally likely)
```vb
PRINT SRAND(10)        ' Output example: noAR1S-Qw1
PRINT SRAND(0)         ' Output: (empty string, nothing printed)
PRINT LEN(SRAND(3.7))  ' Output: 3
PRINT SRAND(-1)        ' Error at line 4: SRAND: length must be 0 or more, got -1
```
`n` must be zero or more. The decimal part is dropped: `SRAND(3.7)` gives 3 characters. `SRAND(0)` returns an empty string. A negative `n` stops the program with an error, and so does a length too large for memory (`SRAND: length 2147483647 is too large`).

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

### UCASE(s$)
Converts to uppercase.
```vb
PRINT UCASE("Hello")  ' Output: HELLO
```

### VAL(s$)
Converts string to number.
```vb
LET n$ = VAL("42")
PRINT n$ + 8        ' Output: 50
```
