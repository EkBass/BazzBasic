' ============================================
' ROSETTA: https://rosettacode.org/wiki/Exponentiation_order
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Prints the two possible readings of 5**3**2, (5**3)**2 and 5**(3**2), calculated with nested POW calls because BazzBasic has no exponentiation operator.
' CATEGORY: math
' TAGS: exponentiation, pow, evaluation order, operator precedence
' MINVERSION: 1.5
' ============================================
' BazzBasic has no exponentiation operator. Powers are written
' with the function POW(base, exponent). Because every power is
' a function call, the order of evaluation is always explicit
' in the nesting - an ambiguous form like 5**3**2 cannot be
' written at all. Its two possible readings are shown below.

[inits]
    LET leftFirst$  = POW(POW(5, 3), 2)    ' (5**3)**2
    LET rightFirst$ = POW(5, POW(3, 2))    ' 5**(3**2)

[main]
    PRINT "5**3**2   : no equivalent, order must be chosen explicitly"
    PRINT "(5**3)**2 = POW(POW(5, 3), 2) = "; leftFirst$
    PRINT "5**(3**2) = POW(5, POW(3, 2)) = "; rightFirst$
END

' Output:
' 5**3**2   : no equivalent, order must be chosen explicitly
' (5**3)**2 = POW(POW(5, 3), 2) = 15625
' 5**(3**2) = POW(5, POW(3, 2)) = 1953125
