# User Defined Functions

## Basic Syntax
**Note:** Name of user-defined function must have '$' as suffix


```basic
DEF FN functionName$(param1$, param2$, ...)
    ' Function body
    RETURN value
END DEF
```

## Simple Function

```basic
DEF FN double$(x$)
    RETURN x$ * 2
END DEF

PRINT FN double$(21)    ' Output: 42
PRINT FN double$(5)     ' Output: 10
```

## Multiple Parameters

```basic
DEF FN add$(a$, b$)
    RETURN a$ + b$
END DEF

DEF FN multiply$(a$, b$)
    RETURN a$ * b$
END DEF

PRINT FN add$(3, 4)         ' Output: 7
PRINT FN multiply$(3, 4)    ' Output: 12
```

## Array data as parameter
**Note:** You cant pass a whole array as a parameter. Instead, you need to pass values from it.

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

## String Functions

```basic
DEF FN greet$(name$)
    RETURN "Hello, " + name$ + "!"
END DEF

PRINT FN greet$("Alice")    ' Output: Hello, Alice!
```

## Functions with Logic

```basic
DEF FN max$(a$, b$)
    IF a$ > b$ THEN
        RETURN a$
    ELSE
        RETURN b$
    END IF
END DEF

DEF FN min$(a$, b$)
    IF a$ < b$ THEN
        RETURN a$
    ELSE
        RETURN b$
    END IF
END DEF

PRINT FN max$(10, 25)    ' Output: 25
PRINT FN min$(10, 25)    ' Output: 10
```

## Recursive Functions

Functions can call themselves:

```basic
DEF FN factorial$(n$)
    IF n$ <= 1 THEN
        RETURN 1
    END IF
    RETURN n$ * FN factorial$(n$ - 1)
END DEF

PRINT FN factorial$(5)    ' Output: 120
PRINT FN factorial$(10)   ' Output: 3628800
```

### Fibonacci

```basic
DEF FN fib$(n$)
    IF n$ <= 1 THEN
        RETURN n$
    END IF
    RETURN FN fib$(n$ - 1) + FN fib$(n$ - 2)
END DEF

FOR i$ = 0 TO 10
    PRINT FN fib$(i$); " ";
NEXT
' Output: 0 1 1 2 3 5 8 13 21 34 55
```

## Scope

User-defined functions have their own local scope that is completely isolated from the main program:

- Function parameters are local to the function
- Variables declared with `LET` inside a function are local to that function  
- Functions **cannot** access or modify global variables from the main program
- Parameters are passed **by value** - changes to parameters don't affect the original variables

```basic
LET b$ = 100              ' Global variable
LET C# = "Foo"            ' Global constant
DEF FN test$(a$)          ' Parameter a$ is local
    LET b$ = 2            ' Local b$ (separate from global b$)
    PRINT C#              ' Global constants are available
    a$ = a$ * b$          ' Uses local a$ (100) and local b$ (2)
    RETURN a$             ' Returns 200
END DEF
```

**In this example:**
- The global `b$` has value 100
- When calling `FN test(b$)`, the **value** 100 is passed to parameter `a$`
- Inside the function, a new **local** variable `b$` is created with value 2
- The local `b$` is completely separate from the global `b$`
- The function calculates `a$ * b$` = 100 × 2 = 200
- The global `b$` remains unchanged at 100


## Labels Inside Functions

Functions can have local labels for GOTO/GOSUB:

```basic
DEF FN countdown$(n$)
    [loop]
    IF n$ <= 0 THEN
        RETURN "Done!"
    END IF
    PRINT n$
    n$ = n$ - 1
    GOTO [loop]
END DEF

PRINT FN countdown$(5)
```

Output:
```
5
4
3
2
1
Done!
```

## Function Isolation

GOTO and GOSUB inside a function **cannot** jump outside the function:

```basic
[outside_label]
PRINT "Outside"

DEF FN broken$(x$)
    GOTO [outside_label]    ' ERROR!
    RETURN x$
END DEF
```

This produces: `GOTO cannot jump outside function: outside_label`

This restriction ensures functions are self-contained and predictable.

## Practical Examples

### Clamp Value

```basic
DEF FN clamp$(value$, minVal$, maxVal$)
    IF value$ < minVal$ THEN
        RETURN minVal$
    END IF
    IF value$ > maxVal$ THEN
        RETURN maxVal$
    END IF
    RETURN value$
END DEF

PRINT FN clamp$(150, 0, 100)   ' Output: 100
PRINT FN clamp$(-50, 0, 100)   ' Output: 0
PRINT FN clamp$(50, 0, 100)    ' Output: 50
```

### Distance Formula

```basic
DEF FN distance$(x1$, y1$, x2$, y2$)
    LET dx$ = x2$ - x1$
    LET dy$ = y2$ - y1$
    RETURN SQR(dx$ * dx$ + dy$ * dy$)
END DEF

PRINT FN distance$(0, 0, 3, 4)   ' Output: 5
```


### Is Even/Odd

```basic
DEF FN isEven$(n$)
    RETURN MOD(n$, 2) = 0
END DEF

DEF FN isOdd$(n$)
    RETURN MOD(n$, 2) = 1
END DEF

FOR i$ = 1 TO 5
    IF FN isEven$(i$) THEN
        PRINT i$; " is even"
    ELSE
        PRINT i$; " is odd"
    END IF
NEXT
```
## Order of code

Before code can call a user-created function, it must be loaded from the source code.

### Wrong
Code below causes error: _Error: Line 1: 'ADD' is not a valid variable name (must end with $ or #) or keyword_
```basic
' incorrect way
PRINT FN ADD$(1, 2)

DEF FN ADD($a$, b$)
	RETURN a$ + b$
END DEF
```

### Right
Code below is valid
```basic
' correct way
DEF FN ADD$(a$, b$)
	RETURN a$ + b$
END DEF

PRINT FN ADD$(1, 2)
```

## Tip

If you have several of your own functions, write them in their own file and include them in the code using _INCLUDE_ right at the beginning of your program.