' ============================================
' Leap year - Rosetta Code
' https://rosettacode.org/wiki/Leap_year
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

' Gregorian rule: divisible by 4, except centuries,
' unless the century is also divisible by 400.
DEF FN IsLeap$(year$)
    IF year$ % 4 <> 0 THEN RETURN FALSE
    IF year$ % 100 = 0 AND year$ % 400 <> 0 THEN RETURN FALSE
    RETURN TRUE
END DEF

' Pad text on the right to a fixed column width
DEF FN PadRight$(text$, width$)
    RETURN text$ + REPEAT(" ", width$ - LEN(text$))
END DEF

[inits]
    LET COL_WIDTH# = 14
    LET year$ = 0
    LET cell$ = ""

[main]
    ' Part 1: century years 1800 - 2900
    FOR year$ = 1800 TO 2900 STEP 100
        IF FN IsLeap$(year$) THEN
            PRINT year$; " is a leap year"
        ELSE
            PRINT year$; " is not a leap year"
        END IF
    NEXT

    PRINT ""

    ' Part 2: table of 2012 - 2031, four years per row
    FOR year$ = 2012 TO 2031
        IF FN IsLeap$(year$) THEN
            cell$ = year$ + " = leap"
        ELSE
            cell$ = year$ + " = no"
        END IF
        PRINT FN PadRight$(cell$, COL_WIDTH#);
        IF year$ % 4 = 3 THEN PRINT ""
    NEXT
END

' Output:
' 1800 is not a leap year
' 1900 is not a leap year
' 2000 is a leap year
' 2100 is not a leap year
' 2200 is not a leap year
' 2300 is not a leap year
' 2400 is a leap year
' 2500 is not a leap year
' 2600 is not a leap year
' 2700 is not a leap year
' 2800 is a leap year
' 2900 is not a leap year
'
' 2012 = leap   2013 = no     2014 = no     2015 = no
' 2016 = leap   2017 = no     2018 = no     2019 = no
' 2020 = leap   2021 = no     2022 = no     2023 = no
' 2024 = leap   2025 = no     2026 = no     2027 = no
' 2028 = leap   2029 = no     2030 = no     2031 = no