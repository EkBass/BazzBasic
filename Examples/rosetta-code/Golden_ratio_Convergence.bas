' ============================================
' ROSETTA: https://rosettacode.org/wiki/Golden_ratio/Convergence
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Iterates phi(n+1) = 1 + 1/phi(n) until two successive values differ by at most 1e-5, then prints the result, the iteration count and the error against the exact golden ratio.
' CATEGORY: math
' TAGS: golden ratio, convergence, iteration, tolerance
' MINVERSION: 1.5
' ============================================
' Iterate phi(n+1) = 1 + 1/phi(n), phi(0) = 1, until two
' successive values differ by at most 1e-5.

[inits]
    LET TOLERANCE# = 0.00001
    LET PHI_EXACT# = (1 + SQR(5)) / 2
    LET phi0$ = 1
    LET phi1$ = 0
    LET iter$ = 0
    LET done$ = FALSE

[main]
    WHILE NOT done$
        phi1$ = 1 + 1 / phi0$
        iter$ += 1
        IF ABS(phi1$ - phi0$) <= TOLERANCE# THEN done$ = TRUE
        phi0$ = phi1$
    WEND

    PRINT "Result: "; phi1$; " after "; iter$; " iterations"
    PRINT "The error is approximately "; phi1$ - PHI_EXACT#
END

' Output:
' Result: 1.6180327868852458 after 14 iterations
' The error is approximately -1.2018646491362972E-06
