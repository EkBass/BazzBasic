' BazzBasic version 1.4c
' https://ekbass.github.io/BazzBasic/

' Basic initialization and use for variables

[inits] ' not mandatory, but common
    LET a$
    LET b$, c$ = 10, d$ = 1, e$
    LET f$ = c$ + 1

[output] ' not mandatory, but common
    PRINT "Variables:"
    PRINT "- a$: "; a$
    PRINT "- b$: "; b$
    PRINT "- c$: "; c$
    PRINT "- d$: "; d$
    PRINT "- e$: "; e$
    PRINT "- f$: "; f$

    LET wk$ = WAITKEY()
END

' CLI
' Variables:
' - a$:
' - b$:
' - c$: 10
' - d$: 1
' - e$:
' - f$: 11