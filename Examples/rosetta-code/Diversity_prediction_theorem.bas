' ============================================
' https://rosettacode.org/wiki/Diversity_prediction_theorem
' BazzBasic: https://github.com/EkBass/BazzBasic
' Collective error = average individual error - prediction diversity
' ============================================

' Format a number with a fixed number of decimals, right-aligned to width
DEF FN Fixed$(n$, dec$, width$)
    LET sign$ = ""
    IF n$ < 0 THEN
        sign$ = "-"
        n$ = ABS(n$)
    END IF
    LET p$      = POW(10, dec$)
    LET scaled$ = ROUND(n$ * p$)
    LET ip$     = INT(scaled$ / p$)
    LET fp$     = scaled$ - ip$ * p$
    LET s$      = sign$ + STR(ip$) + "." + RIGHT(REPEAT("0", dec$) + STR(fp$), dec$)
    RETURN REPEAT(" ", MAX(0, width$ - LEN(s$))) + s$
END DEF

[inits]
    LET TRUE_VAL# = 49

    DIM tests$
    tests$(0) = "48,47,51"
    tests$(1) = "48,47,51,42"

    DIM est$
    LET cnt$      = 0
    LET e$        = 0
    LET vari$     = 0
    LET sum$      = 0
    LET avgErr$   = 0
    LET refAvg$   = 0
    LET crowdErr$ = 0

[main]
    FOR i$ = 0 TO ROWCOUNT(tests$()) - 1
        cnt$  = SPLIT(est$, tests$(i$), ",")
        vari$ = 0
        sum$  = 0

        FOR c$ = 0 TO cnt$ - 1
            e$ = VAL(est$(c$))
            vari$ += POW(e$ - TRUE_VAL#, 2)
            sum$  += e$
        NEXT

        avgErr$   = vari$ / cnt$
        refAvg$   = sum$ / cnt$
        crowdErr$ = POW(TRUE_VAL# - refAvg$, 2)

        PRINT "Average error : " + FN Fixed$(avgErr$, 4, 8)
        PRINT "  Crowd error : " + FN Fixed$(crowdErr$, 4, 8)
        PRINT "    Diversity : " + FN Fixed$(avgErr$ - crowdErr$, 4, 8)
        PRINT
    NEXT
END

' Output:
' Average error :   3.0000
'   Crowd error :   0.1111
'     Diversity :   2.8889
'
' Average error :  14.5000
'   Crowd error :   4.0000
'     Diversity :  10.5000