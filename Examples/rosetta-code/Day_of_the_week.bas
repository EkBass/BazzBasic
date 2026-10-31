' ============================================
' ROSETTA: https://rosettacode.org/wiki/Day_of_the_week
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Lists the years between 2008 and 2121 in which 25 December falls on a Sunday.
' CATEGORY: system
' TAGS: day of the week, christmas, leap years, calendar arithmetic
' MINVERSION: 1.5
' ============================================

[inits]
    LET FIRST# = 2008
    LET LAST# = 2121
    LET days$ = 0

[main]
    PRINT FSTRING("Sunday Christmases {{-FIRST#-}} - {{-LAST#-}}")
    PRINT ""
    FOR y$ = FIRST# TO LAST#
        ' Day count up to the end of year y (Gregorian leap rules),
        ' offset so that a remainder of 0 means 25 December is a Sunday
        days$ = y$ * 365 + INT(y$ / 4) - INT(y$ / 100) + INT(y$ / 400)
        IF MOD(days$ - 6, 7) = 0 THEN PRINT y$; " ";
    NEXT
    PRINT ""
END

' Output:
' Sunday Christmases 2008 - 2121
'
' 2011 2016 2022 2033 2039 2044 2050 2061 2067 2072 2078 2089 2095 2101 2107 2112 2118