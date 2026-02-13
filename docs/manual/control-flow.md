# Control Flow

## Sleep
Halts the program for _x_ milliseconds

```vb
PRINT "Wait 2 seconds..."
SLEEP 2000
PRINT "Done!"
```

## IF Statements

### Block IF
Multi-line conditional with THEN on its own:

```vb
IF score$ >= 90 THEN
    PRINT "Grade: A"
    PRINT "Excellent!"
END IF
```

### IF/ELSE
```vb
IF age$ >= 18 THEN
    PRINT "Adult"
ELSE
    PRINT "Minor"
END IF
```

### IF/ELSEIF/ELSE
```vb
IF score$ >= 90 THEN
    PRINT "A"
ELSEIF score$ >= 80 THEN
    PRINT "B"
ELSEIF score$ >= 70 THEN
    PRINT "C"
ELSEIF score$ >= 60 THEN
    PRINT "D"
ELSE
    PRINT "F"
END IF
```

### One-line IF
Jump to label based on condition:

```vb
IF lives$ = 0 THEN GOTO [game_over]
IF key$ = KEY_ESC# THEN GOTO [menu] ELSE GOTO [continue]
```

With GOSUB:
```vb
IF ready$ = 1 THEN GOSUB [start_game]
```

## Comparison Operators
| Operator | Meaning |
|----------|---------|
| `=` or `==` | Equal |
| `<>` or `!=` | Not equal |
| `<` | Less than |
| `>` | Greater than |
| `<=` | Less than or equal |
| `>=` | Greater than or equal |

## Logical Operators
```vb
IF age$ >= 18 AND age$ <= 65 THEN
    PRINT "Working age"
END IF

IF day$ = "Saturday" OR day$ = "Sunday" THEN
    PRINT "Weekend!"
END IF

IF NOT gameOver$ THEN
    PRINT "Keep playing"
END IF
```

## FOR Loops
**Note:** FOR can initialize variable itself, without LET

### Basic FOR
```vb
FOR i$ = 1 TO 10
    PRINT i$
NEXT
```

Output: 1 2 3 4 5 6 7 8 9 10

### FOR with STEP
```vb
FOR i$ = 0 TO 100 STEP 10
    PRINT i$
NEXT
```

Output: 0 10 20 30 40 50 60 70 80 90 100

### Counting Down
```vb
FOR i$ = 10 TO 1 STEP -1
    PRINT i$
NEXT
PRINT "Liftoff!"
```

### Nested FOR
```vb
FOR row$ = 1 TO 3
    FOR col$ = 1 TO 3
        PRINT row$; ","; col$; " ";
    NEXT
    PRINT ""
NEXT
```

## WHILE Loops
Repeat while condition is true:
```vb
LET count$ = 0
WHILE count$ < 5
    PRINT count$
    count$ = count$ + 1
WEND
```

Output: 0 1 2 3 4

### Infinite Loop with Exit Condition
```vb
WHILE 1
    LET key$ = INKEY
    IF key$ = KEY_ESC# THEN GOTO [exit]
    ' Game logic here
WEND

[exit]
PRINT "Goodbye"
```

## Labels and GOTO
Labels are marked with square brackets:

```vb
[start]
    PRINT "Starting..."
    GOTO [main]

[main]
    PRINT "Main section"
    GOTO [end]

[end]
    PRINT "Done"
    END
```

## GOSUB and RETURN
Call a subroutine and return:

```vb
PRINT "Before subroutine"
GOSUB [greet]
PRINT "After subroutine"
END

[greet]
    PRINT "Hello!"
    PRINT "Nice to meet you!"
    RETURN
```

Output:
```
Before subroutine
Hello!
Nice to meet you!
After subroutine
```

### Nested GOSUB
```vb
GOSUB [level1]
END

[level1]
    PRINT "Level 1"
    GOSUB [level2]
    PRINT "Back to Level 1"
    RETURN

[level2]
    PRINT "Level 2"
    RETURN
    
' Output:
' Level 1
' Level 2
' Back to Level 1
```

### Variables as GOTO/GOSUB pointers
**Note:** A variable can be used to indicate the location of the jump.

```vb
LET foo$ = "[start]"
LET bar# = "[jump]"
GOTO foo$

PRINT "Line we never see".

[start]
PRINT "[start]"
GOSUB bar#

PRINT "Ending line"
END 

[jump]
PRINT "[jump]"
RETURN
```

```text
[start]
[jump]
Ending line
```

### Function Scope Isolation
Inside user-defined functions, GOTO and GOSUB can only jump to labels within the same function:

```vb
' GOTO cannot jump outside function
DEF FN test$(x$)
    [local_label]
    IF x$ < 10 THEN
        x$ = x$ + 1
        GOTO [local_label]    ' OK - within function
    END IF
    RETURN x$
END DEF

[outside] ' GOTO [outside] from inside function would cause ERROR:
PRINT "Outside"
```

## Using Key Constants
```vb
[game_loop]
    LET key$ = INKEY
    
    IF key$ = KEY_ESC# THEN END
    IF key$ = KEY_UP# THEN y$ = y$ - 1
    IF key$ = KEY_DOWN# THEN y$ = y$ + 1
    IF key$ = KEY_LEFT# THEN x$ = x$ - 1
    IF key$ = KEY_RIGHT# THEN x$ = x$ + 1
    IF key$ = KEY_SPACE# THEN GOSUB [fire]
    
    GOTO [game_loop]
```

## END Statement
Terminates program execution:

```vb
IF error$ THEN
    PRINT "Error occurred"
    END
END IF
PRINT "This runs if no error"
```