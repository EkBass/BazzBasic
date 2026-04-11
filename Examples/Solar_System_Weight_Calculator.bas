REM ================================================
REM Solar System Weight Calculator
REM BazzBasic - github.com/EkBass/BazzBasic
REM ================================================

[inits]
    DIM planets$

    planets$(0, "name") = "Sun"      : planets$(0, "gravity") = 27.07
    planets$(1, "name") = "Mercury"  : planets$(1, "gravity") = 0.38
    planets$(2, "name") = "Venus"    : planets$(2, "gravity") = 0.91
    planets$(3, "name") = "Earth"    : planets$(3, "gravity") = 1.00
    planets$(4, "name") = "Mars"     : planets$(4, "gravity") = 0.38
    planets$(5, "name") = "Jupiter"  : planets$(5, "gravity") = 2.34
    planets$(6, "name") = "Saturn"   : planets$(6, "gravity") = 1.06
    planets$(7, "name") = "Uranus"   : planets$(7, "gravity") = 0.92
    planets$(8, "name") = "Neptune"  : planets$(8, "gravity") = 1.19
    planets$(9, "name") = "Pluto"    : planets$(9, "gravity") = 0.06

    ' LET COUNT# = 10 <- fixed value, bad bad bad :)
    LET count$ = LEN(planets$()) / 2 ' 2 because of dimensions

    ' BazzBasic 1.2 returns LEN(planets$()) = 20 since there is 20 elements.
    ' ROWCOUNT(arr$) is coming for version 1.3 which returns correctly 10

[main]
    CLS
    COLOR 11, 0
    PRINT "  *** Solar System Weight Calculator ***"
    COLOR 7, 0
    PRINT

    INPUT "  Your weight on Earth (kg): ", earthWeight$

    PRINT
    COLOR 14, 0
    PRINT LEFT("  Body" + REPEAT(" ", 16), 18); "Weight (kg)"
    PRINT "  " + REPEAT("-", 30)
    COLOR 7, 0

    FOR i$ = 0 TO count$ - 1
        LET name$    = planets$(i$, "name")
        LET result$  = ROUND(earthWeight$ * planets$(i$, "gravity") * 10) / 10

        IF name$ = "Earth" THEN COLOR 10, 0
        PRINT LEFT("  " + name$ + REPEAT(" ", 16), 18); result$
        IF name$ = "Earth" THEN COLOR 7, 0
    NEXT

    PRINT
    COLOR 8, 0
    PRINT "  (Note: Pluto counts here!)"
    COLOR 7, 0
END

' Output:
'   *** Solar System Weight Calculator ***
' 
'   Your weight on Earth (kg): 100
' 
'   Body            Weight (kg)
'   ------------------------------
'   Sun             2707
'   Mercury         38
'   Venus           91
'   Earth           100
'   Mars            38
'   Jupiter         234
'   Saturn          106
'   Uranus          92
'   Neptune         119
'   Pluto           6
' 
'   (Note: Pluto counts here!)