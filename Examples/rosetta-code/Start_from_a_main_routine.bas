' ============================================
' ROSETTA: https://rosettacode.org/wiki/Start_from_a_main_routine
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Shows that BazzBasic needs no main() entry point: programs run top to bottom, and the [inits] and [main] labels with a GOSUB subroutine give the same structure.
' CATEGORY: basics
' TAGS: main routine, program structure, labels, gosub
' MINVERSION: 1.5
' ============================================
' BazzBasic programs execute top-to-bottom. There is no required main()
' entry point. However, the [inits] / [main] label convention provides
' a clear structural equivalent: declarations first, logic second.

[inits]
    LET myVar$    = "foo"
    LET otherVar$ = "bar"

[main]
    PRINT myVar$
    GOSUB [sub:doSomething]
END

[sub:doSomething]
    PRINT "doSomething"
RETURN
