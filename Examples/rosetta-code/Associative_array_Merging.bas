' ============================================
' ROSETTA: https://rosettacode.org/wiki/Associative_array/Merging
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Merges a base and an update associative array into a new one, where update values win over base values, leaving both originals unchanged.
' CATEGORY: basics
' TAGS: associative arrays, join, arrkey, merging
' MINVERSION: 1.5
' ============================================
' Task: merge a base and an update associative array into a new
'       one, preferring update values, without mutating either.

[inits]
    DIM base$
    base$("name")  = "Rocket Skates"
    base$("price") = 12.75
    base$("color") = "yellow"

    DIM update$
    update$("price") = 15.25
    update$("color") = "red"
    update$("year")  = 1974

    DIM merged$
    LET key$ = ""

[main]
    ' JOIN writes into merged$; keys from update$ overwrite those from base$
    JOIN merged$, base$, update$

    FOR i$ = 0 TO LEN(merged$()) - 1
        key$ = ARRKEY(merged$(), i$)
        PRINT key$; " = "; merged$(key$)
    NEXT

    PRINT
    PRINT "Base price is still "; base$("price")
END

' Output:
' name = Rocket Skates
' price = 15.25
' color = red
' year = 1974
'
' Base price is still 12.75