' ============================================
' https://rosettacode.org/wiki/Caesar_cipher
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

DEF FN Encrypt$(s$, key$)
    LET c$ = 0
    LET ret$ = ""

    FOR i$ = 1 TO LEN(s$)
        c$ = ASC(MID(s$, i$, 1))
        IF c$ >= 65 AND c$ <= 90 THEN
            c$ += key$
            IF c$ > 90 THEN c$ -= 26
        ELSEIF c$ >= 97 AND c$ <= 122 THEN
            c$ += key$
            IF c$ > 122 THEN c$ -= 26
        END IF
        ret$ += CHR(c$)
    NEXT

    RETURN ret$
END DEF

DEF FN Decrypt$(s$, key$)
    RETURN FN Encrypt$(s$, 26 - key$)
END DEF

[inits]
    LET s$ = "Bright vixens jump; dozy fowl quack."

[main]
    PRINT "Plain text : "; s$
    s$ = FN Encrypt$(s$, 10)
    PRINT "Encrypted  : "; s$
    PRINT "Decrypted  : "; FN Decrypt$(s$, 10)
END

' Output:
' Plain text : Bright vixens jump; dozy fowl quack.
' Encrypted  : Lbsqrd fshoxc tewz; nyji pygv aekmu.
' Decrypted  : Bright vixens jump; dozy fowl quack.