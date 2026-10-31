' ============================================
' ROSETTA: https://rosettacode.org/wiki/Base_16_numbers_needing_a_to_f
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Lists the numbers from 1 to 500 whose hexadecimal form contains at least one of the digits a to f, ten per row, and counts them.
' CATEGORY: math
' TAGS: hexadecimal, number bases, digits
' MINVERSION: 1.5
' ============================================
' Task: find the numbers 1 to 500 whose hexadecimal form
'       contains at least one of the digits a to f.

' TRUE if any base-16 digit of n$ is 10 or more (a..f)
DEF FN HasHexLetter$(n$)
    LET m$ = n$
    LET found$ = FALSE
    WHILE m$ > 0 AND NOT found$
        IF MOD(m$, 16) >= 10 THEN found$ = TRUE
        m$ = INT(m$ / 16)
    WEND
    RETURN found$
END DEF

[inits]
    LET LIMIT# = 500
    LET PER_ROW# = 10
    LET count$ = 0
    LET row$ = ""

[main]
    FOR n$ = 1 TO LIMIT#
        IF FN HasHexLetter$(n$) THEN
            count$ += 1
            row$ += RIGHT("    " + n$, 4)
            IF MOD(count$, PER_ROW#) = 0 THEN
                PRINT row$
                row$ = ""
            END IF
        END IF
    NEXT
    IF row$ <> "" THEN PRINT row$       ' last, partly filled row

    PRINT
    PRINT "Found "; count$; " numbers."
END

' Output:
'   10  11  12  13  14  15  26  27  28  29
'   30  31  42  43  44  45  46  47  58  59
'  ...
'  478 479 480 481 482 483 484 485 486 487
'  488 489 490 491 492 493 494 495 496 497
'  498 499 500
'
' Found 301 numbers.