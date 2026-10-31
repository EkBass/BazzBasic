' ============================================
' ROSETTA: https://rosettacode.org/wiki/Case-sensitivity_of_identifiers
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Shows that BazzBasic identifiers are case-insensitive, so dog$, Dog$ and DOG$ all name the same variable.
' CATEGORY: basics
' TAGS: case sensitivity, identifiers, variables
' MINVERSION: 1.5
' ============================================

' BazzBasic is case-insensitive.
' dog$, DOG$ or DoG$ or are handled as same variable.

[inits]
    LET dog$

    dog$ = "Benjamin"
    Dog$ = "Samba"
    DOG$ = "Bernie"

[main]
    PRINT "There is just one dog named "; DoG$
END

' Output
' There is just one dog named Bernie