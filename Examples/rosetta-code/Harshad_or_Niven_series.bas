' ============================================
' https://rosettacode.org/wiki/Harshad_or_Niven_series
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' A Harshad (Niven) number is divisible by the sum of its digits.
' NextHarshad$(n) returns the first Harshad number greater than n,
' so calling it repeatedly walks the series.

DEF FN DigitSum$(n$)
    LET s$ = 0
    WHILE n$ > 0
        s$ += MOD(n$, 10)
        n$ = INT(n$ / 10)
    WEND
    RETURN s$
END DEF

DEF FN NextHarshad$(n$)
    n$ += 1
    WHILE MOD(n$, FN DigitSum$(n$)) <> 0
        n$ += 1
    WEND
    RETURN n$
END DEF

[inits]
    LET h$ = 0
    LET line$ = ""

[main]
    FOR i$ = 1 TO 20
        h$ = FN NextHarshad$(h$)
        line$ += h$ + " "
    NEXT
    PRINT "First 20 Harshad numbers:"
    PRINT TRIM(line$)
    PRINT ""
    PRINT "First Harshad number > 1000: "; FN NextHarshad$(1000)
END

' Output:
' First 20 Harshad numbers:
' 1 2 3 4 5 6 7 8 9 10 12 18 20 21 24 27 30 36 40 42
'
' First Harshad number > 1000: 1002
