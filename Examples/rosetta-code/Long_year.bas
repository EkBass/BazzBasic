' ============================================
' Long year (ISO 8601 years with 53 weeks)
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

' Day of week of 31 December of year y$ (0 = Sunday ... 4 = Thursday)
DEF FN P$(y$)
    RETURN (y$ + INT(y$ / 4) - INT(y$ / 100) + INT(y$ / 400)) % 7
END DEF

' A year is long if it ends on a Thursday,
' or if the previous year ends on a Wednesday (year starts on Thursday)
DEF FN IsLongYear$(y$)
    IF FN P$(y$) = 4 THEN RETURN TRUE
    IF FN P$(y$ - 1) = 3 THEN RETURN TRUE
    RETURN FALSE
END DEF

[inits]
    LET FIRST_YEAR# = 2000
    LET LAST_YEAR#  = 2100
    LET count$      = 0

[main]
    ' Same checks as the FreeBASIC example
    PRINT "1998: "; FN IsLongYear$(1998)
    PRINT "2020: "; FN IsLongYear$(2020)
    PRINT "2021: "; FN IsLongYear$(2021)
    PRINT

    PRINT FSTRING("Long years between {{-FIRST_YEAR#-}} and {{-LAST_YEAR#-}}:")
    FOR y$ = FIRST_YEAR# TO LAST_YEAR#
        IF FN IsLongYear$(y$) THEN
            PRINT y$; " ";
            count$ += 1
        END IF
    NEXT
    PRINT
    PRINT FSTRING("Total: {{-count$-}} long years")
END

' Output:
' 1998: 1
' 2020: 1
' 2021: 0
'
' Long years between 2000 and 2100:
' 2004 2009 2015 2020 2026 2032 2037 2043 2048 2054 2060 2065 2071 2076 2082 2088 2093 2099
' Total: 18 long years