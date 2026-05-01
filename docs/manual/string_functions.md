## String Functions

### ASC(s$)
Returns ASCII code of first character.
```vb
PRINT ASC("A")      ' Output: 65
PRINT ASC("Hello")  ' Output: 72 (H)
```

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

### SHA256(s$)
Creates SHA256 hash from a string
```vb
LET hash$ = SHA256("password123")
PRINT hash$                 ' ef92b778... (64-char lowercase hex)
```

### SPLIT(s$, a$, b$)
Splits string into array according to separator
```vb
DIM parts$
LET count$ = SPLIT(parts$, "apple,banana,orange", ",")
PRINT "Parts: "; count$
PRINT parts$(0)  ' "apple"
PRINT parts$(1)  ' "banana"
PRINT parts$(2)  ' "orange"
```

### SRAND(n)
Returns random string length of *n* from allowed chars.  
**Allowed chars:** *ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456780_*
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
