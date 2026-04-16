' ============================================
' https://rosettacode.org/wiki/Case-sensitivity_of_identifiers
' BazzBasic: https://github.com/EkBass/BazzBasic
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