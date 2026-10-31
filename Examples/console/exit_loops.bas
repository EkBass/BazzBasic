' ============================================
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Demonstrates EXIT WHILE and EXIT FOR for leaving loops early, with nine cases covering nesting, block IF and DEF FN.
' CATEGORY: basics
' TAGS: exit while, exit for, loops, break
' MINVERSION: 1.5
' ============================================

REM 1. EXIT WHILE from an endless loop
LET n$ = 0
WHILE 1
    n$ += 1
    IF n$ = 5 THEN EXIT WHILE
WEND
PRINT "1. WHILE stopped at "; n$; " (expect 5)"

REM 2. EXIT FOR keeps the loop variable
FOR i$ = 1 TO 100
    IF i$ * i$ > 50 THEN EXIT FOR
NEXT
PRINT "2. First square over 50: "; i$; " (expect 8)"

REM 3. EXIT inside a block IF
LET total$ = 0
FOR i$ = 1 TO 10
    IF i$ = 4 THEN
        PRINT "3. Leaving FOR from block IF at "; i$
        EXIT FOR
    END IF
    total$ += i$
NEXT
PRINT "3. Total: "; total$; " (expect 6)"

REM 4. Nested: EXIT FOR leaves only the inner loop
FOR a$ = 1 TO 3
    FOR b$ = 1 TO 3
        IF b$ = 2 THEN EXIT FOR
    NEXT
    PRINT "4. a="; a$; " b="; b$; " (expect b=2)"
NEXT

REM 5. EXIT WHILE from inside a FOR cleans up the FOR
LET rounds$ = 0
WHILE rounds$ < 100
    rounds$ += 1
    FOR k$ = 1 TO 10
        IF rounds$ = 3 AND k$ = 2 THEN EXIT WHILE
    NEXT
WEND
PRINT "5. Rounds: "; rounds$; " k="; k$; " (expect 3, 2)"

REM 6. A loop that contains EXIT but never uses it
LET c$ = 0
WHILE c$ < 3
    c$ += 1
    IF c$ = 99 THEN EXIT WHILE
WEND
PRINT "6. Count: "; c$; " (expect 3)"

REM 7. Skipped loop body that contains EXIT
LET z$ = 0
WHILE z$ > 0
    IF z$ THEN EXIT WHILE
    WHILE z$ > 1
        EXIT WHILE
    WEND
WEND
FOR q$ = 5 TO 1
    EXIT FOR
NEXT
PRINT "7. Skipped loops OK"

REM 8. EXIT inside DEF FN
DEF FN FirstDiv$(n$)
    FOR d$ = 2 TO n$
        IF n$ % d$ = 0 THEN EXIT FOR
    NEXT
    RETURN d$
END DEF
PRINT "8. Smallest divisor of 91: "; FN FirstDiv$(91); " (expect 7)"

REM 9. Game-loop style: thousands of exits, stacks must not grow
LET hits$ = 0
FOR frame$ = 1 TO 5000
    WHILE 1
        hits$ += 1
        EXIT WHILE
    WEND
NEXT
PRINT "9. Frames: "; hits$; " (expect 5000)"

PRINT "Done!"

LET wk$ = WAITKEY()
END
