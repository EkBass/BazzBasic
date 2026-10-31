' ============================================
' ROSETTA: https://rosettacode.org/wiki/Day_of_the_week_of_Christmas_and_New_Year
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Prints the weekday of Christmas Day 2021 and New Year's Day 2022, calculated with Zeller's congruence.
' CATEGORY: system
' TAGS: day of the week, zeller's congruence, dates, split
' MINVERSION: 1.5
' ============================================

' Returns 0 = Saturday, 1 = Sunday ... 6 = Friday
DEF FN Weekday$(y$, m$, d$)
    IF m$ <= 2 THEN                 ' January and February count as months 13 and 14
        m$ = m$ + 12
        y$ = y$ - 1
    END IF
    LET j$ = INT(y$ / 100)          ' century
    LET k$ = MOD(y$, 100)           ' year of the century
    RETURN MOD(d$ + INT((m$ + 1) * 26 / 10) + k$ + INT(k$ / 4) + INT(j$ / 4) + 5 * j$, 7)
END DEF

[inits]
    DIM dayNames$, dates$, parts$
    LET count$ = SPLIT(dayNames$, "Saturday,Sunday,Monday,Tuesday,Wednesday,Thursday,Friday", ",")
    count$ = SPLIT(dates$, "2021-12-25,2022-01-01", ",")
    LET n$ = 0
    LET wd$ = 0

[main]
    FOR i$ = 0 TO count$ - 1
        n$ = SPLIT(parts$, dates$(i$), "-")
        wd$ = FN Weekday$(VAL(parts$(0)), VAL(parts$(1)), VAL(parts$(2)))
        PRINT dates$(i$); " is a "; dayNames$(wd$)
    NEXT
END

' Output:
' 2021-12-25 is a Saturday
' 2022-01-01 is a Saturday