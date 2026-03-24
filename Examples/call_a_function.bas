' ============================================
' https://rosettacode.org/wiki/Call_a_function
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
DEF FN add$(a$, b$)
    RETURN a$ + b$
END DEF

DEF FN ReturnHello$()
    RETURN "This is ReturnHello"
END DEF

[init]
    LET mySub$ = "[sub:subHello]"

[main]
    PRINT FN add$(5, RND(10) + 1)
    PRINT FN ReturnHello$()
    GOSUB mySub$
    GOSUB [sub:subHello]
END

[sub:subHello]
    PRINT "This is subHello"
RETURN
