' ============================================
' https://rosettacode.org/wiki/Inconsummate_numbers_in_base_10
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' A number is inconsummate if no integer N gives it as N / digitsum(N).
' Sieve: walk every Niven number N up to a safe limit and mark the
' quotient N / digitsum(N) as consummate. Whatever stays unmarked
' is inconsummate.

DEF FN DigitSum$(n$)
    LET s$ = 0
    WHILE n$ > 0
        s$ += n$ % 10
        n$ = INT(n$ / 10)
    WEND
    RETURN s$
END DEF

[inits]
    LET SIEVE# = 7000                       ' large enough to reach the 1000th
    LET LIMIT# = SIEVE# * 9 * LEN(STR(SIEVE#)) ' N never needs to exceed this
    LET FIRST# = 50
    LET NTH#   = 1000

    DIM consummate$
    LET s$     = 0
    LET q$     = 0
    LET count$ = 0

[sieve]
    FOR i$ = 10 TO LIMIT#
        s$ = FN DigitSum$(i$)
        IF i$ % s$ = 0 THEN
            q$ = INT(i$ / s$)               ' "/" is float, keep key integer
            IF q$ <= SIEVE# THEN consummate$(q$) = TRUE
        END IF
    NEXT

[main]
    PRINT "The first "; FIRST#; " inconsummate numbers in base 10:"
    FOR i$ = 10 TO SIEVE#
        IF HASKEY(consummate$(i$)) = FALSE THEN
            count$ += 1
            IF count$ <= FIRST# THEN
                PRINT RIGHT("    " + i$, 4);
                IF count$ % 10 = 0 THEN PRINT ""
            END IF
            IF count$ = NTH# THEN
                PRINT ""
                PRINT "The one thousandth inconsummate number is "; i$
                EXIT FOR
            END IF
        END IF
    NEXT
END

' Output:
' The first 50 inconsummate numbers in base 10:
'   62  63  65  75  84  95 161 173 195 216
'  261 266 272 276 326 371 372 377 381 383
'  386 387 395 411 416 422 426 431 432 438
'  441 443 461 466 471 476 482 483 486 488
'  491 492 493 494 497 498 516 521 522 527
'
' The one thousandth inconsummate number is 6996
