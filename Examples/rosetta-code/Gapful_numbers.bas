' ============================================
' https://rosettacode.org/wiki/Gapful_numbers
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' A gapful number (>= 100) is evenly divisible by the
' number formed from its first and last decimal digits.

DEF FN IsGapful$(n$)
    IF n$ < 100 THEN RETURN FALSE
    LET first$ = n$
    WHILE first$ >= 10
        first$ = INT(first$ / 10)
    WEND
    IF MOD(n$, first$ * 10 + MOD(n$, 10)) = 0 THEN RETURN TRUE
    RETURN FALSE
END DEF

' Returns the first count$ gapful numbers >= start$ as one line
DEF FN GapfulLine$(start$, count$)
    LET n$ = start$
    LET found$ = 0
    LET line$ = ""
    WHILE found$ < count$
        IF FN IsGapful$(n$) THEN
            line$ += n$ + " "
            found$ += 1
        END IF
        n$ += 1
    WEND
    RETURN TRIM(line$)
END DEF

[main]
    PRINT "First 30 gapful numbers >= 100:"
    PRINT FN GapfulLine$(100, 30)
    PRINT ""
    PRINT "First 15 gapful numbers >= 1,000,000:"
    PRINT FN GapfulLine$(1000000, 15)
    PRINT ""
    PRINT "First 10 gapful numbers >= 1,000,000,000:"
    PRINT FN GapfulLine$(1000000000, 10)
END

' Output:
' First 30 gapful numbers >= 100:
' 100 105 108 110 120 121 130 132 135 140 143 150 154 160 165 170 176 180 187 190 192 195 198 200 220 225 231 240 242 253
'
' First 15 gapful numbers >= 1,000,000:
' 1000000 1000005 1000008 1000010 1000016 1000020 1000021 1000030 1000032 1000034 1000035 1000040 1000050 1000060 1000065
'
' First 10 gapful numbers >= 1,000,000,000:
' 1000000000 1000000001 1000000005 1000000008 1000000010 1000000016 1000000020 1000000027 1000000030 1000000032
