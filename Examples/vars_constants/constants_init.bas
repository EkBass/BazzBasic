' ============================================
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Shows basic initialization of constants and variables with LET, including a constant calculated from other values and several constants in one statement.
' CATEGORY: basics
' TAGS: constants, variables, initialization
' MINVERSION: 1.5
' ============================================

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