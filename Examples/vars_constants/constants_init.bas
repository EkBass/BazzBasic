' BazzBasic version 1.4c
' https://ekbass.github.io/BazzBasic/

' Basic initialization and use for constants

[inits] ' not mandatory, but common
    LET a$      = 1
    LET FOO#    = 2
    LET BAR#    = a$ + FOO#
    LET HIP# = "Hip", HOP# = "Hop"

[output] ' not mandatory, but common
    PRINT "a$: "; a$
    PRINT "FOO#: "; FOO#
    PRINT "BAR#: "; BAR#
    PRINT "HIP#: "; HIP#
    PRINT "HOP#: "; HOP#

    LET wk$ = WAITKEY()
END

' CLI
' a$: 1
' FOO#: 2
' BAR#: 3
' HIP#: Hip
' HOP#: Hop