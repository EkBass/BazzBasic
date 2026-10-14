' ============================================
' https://rosettacode.org/wiki/Hailstone_sequence
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' [sub:hailstone] builds the full sequence for n$ into seq$.
' HailLength$ only counts the steps - used for the big search,
' where storing 100,000 sequences would be wasted work.

DEF FN HailLength$(n$)
    LET count$ = 1
    WHILE n$ <> 1
        IF MOD(n$, 2) = 0 THEN
            n$ = n$ / 2
        ELSE
            n$ = 3 * n$ + 1
        END IF
        count$ += 1
    WEND
    RETURN count$
END DEF

[inits]
    LET LIMIT# = 100000
    DIM seq$
    LET n$ = 0
    LET size$ = 0
    LET len$ = 0
    LET best$ = 0
    LET bestLen$ = 0

[main]
    n$ = 27
    GOSUB [sub:hailstone]
    PRINT FSTRING("Hailstone sequence for 27 has {{-size$-}} elements:")
    PRINT seq$(0); ", "; seq$(1); ", "; seq$(2); ", "; seq$(3); ", ... , ";
    PRINT seq$(size$ - 4); ", "; seq$(size$ - 3); ", "; seq$(size$ - 2); ", "; seq$(size$ - 1)
    PRINT ""

    FOR i$ = 1 TO LIMIT# - 1
        len$ = FN HailLength$(i$)
        IF len$ > bestLen$ THEN
            best$ = i$
            bestLen$ = len$
        END IF
    NEXT
    PRINT FSTRING("Longest sequence below 100,000: {{-best$-}}, with {{-bestLen$-}} elements")
END

' Fills seq$(0..size$-1) with the hailstone sequence of n$
[sub:hailstone]
    DELARRAY seq$
    DIM seq$
    size$ = 0
    seq$(size$) = n$
    WHILE n$ <> 1
        IF MOD(n$, 2) = 0 THEN
            n$ = n$ / 2
        ELSE
            n$ = 3 * n$ + 1
        END IF
        size$ += 1
        seq$(size$) = n$
    WEND
    size$ += 1
RETURN

' Output:
' Hailstone sequence for 27 has 112 elements:
' 27, 82, 41, 124, ... , 8, 4, 2, 1
'
' Longest sequence below 100,000: 77031, with 351 elements
