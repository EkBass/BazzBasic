' ============================================
' ROSETTA: https://rosettacode.org/wiki/Empty_string
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Shows that a string variable declared without a value is empty and tests a string for being empty and not empty.
' CATEGORY: strings
' TAGS: empty string, string comparison, variables
' MINVERSION: 1.5
' ============================================

[inits]
    LET s$
    LET f$ = "Not empty"

[main]

    PRINT "Empty string: "; s$

    IF s$ = "" THEN
        PRINT "s$ is empty."
    ENDIF

    IF f$ <> "" THEN
        PRINT "f$ is not empty."
    ENDIF
END

' Output:
' Empty string:
' s$ is empty.
' f$ is not empty.