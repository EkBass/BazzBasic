' BazzBasic version 1.4c
' https://rosettacode.org/wiki/Loops/Foreach
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' BazzBasic has no FOREACH statement. ARRKEY() returns the keys of an
' array in insertion order, so FOR + ARRKEY iterates over any collection
' (numeric or string keyed) in order, without knowing its indices.

[inits]
    DIM fruits$
        fruits$("a") = "Apple"
        fruits$("b") = "Banana"
        fruits$("c") = "Cherry"
        fruits$("d") = "Date"
        fruits$("e") = "Elderberry"

    LET key$ = ""

[main]
    FOR i$ = 0 TO LEN(fruits$()) - 1
        key$ = ARRKEY(fruits$(), i$)
        PRINT fruits$(key$)
    NEXT
END

' Output:
' Apple
' Banana
' Cherry
' Date
' Elderberry