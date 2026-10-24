' ============================================
' https://rosettacode.org/wiki/Loops/Break
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

' Print a random number 0..19. If it is 10, stop the loop.
' Otherwise print a second random number and start over.
' EXIT WHILE leaves the loop at once and continues after WEND.

[main]
    WHILE TRUE
        LET a$ = RND(20)
        PRINT a$;
        IF a$ = 10 THEN EXIT WHILE
        PRINT "  "; RND(20)
    WEND
    PRINT ""
END

' Output (random, for example):
' 3  17
' 12  0
' 7  19
' 10
