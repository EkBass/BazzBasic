' ============================================
' ROSETTA: https://rosettacode.org/wiki/Detect_division_by_zero
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Detects a division by zero (BazzBasic returns 0 instead of raising an error) and reports it for each of three test divisions.
' CATEGORY: math
' TAGS: division by zero, error detection, arithmetic
' MINVERSION: 1.5
' ============================================
' BazzBasic has no exceptions: x / 0 silently returns 0.
' A non-zero numerator divided by any non-zero number can never be 0,
' so a zero result from a non-zero numerator reveals division by zero
' without ever examining the denominator.
' Limitation: 0 / 0 also returns 0 and cannot be told apart from 0 / n.

DEF FN IsDivByZero$(num$, den$)
    LET q$ = num$ / den$
    IF q$ = 0 AND num$ <> 0 THEN RETURN TRUE
    RETURN FALSE
END DEF

[inits]
    DIM tests$
    tests$(0, 0) = 2 : tests$(0, 1) = 3
    tests$(1, 0) = 3 : tests$(1, 1) = 5
    tests$(2, 0) = 4 : tests$(2, 1) = 0

    LET a$ = 0
    LET b$ = 0

[main]
    FOR i$ = 0 TO ROWCOUNT(tests$()) - 1
        a$ = tests$(i$, 0)
        b$ = tests$(i$, 1)
        IF FN IsDivByZero$(a$, b$) THEN
            PRINT FSTRING("{{-a$-}} / {{-b$-}} : division by zero detected")
        ELSE
            PRINT FSTRING("{{-a$-}} / {{-b$-}} = "); a$ / b$
        END IF
    NEXT
END

' Output:
' 2 / 3 = 0.6666666666666666
' 3 / 5 = 0.6
' 4 / 0 : division by zero detected