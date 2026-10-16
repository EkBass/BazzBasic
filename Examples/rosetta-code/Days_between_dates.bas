' ============================================
' https://rosettacode.org/wiki/Days_between_dates
' BazzBasic: https://github.com/EkBass/BazzBasic
' Number of days between two dates given as YYYY-MM-DD
' ============================================

' TRUE if the string looks like YYYY-MM-DD with a sane month and day
DEF FN IsValidDate$(ds$)
    IF LEN(ds$) <> 10 THEN RETURN FALSE
    IF MID(ds$, 5, 1) <> "-" OR MID(ds$, 8, 1) <> "-" THEN RETURN FALSE
    LET m$ = VAL(MID(ds$, 6, 2))
    LET d$ = VAL(MID(ds$, 9, 2))
    IF NOT BETWEEN(m$, 1, 12) OR NOT BETWEEN(d$, 1, 31) THEN RETURN FALSE
    RETURN TRUE
END DEF

' Sequential day number of a date; only differences between two results matter
DEF FN DayNum$(ds$)
    LET y$ = VAL(MID(ds$, 1, 4))
    LET m$ = VAL(MID(ds$, 6, 2))
    LET d$ = VAL(MID(ds$, 9, 2))
    LET n$ = 365 * y$ + d$ + 31 * (m$ - 1)
    IF m$ >= 3 THEN
        n$ = n$ - INT(0.4 * m$ + 2.3)   ' correct for months shorter than 31 days
    ELSE
        y$ = y$ - 1                     ' Jan/Feb: this year's leap day hasn't happened yet
    END IF
    RETURN n$ + INT(y$ / 4) - INT(y$ / 100) + INT(y$ / 400)
END DEF

[inits]
    LET entry$ = ""
    LET again$ = ""
    LET date1$ = 0
    LET date2$ = 0

[main]
    PRINT "Elapsed days from one date to another."
    PRINT "Enter dates in YYYY-MM-DD format"

[loop]
    PRINT ""
    LINE INPUT "First date   : ", entry$
    GOSUB [sub:validateDate]
    date1$ = FN DayNum$(entry$)

    LINE INPUT "Second date  : ", entry$
    GOSUB [sub:validateDate]
    date2$ = FN DayNum$(entry$)

    PRINT "Elapsed days = "; date2$ - date1$
    LINE INPUT "Do another (y/n)? ", again$
    IF LCASE(again$) = "y" THEN GOTO [loop]
END

' Re-prompt until entry$ holds a valid date
[sub:validateDate]
    WHILE NOT FN IsValidDate$(entry$)
        LINE INPUT "Bad date -- try again: ", entry$
    WEND
RETURN

' Output:
' First date   : 2026-10-11
' Second date  : 2019-06-27
' Elapsed days = -2663
' Do another (y/n)?