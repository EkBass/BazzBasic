' ============================================
' ROSETTA: https://rosettacode.org/wiki/String_case
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Converts the string BazzBasic to upper case with UCASE and to lower case with LCASE and prints the original and both results.
' CATEGORY: strings
' TAGS: ucase, lcase, string case
' MINVERSION: 1.5
' ============================================
[inits]
    LET mix$ = "BazzBasic"

[output]
    CLS
    PRINT "Original:    "; mix$
    PRINT "UCASE:       "; UCASE(mix$)
    PRINT "lcase:       "; LCASE(mix$)
END

' Output:
' Original:    BazzBasic
' UCASE:       BAZZBASIC
' lcase:       bazzbasic
