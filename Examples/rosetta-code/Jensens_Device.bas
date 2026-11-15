' ============================================
' https://rosettacode.org/wiki/Jensen%27s_Device
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

[inits]
    LET i$ = 0          ' the "by-name" index, shared with term subroutines
    LET lo$ = 0
    LET hi$ = 0
    LET term$ = ""      ' label of the subroutine that evaluates the term
    LET termValue$ = 0  ' result written by the term subroutine
    LET sum$ = 0

[main]
    ' sum(i, 1, 100, 1/i)
    lo$ = 1 : hi$ = 100 : term$ = "[term:reciprocal]"
    GOSUB [sub:sum]
    PRINT "H(100)          = "; sum$

    ' Same device, different term: sum(i, 1, 10, i*i)
    lo$ = 1 : hi$ = 10 : term$ = "[term:square]"
    GOSUB [sub:sum]
    PRINT "Sum of squares  = "; sum$
END

[sub:sum]
    sum$ = 0
    FOR i$ = lo$ TO hi$
        GOSUB term$
        sum$ = sum$ + termValue$
    NEXT
RETURN

[term:reciprocal]
    termValue$ = 1 / i$
RETURN

[term:square]
    termValue$ = i$ * i$
RETURN

' Output:
' H(100)          = 5.187377517639621
' Sum of squares  = 385