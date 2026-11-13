' ============================================
' https://rosettacode.org/wiki/Horizontal_sundial_calculations
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' Calculate the hour, sun hour angle and dial hour line angle
' from 6am to 6pm for a given latitude, longitude and legal meridian.

' Fixed-point formatter: dec$ decimals, right-aligned to width$.
' plus$ = TRUE adds a "+" in front of non-negative values.
DEF FN Fixed$(n$, dec$, width$, plus$)
    LET scale$ = POW(10, dec$)
    LET v$     = ROUND(ABS(n$) * scale$)
    LET s$     = STR(INT(v$ / scale$))
    IF dec$ > 0 THEN
        s$ = s$ + "." + RIGHT(REPEAT("0", dec$) + STR(MOD(v$, scale$)), dec$)
    END IF
    IF n$ < 0 AND v$ > 0 THEN
        s$ = "-" + s$
    ELSEIF plus$ THEN
        s$ = "+" + s$
    END IF
    IF LEN(s$) < width$ THEN s$ = REPEAT(" ", width$ - LEN(s$)) + s$
    RETURN s$
END DEF

' Scientific formatter, e.g. -8.63E-02
DEF FN Sci$(n$, dec$)
    LET a$ = ABS(n$)
    LET e$ = 0
    IF a$ > 0 THEN
        e$ = FLOOR(LOG(a$) / LOG(10))
        IF ROUND(a$ / POW(10, e$) * POW(10, dec$)) >= 10 * POW(10, dec$) THEN e$ += 1
        IF a$ / POW(10, e$) < 1 THEN e$ -= 1
    END IF
    LET s$ = FN Fixed$(a$ / POW(10, e$), dec$, 0, FALSE)
    IF n$ < 0 THEN s$ = "-" + s$ ELSE s$ = " " + s$
    IF e$ < 0 THEN s$ = s$ + "E-" ELSE s$ = s$ + "E+"
    RETURN s$ + RIGHT("0" + STR(ABS(e$)), 2)
END DEF

[inits]
    LET lat$  = 0
    LET lng$  = 0
    LET ref$  = 0
    LET sLat$ = 0
    LET hra$  = 0
    LET hla$  = 0

[main]
    INPUT "Enter latitude       => ", lat$
    INPUT "Enter longitude      => ", lng$
    INPUT "Enter legal meridian => ", ref$
    lat$ = VAL(lat$)
    lng$ = VAL(lng$)
    ref$ = VAL(ref$)
    PRINT

    sLat$ = SIN(RAD(lat$))
    PRINT "    sine of latitude:   "; FN Sci$(sLat$, 2)
    PRINT "    diff longitude:     "; FN Fixed$(lng$ - ref$, 3, 8, FALSE)
    PRINT
    PRINT "Hour, sun hour angle, dial hour line angle from 6am to 6pm"

    FOR h$ = -6 TO 6
        hra$ = 15 * h$ - (lng$ - ref$)          ' correct for longitude difference
        hla$ = DEG(ATAN(sLat$ * TAN(RAD(hra$))))
        PRINT "HR="; FN Fixed$(h$, 0, 3, TRUE);
        PRINT "; HRA="; FN Fixed$(hra$, 3, 8, TRUE);
        PRINT "; HLA="; FN Fixed$(hla$, 3, 8, TRUE)
    NEXT
END

' Output:
' Enter latitude       => -4.95
' Enter longitude      => -150.5
' Enter legal meridian => -150
'
'     sine of latitude:   -8.63E-02
'     diff longitude:       -0.500
'
' Hour, sun hour angle, dial hour line angle from 6am to 6pm
' HR= -6; HRA= -89.500; HLA= +84.225
' HR= -5; HRA= -74.500; HLA= +17.283
' HR= -4; HRA= -59.500; HLA=  +8.334
' HR= -3; HRA= -44.500; HLA=  +4.847
' HR= -2; HRA= -29.500; HLA=  +2.795
' HR= -1; HRA= -14.500; HLA=  +1.278
' HR= +0; HRA=  +0.500; HLA=  -0.043
' HR= +1; HRA= +15.500; HLA=  -1.371
' HR= +2; HRA= +30.500; HLA=  -2.910
' HR= +3; HRA= +45.500; HLA=  -5.018
' HR= +4; HRA= +60.500; HLA=  -8.671
' HR= +5; HRA= +75.500; HLA= -18.451
' HR= +6; HRA= +90.500; HLA= +84.225
