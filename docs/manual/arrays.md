# Arrays

Arrays store collections of values. BazzBasic arrays are fully dynamic and support numeric, string, or mixed indexing.

- Arrays store values that can change during program execution.
- All array names must end with `$`.

## Initialization

- Arrays must be initialized with `DIM` before they can be used
- BazzBasic arrays are not typed, but work the same way as in JavaScript, for example.
- An array needs the suffix '$'.

```basic
DIM scores$
DIM names$
DIM matrix$
```

Multiple declarations:

```basic
DIM a$, b$, c$
```

## Numeric Indexing

Use numbers as indices (0-based):

```basic
DIM scores$
scores$(0) = 95
scores$(1) = 87
scores$(2) = 92

PRINT scores$(0)         ' Output: 95
```

## String Indexing (Associative Arrays)

Use strings as keys:

```basic
DIM player$
player$("name") = "Alice"
player$("score") = 1500
player$("level") = 3

PRINT player$("name")    ' Output: Alice
```

## Multi-dimensional Arrays

Use multiple indices separated by commas:

```basic
DIM matrix$
matrix$(0, 0) = "A1"
matrix$(0, 1) = "A2"
matrix$(1, 0) = "B1"
matrix$(1, 1) = "B2"

PRINT matrix$(1, 0)      ' Output: B1
```

## Mixed Indexing

Combine numeric and string indices:

```basic
DIM data$
data$(1, "header") = "Name"
data$(1, "value") = "Alice"
data$(2, "header") = "Age"
data$(2, "value") = 30

PRINT data$(1, "value")  ' Output: Alice
```

## Array Functions

### LEN

Returns the number of elements in an array:

```basic
DIM items$
items$(0) = "apple"
items$(1) = "banana"
items$(2) = "cherry"

PRINT LEN(items$())      ' Output: 3
```

Note the empty parentheses `()` after the array name.

### HASKEY

Returns 1 if the key exists, 0 otherwise:

```basic
DIM config$
config$("debug") = 1

IF HASKEY(config$("debug")) THEN
    PRINT "Debug mode is set"
END IF

IF HASKEY(config$("verbose")) = 0 THEN
    PRINT "Verbose not set"
END IF
```

### DELKEY

Removes an element from the array:

```basic
DIM cache$
cache$("temp") = "value"
PRINT HASKEY(cache$("temp"))  ' Output: 1

DELKEY cache$("temp")
PRINT HASKEY(cache$("temp"))  ' Output: 0
```

### DELARRAY

Removes the entire array and all its elements:

```basic
DIM arr$
arr$("name") = "Test"
arr$(0) = "Zero"

PRINT LEN(arr$())             ' Output: 2

DELARRAY arr$

' Array no longer exists, can be re-declared
DIM arr$
PRINT LEN(arr$())             ' Output: 0
```

## Practical Examples

### Pass values to user-defined functions

Arrays cannot be passed directly to functions. Instead, pass individual elements as values:

```basic
DIM a$
a$("name") = "Foo"
a$("age") = 19
a$(1) = 1

DEF FN func$(a$, b$, c$)
    PRINT a$
    PRINT b$
    PRINT c$
    RETURN 0
END DEF

LET b$ = FN func$(a$("name"), a$("age"), a$(1))
' Output:
' Foo
' 19
' 1
```

### Simple List

```basic
DIM fruits$
LET count$ = 0

fruits$(count$) = "Apple"
count$ = count$ + 1
fruits$(count$) = "Banana"
count$ = count$ + 1
fruits$(count$) = "Cherry"
count$ = count$ + 1

FOR i$ = 0 TO count$ - 1
    PRINT fruits$(i$)
NEXT
```

### Dictionary / Map

```basic
DIM translations$
translations$("hello") = "hei"
translations$("goodbye") = "nakemiin"
translations$("thanks") = "kiitos"

INPUT "English word: ", word$
IF HASKEY(translations$(word$)) THEN
    PRINT "Finnish: "; translations$(word$)
ELSE
    PRINT "Translation not found"
END IF
```

### 2D Grid

```basic
DIM grid$

' Initialize 3x3 grid
FOR row$ = 0 TO 2
    FOR col$ = 0 TO 2
        grid$(row$, col$) = "."
    NEXT
NEXT

' Place some markers
grid$(0, 0) = "X"
grid$(1, 1) = "O"
grid$(2, 2) = "X"

' Print grid
FOR row$ = 0 TO 2
    FOR col$ = 0 TO 2
        PRINT grid$(row$, col$); " ";
    NEXT
    PRINT ""
NEXT
```

Output:
```
X . .
. O .
. . X
```

## Error Handling

### Array Not Declared

```basic
scores$(0) = 95
' ERROR: Array not declared, use DIM first: scores$
```

### Element Not Initialized

```basic
DIM data$
PRINT data$(0)
' ERROR: Array element data$(0) not initialized
```

Always check with `HASKEY` or initialize elements before reading.
