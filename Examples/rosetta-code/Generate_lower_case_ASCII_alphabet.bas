' ============================================
' https://rosettacode.org/wiki/Generate_lower_case_ASCII_alphabet
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

[inits]
    LET daString$ = ""
    LET daString2$ = ""

[main]
    ' with key constants
    FOR i$ = KEY_A# TO KEY_Z#
        daString$+= LCASE(CHR(i$)) + " "
    NEXT

    daString$ = RTRIM(daString$)

    ' with ASC()
    FOR i$ = ASC("a") TO ASC("z")
        daString2$+= CHR(i$) + " "
    NEXT

    daString2$ = RTRIM(daString2$)

[output]
    PRINT daString$
    PRINT daString2$
END

' Output
' a b c d e f g h i j k l m n o p q r s t u v w x y z
' a b c d e f g h i j k l m n o p q r s t u v w x y z