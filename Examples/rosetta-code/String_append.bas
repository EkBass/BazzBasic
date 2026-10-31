' ============================================
' ROSETTA: https://rosettacode.org/wiki/String_append
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Appends text and a number to string variables with concatenation and prints the results.
' CATEGORY: strings
' TAGS: string append, concatenation
' MINVERSION: 1.5
' ============================================

' BazzBasic uses = for append; += operator does not exist.
' Numbers are typeless and concatenate directly with strings.

[inits]
    LET foo$
    LET bar$
    LET num$
    LET boo$
    foo$ = "Text" + "Text"
    bar$ = foo$ + foo$
    num$ = 123
    boo$ = bar$ + num$

[output]
    PRINT "foo$: "; foo$
    PRINT "bar$: "; bar$
    PRINT "boo$: "; boo$
END

' Output:
' foo$: TextText
' bar$: TextTextTextText
' boo$: TextTextTextText123
