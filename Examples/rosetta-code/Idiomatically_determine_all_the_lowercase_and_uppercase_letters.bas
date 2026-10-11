' ============================================
' https://rosettacode.org/wiki/Idiomatically_determine_all_the_lowercase_and_uppercase_letters
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

DEF FN LetterCase$(ch$)
    ' String "=" is case-insensitive in BazzBasic,
    ' so compare character codes instead.
    ' Non-letters are unchanged by both UCASE and LCASE.
    IF ASC(UCASE(ch$)) = ASC(LCASE(ch$)) THEN RETURN NOT_LETTER#
    IF ASC(UCASE(ch$)) = ASC(ch$) THEN RETURN UPPER#
    RETURN LOWER#
END DEF

[inits]
    LET NOT_LETTER# = 0
    LET UPPER#      = 1
    LET LOWER#      = -1

    LET lower$  = ""
    LET upper$  = ""
    LET choice$ = 0

[main]
    FOR i$ = 0 TO 128 ' increase to 255 to see non-english alphabets too
        choice$ = FN LetterCase$(CHR(i$))
        IF choice$ = UPPER# THEN upper$ += CHR(i$)
        IF choice$ = LOWER# THEN lower$ += CHR(i$)
    NEXT

    PRINT "Upper: "; upper$
    PRINT "Lower: "; lower$
END

' Output with english letters only:
' Upper: ABCDEFGHIJKLMNOPQRSTUVWXYZ
' Lower: abcdefghijklmnopqrstuvwxyz

' Output with all alphabets in ASCII 256
' Upper: ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞ
' Lower: abcdefghijklmnopqrstuvwxyzµàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ