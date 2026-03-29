' ============================================
' https://rosettacode.org/wiki/Undefined_values
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

' In BazzBasic, a variable declared with LET but given no value
' holds an empty/zero state and prints as blank.
' Referencing a variable that was never declared at all produces
' a runtime error, clearly identifying it as undefined.

[inits]
    LET ok$
    LET okToo$ = "Ok too"

[main]
    PRINT "ok$: "; ok$
    PRINT "okToo$: "; okToo$
    PRINT "error$: "; error$
END

' Output:
' ok$:
' okToo$: Ok too
' Error at line 11: Undefined variable: ERROR$
' error$: 0
