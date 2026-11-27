' calendar.bas - Solar System: date and number text (DEF FN only)
' INCLUDEd first by solar.bas, so the functions exist before any call.
' Calendar: proleptic Gregorian, days/civil arithmetic (Hinnant), FLOOR only.

' Days since 1970-01-01 for a civil date y-m-d
DEF FN DaysFromCivil$(y$, m$, d$)
    IF m$ <= 2 THEN y$ = y$ - 1
    LET era$ = FLOOR(y$ / 400)
    LET yoe$ = y$ - era$ * 400
    LET mp$ = m$ + 9
    IF m$ > 2 THEN mp$ = m$ - 3
    LET doy$ = FLOOR((153 * mp$ + 2) / 5) + d$ - 1
    LET doe$ = yoe$ * 365 + FLOOR(yoe$ / 4) - FLOOR(yoe$ / 100) + doy$
    RETURN era$ * 146097 + doe$ - 719468
END DEF

' "yyyy-mm-dd" for a day number z$ (days since 1970-01-01)
DEF FN DateText$(z$)
    z$ = z$ + 719468
    LET era$ = FLOOR(z$ / 146097)
    LET doe$ = z$ - era$ * 146097
    LET yoe$ = FLOOR((doe$ - FLOOR(doe$ / 1460) + FLOOR(doe$ / 36524) - FLOOR(doe$ / 146096)) / 365)
    LET y$ = yoe$ + era$ * 400
    LET doy$ = doe$ - (365 * yoe$ + FLOOR(yoe$ / 4) - FLOOR(yoe$ / 100))
    LET mp$ = FLOOR((5 * doy$ + 2) / 153)
    LET d$ = doy$ - FLOOR((153 * mp$ + 2) / 5) + 1
    LET m$ = mp$ - 9
    IF mp$ < 10 THEN m$ = mp$ + 3
    IF m$ <= 2 THEN y$ = y$ + 1
    RETURN STR(y$) + "-" + RIGHT("0" + STR(m$), 2) + "-" + RIGHT("0" + STR(d$), 2)
END DEF

' Fixed-point text of v$ >= 0 with dec$ decimals (no reliance on double formatting)
DEF FN Fixed$(v$, dec$)
    LET p$ = POW(10, dec$)
    LET n$ = ROUND(v$ * p$)
    IF dec$ = 0 THEN RETURN STR(n$)
    LET w$ = FLOOR(n$ / p$)
    LET f$ = n$ - w$ * p$
    RETURN STR(w$) + "." + RIGHT(REPEAT("0", dec$) + STR(f$), dec$)
END DEF

' Signed fixed-point text with dec$ decimals, never "-0.00" (B8 body list; b8-details P6)
DEF FN SFixed$(v$, dec$)
    LET p$ = POW(10, dec$)
    LET n$ = ROUND(ABS(v$) * p$)
    LET s$ = ""
    IF v$ < 0 AND n$ > 0 THEN s$ = "-"
    LET w$ = FLOOR(n$ / p$)
    LET f$ = n$ - w$ * p$
    RETURN s$ + STR(w$) + "." + RIGHT(REPEAT("0", dec$) + STR(f$), dec$)
END DEF
