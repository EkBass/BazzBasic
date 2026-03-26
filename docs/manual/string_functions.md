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
