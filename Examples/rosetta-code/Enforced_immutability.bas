' ============================================
' ROSETTA: https://rosettacode.org/wiki/Enforced_immutability
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Declares constants, which are immutable in BazzBasic, and uses them to initialise variables and to print values.
' CATEGORY: basics
' TAGS: constants, immutability, variables
' MINVERSION: 1.5
' ============================================
' In BazzBasic, immutability is enforced by the # suffix.
' Constants are declared with LET, just like variables,
' but any attempt to reassign them is a runtime error.
' Constants are typeless, like variables.

[inits]
    LET MY_NUM#  = 123
    LET MY_TEXT# = "Text"

    ' Variables can be initialised from constants
    LET myVar$      = "More " + MY_TEXT#
    LET myOtherVar$ = MY_NUM# * 2

[main]
    PRINT "MY_NUM#:      "; MY_NUM#
    PRINT "MY_TEXT#:     "; MY_TEXT#
    PRINT "myVar$:       "; myVar$
    PRINT "myOtherVar$:  "; myOtherVar$
END

' Output:
' MY_NUM#:      123
' MY_TEXT#:     Text
' myVar$:       More Text
' myOtherVar$:  246
