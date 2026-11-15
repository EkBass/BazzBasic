' ============================================
' https://rosettacode.org/wiki/Jewels_and_stones
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

' Count how many characters of stones$ also appear in jewels$.
' Comparison must be case-sensitive: "z" is not a jewel for "Z".
DEF FN CountJewels$(stones$, jewels$)
    LET count$ = 0
    FOR i$ = 1 TO LEN(stones$)
        ' Mode 1 = case-sensitive (also the default, written out for clarity)
        IF INSTR(jewels$, MID(stones$, i$, 1), 1) > 0 THEN count$ += 1
    NEXT
    RETURN count$
END DEF

[main]
    PRINT FN CountJewels$("aAAbbbb", "aA")
    PRINT FN CountJewels$("ZZ", "z")
    PRINT FN CountJewels$("ABCDEFGHIJKLMNOPQRSTUVWXYZ@abcdefghijklmnopqrstuvwxyz", "ABCDEFGHIJKLMNOPQRSTUVWXYZ@abcdefghijklmnopqrstuvwxyz")
    PRINT FN CountJewels$("AB", "")
END

' Output:
' 3
' 0
' 53
' 0