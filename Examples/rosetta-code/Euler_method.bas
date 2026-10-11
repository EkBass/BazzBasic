' ============================================
' https://rosettacode.org/wiki/Euler_method
' BazzBasic: https://github.com/EkBass/BazzBasic
' Solve Newton's cooling law dT/dt = -k(T - TR) with Euler's method
' and compare step sizes 2, 5 and 10 against the analytic solution.
' ============================================

' The differential equation being solved: dy/dt = f(t, y)
DEF FN Cooling$(t$, y$)
    RETURN -K# * (y$ - ROOM_TEMP#)
END DEF

' Exact solution for comparison
DEF FN Analytic$(t$)
    RETURN ROOM_TEMP# + (START_TEMP# - ROOM_TEMP#) * EXP(-K# * t$)
END DEF

DEF FN Round3$(x$)
    RETURN ROUND(x$ * 1000) / 1000
END DEF

DEF FN PadLeft$(v$, width$)
    RETURN RIGHT(REPEAT(" ", width$) + v$, width$)
END DEF

[inits]
    LET K#          = 0.07
    LET ROOM_TEMP#  = 20
    LET START_TEMP# = 100
    LET T_START#    = 0
    LET T_END#      = 100
    LET REPORT#     = 10     ' print every 10 seconds
    LET COL#        = 11

    DIM steps$
    steps$(0) = 2
    steps$(1) = 5
    steps$(2) = 10

    DIM result$              ' result$(stepSize, time) = Euler estimate
    LET h$ = 0
    LET t$ = 0
    LET y$ = 0
    LET line$ = ""

[main]
    FOR i$ = 0 TO ROWCOUNT(steps$()) - 1
        h$ = steps$(i$)
        GOSUB [sub:euler]
    NEXT

    PRINT "Newton's cooling, k = "; K#; ", from "; START_TEMP#; " to "; ROOM_TEMP#
    PRINT
    line$ = "  Time" + FN PadLeft$("Analytic", COL#)
    FOR i$ = 0 TO ROWCOUNT(steps$()) - 1
        line$ += FN PadLeft$("h=" + steps$(i$), COL#)
    NEXT
    PRINT line$

    FOR t$ = T_START# TO T_END# STEP REPORT#
        line$ = FN PadLeft$(t$, 6) + FN PadLeft$(FN Round3$(FN Analytic$(t$)), COL#)
        FOR i$ = 0 TO ROWCOUNT(steps$()) - 1
            h$ = steps$(i$)
            line$ += FN PadLeft$(FN Round3$(result$(h$, t$)), COL#)
        NEXT
        PRINT line$
    NEXT
END

' Run Euler's method with step size h$, storing values at report times
[sub:euler]
    t$ = T_START#
    y$ = START_TEMP#
    WHILE t$ <= T_END#
        IF MOD(t$, REPORT#) = 0 THEN result$(h$, t$) = y$
        y$ += h$ * FN Cooling$(t$, y$)
        t$ += h$
    WEND
RETURN

' Output:
' Newton's cooling, k = 0.07, from 100 to 20
'
'   Time   Analytic        h=2        h=5       h=10
'      0        100        100        100        100
'     10     59.727     57.634       53.8         44
'     20     39.728     37.704     34.281       27.2
'     30     29.797     28.328     26.034      22.16
'     40     24.865     23.918     22.549     20.648
'     50     22.416     21.843     21.077     20.194
'     60       21.2     20.867     20.455     20.058
'     70     20.596     20.408     20.192     20.017
'     80     20.296     20.192     20.081     20.005
'     90     20.147      20.09     20.034     20.002
'    100     20.073     20.042     20.014         20