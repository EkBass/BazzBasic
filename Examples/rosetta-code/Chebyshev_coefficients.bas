' ============================================
' https://rosettacode.org/wiki/Chebyshev_coefficients
' BazzBasic: https://github.com/EkBass/BazzBasic
' Chebyshev coefficients of cos(x) on the interval [0, 1], 10 terms
' ============================================

[inits]
    LET A# = 0              ' interval start
    LET B# = 1              ' interval end
    LET N# = 10             ' number of coefficients
    DIM coef$, cheby$
    LET w$ = 0

[main]
    ' Sample the function at the Chebyshev nodes mapped onto [A, B]
    FOR i$ = 0 TO N# - 1
        coef$(i$) = COS(COS(PI# / N# * (i$ + 0.5)) * (B# - A#) / 2 + (B# + A#) / 2)
    NEXT

    ' Discrete cosine transform of the samples gives the coefficients
    FOR i$ = 0 TO N# - 1
        w$ = 0
        FOR j$ = 0 TO N# - 1
            w$ = w$ + coef$(j$) * COS(PI# / N# * i$ * (j$ + 0.5))
        NEXT
        cheby$(i$) = w$ * 2 / N#
        PRINT FSTRING("{{-i$-}} : {{-cheby$(i$)-}}")
    NEXT
END

' Output:
' 0 : 1.6471694753903137
' 1 : -0.23229937161517186
' 2 : -0.05371511462204768
' 3 : 0.0024582352669816343
' 4 : 0.0002821190574339161
' 5 : -7.7222291556156E-06
' 6 : -5.898556451056081E-07
' 7 : 1.1521427500937876E-08
' 8 : 6.59629917354465E-10
' 9 : -1.0022016549982027E-11