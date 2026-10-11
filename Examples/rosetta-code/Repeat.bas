' ============================================
' https://rosettacode.org/wiki/Repeat
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' BazzBasic functions (DEF FN) cannot take another function as an
' argument. A subroutine label can, however, be stored in a variable
' and called with GOSUB, which gives the same effect: [sub:Repeat]
' receives a procedure (proc$) and a count (times$) and calls it
' times$ times.

[inits]
    LET proc$  = ""
    LET times$ = 0
    LET i$     = 0

[main]
    proc$  = "[sub:Hello]"
    times$ = 3
    GOSUB [sub:Repeat]

    proc$  = "[sub:Goodbye]"
    times$ = 2
    GOSUB [sub:Repeat]
END

' Calls the subroutine named in proc$, times$ times
[sub:Repeat]
    FOR i$ = 1 TO times$
        GOSUB proc$
    NEXT
RETURN

[sub:Hello]
    PRINT "Hello"
RETURN

[sub:Goodbye]
    PRINT "Goodbye"
RETURN

' Output:
' Hello
' Hello
' Hello
' Goodbye
' Goodbye