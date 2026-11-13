' ============================================
' https://rosettacode.org/wiki/Hofstadter_Q_sequence
' BazzBasic: https://github.com/EkBass/BazzBasic
' Q(1) = Q(2) = 1, Q(n) = Q(n - Q(n-1)) + Q(n - Q(n-2))
' ============================================

[inits]
    LET LIMIT# = 100000
    DIM q$
    q$(1) = 1
    q$(2) = 1
    LET count$ = 0

[main]
    FOR i$ = 3 TO LIMIT#
        q$(i$) = q$(i$ - q$(i$ - 1)) + q$(i$ - q$(i$ - 2))
        IF q$(i$) < q$(i$ - 1) THEN count$ += 1
    NEXT

    PRINT "First 10 terms: ";
    FOR i$ = 1 TO 10
        PRINT q$(i$); " ";
    NEXT
    PRINT

    PRINT "Term 1000: "; q$(1000)
    PRINT "Terms less than preceding in first 100k: "; count$
END

' Output:
' First 10 terms: 1 1 2 3 3 4 5 5 6 6
' Term 1000: 502
' Terms less than preceding in first 100k: 49798