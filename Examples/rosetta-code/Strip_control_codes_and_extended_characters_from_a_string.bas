' ============================================
' ROSETTA: https://rosettacode.org/wiki/Strip_control_codes_and_extended_characters_from_a_string
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Removes control codes (0 to 31 and 127) from a test string, and separately both control codes and extended characters (128 and up), by checking the ASC code of each character.
' CATEGORY: strings
' TAGS: control codes, extended characters, asc, strip
' MINVERSION: 1.5
' ============================================

DEF FN StripControl$(s$)
    ' Remove control codes (0-31 and 127), keep extended (128+)
    LET result$ = ""
    FOR i$ = 1 TO LEN(s$)
        LET c$ = MID(s$, i$, 1)
        LET code$ = ASC(c$)
        IF code$ >= 32 AND code$ <> 127 THEN result$ += c$
    NEXT
    RETURN result$
END DEF

DEF FN StripAll$(s$)
    ' Remove control codes (0-31 and 127) and extended characters (128+)
    LET result$ = ""
    FOR i$ = 1 TO LEN(s$)
        LET c$ = MID(s$, i$, 1)
        LET code$ = ASC(c$)
        IF code$ >= 32 AND code$ <= 126 THEN result$ += c$
    NEXT
    RETURN result$
END DEF

[inits]
    ' Build test string: printable ASCII + control codes + extended chars
    LET s$ = CHR(2) + "Hello" + CHR(9) + "W" + CHR(27) + "orld" + CHR(127) + CHR(233) + "!"
    LET wkv$ ' WAITKEY return value

[main]
    PRINT "Original (escaped): "; s$
    PRINT "Control codes stripped: "; FN StripControl$(s$)
    PRINT "Control and extended stripped: "; FN StripAll$(s$)
    wkv$ = WAITKEY()
END

' Output:
' Original (escaped): Hello       Wrldé!
' Control codes stripped: HelloWorldé!
' Control and extended stripped: HelloWorld!