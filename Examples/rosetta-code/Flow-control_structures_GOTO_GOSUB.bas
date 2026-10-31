' ============================================
' ROSETTA: https://rosettacode.org/wiki/Flow-control_structures
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Demonstrates BazzBasic's flow control: GOTO, GOSUB with RETURN, a computed GOSUB target held in a variable, RETURN inside a DEF FN, and END.
' CATEGORY: basics
' TAGS: goto, gosub, labels, return, flow control
' MINVERSION: 1.5
' ============================================
' Labels are names in square brackets. [inits], [main] and
' [sub:...] are just labels too - a naming convention, not syntax.

' DEF FN: a call that returns a value. RETURN leaves the function
' at once, so it also works as an early exit.
DEF FN Sign$(n$)
    IF n$ < 0 THEN RETURN "negative"
    IF n$ > 0 THEN RETURN "positive"
    RETURN "zero"
END DEF

[inits]
    LET target$ = ""

[main]
    PRINT "1. GOTO jumps unconditionally to a label"
    GOTO [skip]
    PRINT "   (never printed)"
[skip]
    PRINT "   landed at [skip]"

    PRINT "2. GOSUB calls a subroutine, RETURN comes back"
    GOSUB [sub:hello]
    PRINT "   back in [main]"

    PRINT "3. Computed target: the label is held in a variable"
    FOR i$ = 1 TO 2
        target$ = "[sub:case" + i$ + "]"
        GOSUB target$
    NEXT

    PRINT "4. RETURN inside DEF FN exits with a value"
    PRINT "   -5 is "; FN Sign$(-5)

    PRINT "5. END stops the program"
END

' Subroutines live after END, so execution never falls into them
[sub:hello]
    PRINT "   in [sub:hello]"
RETURN

[sub:case1]
    PRINT "   in [sub:case1]"
RETURN

[sub:case2]
    PRINT "   in [sub:case2]"
RETURN

' Output:
' 1. GOTO jumps unconditionally to a label
'    landed at [skip]
' 2. GOSUB calls a subroutine, RETURN comes back
'    in [sub:hello]
'    back in [main]
' 3. Computed target: the label is held in a variable
'    in [sub:case1]
'    in [sub:case2]
' 4. RETURN inside DEF FN exits with a value
'    -5 is negative
' 5. END stops the program