' ============================================
' https://rosettacode.org/wiki/Binary_strings
' BazzBasic: https://github.com/EkBass/BazzBasic
' Task: demonstrate basic byte-string operations: creation,
'       assignment, comparison, copying, emptiness test, appending,
'       substrings, replacing and joining.
' ============================================

' Three-way string comparison
DEF FN Compare$(x$, y$)
    IF x$ < y$ THEN RETURN "less"
    IF x$ > y$ THEN RETURN "greater"
    RETURN "equal"
END DEF

' Hand-written alternative to the built-in REPLACE
DEF FN ReplaceAll$(src$, find$, repl$)
    IF find$ = "" THEN RETURN src$
    LET result$ = ""
    LET rest$ = src$
    LET at$ = INSTR(rest$, find$)
    WHILE at$ > 0
        result$ += LEFT(rest$, at$ - 1) + repl$
        rest$ = MID(rest$, at$ + LEN(find$))
        at$ = INSTR(rest$, find$)
    WEND
    RETURN result$ + rest$
END DEF

[inits]
    LET a$ = "One value"            ' creation and assignment
    LET b$ = "Other value"
    LET c$ = ""
    LET blank$ = ""
    LET foo$                        ' created, not initialized

[main]
    PRINT "a$ = "; a$
    PRINT "b$ = "; b$

    ' Comparison
    PRINT "a$ compared to b$: "; FN Compare$(a$, b$)
    PRINT "b$ compared to a$: "; FN Compare$(b$, a$)

    ' Cloning: b$ gets its own copy, so changing a$ leaves it alone
    b$ = a$
    PRINT "After b$ = a$:     "; FN Compare$(a$, b$)

    ' Appending a byte
    a$ += CHR(33)
    PRINT "After appending a byte: a$ = "; a$; ", b$ = "; b$

    ' Emptiness test
    IF a$ = "" THEN
        PRINT "a$ is empty"
    ELSE
        PRINT "a$ is not empty"
    END IF
    IF blank$ = "" THEN
        PRINT "blank$ is empty"
    ELSE
        PRINT "blank$ is not empty"
    END IF

    ' Substrings
    PRINT "LEFT(a$, 3)   = "; LEFT(a$, 3)
    PRINT "MID(a$, 5, 5) = "; MID(a$, 5, 5)
    PRINT "RIGHT(a$, 1)  = "; RIGHT(a$, 1)

    ' Replacing every occurrence
    PRINT "REPLACE       = "; REPLACE(a$, "e", "x")
    PRINT "ReplaceAll$   = "; FN ReplaceAll$(a$, "e", "x")

    ' Joining
    c$ = a$ + " and " + REPEAT("-", 10)
    PRINT "Joined: "; c$

    ' Destruction: there is no delete; emptying the variable releases
    ' its content and the .NET garbage collector reclaims the memory
    a$ = ""
END

' Output:
' a$ = One value
' b$ = Other value
' a$ compared to b$: less
' b$ compared to a$: greater
' After b$ = a$:     equal
' After appending a byte: a$ = One value!, b$ = One value
' a$ is not empty
' empty$ is empty
' LEFT(a$, 3)   = One
' MID(a$, 5, 5) = value
' RIGHT(a$, 1)  = !
' REPLACE       = Onx valux!
' ReplaceAll$   = Onx valux!
' Joined: One value! and ----------