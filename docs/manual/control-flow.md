# Control Flow

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
IF ready$ = 1 THEN GOSUB [start_game]
```

## FOR Loops
**Note:** FOR auto-declares the loop variable — no LET needed.

### Basic FOR
```vb
FOR i$ = 1 TO 10
    PRINT i$
NEXT
```

### FOR with STEP
```vb
FOR i$ = 0 TO 100 STEP 10
    PRINT i$
NEXT
```

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
    RETURN
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
```

### Variables as GOTO/GOSUB targets
A variable or constant containing a label string can be used as a jump target:

```vb
LET foo$ = "[start]"
LET bar# = "[jump]"
GOTO foo$

[start]
PRINT "[start]"
GOSUB bar#
PRINT "Ending line"
END

[jump]
PRINT "[jump]"
RETURN
```

### Function Scope and Labels
Inside user-defined functions, GOTO and GOSUB can only jump to labels within the same function:

```vb
DEF FN test$(x$)
    [local_label]
    IF x$ < 10 THEN
        x$ = x$ + 1
        GOTO [local_label]    ' OK - within function
    END IF
    RETURN x$
END DEF

[outside]
' GOTO [outside] from inside the function above would cause an error
PRINT "Outside"
```

## END
Terminates program execution.

```vb
IF error$ THEN
    PRINT "Error occurred"
    END
END IF
PRINT "This runs if no error"
```

## SLEEP
Pause execution for specified milliseconds.

```vb
PRINT "Wait 2 seconds..."
SLEEP 2000
PRINT "Done!"
```

## See Also
- [Operators](operators.md) — comparison and logical operators
- [Input Functions](input_functions.md) — INKEY, KEYDOWN, WAITKEY
- [Statements A-Z](statements.md) — PRINT, INPUT, CLS, etc.
