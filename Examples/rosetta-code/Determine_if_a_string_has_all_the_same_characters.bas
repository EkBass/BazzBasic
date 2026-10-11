' ============================================
' https://rosettacode.org/wiki/Determine_if_a_string_has_all_the_same_characters
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

' Returns position (1-based) of the first character that differs
' from the first one, or 0 if all characters are the same.
' An empty string counts as all the same.
' Characters are compared by code, since string <> is case-insensitive.
DEF FN FirstDiff$(s$)
    IF LEN(s$) = 0 THEN RETURN 0
    LET ref$ = ASC(s$)
    LET idx$ = 2
    WHILE idx$ <= LEN(s$)
        IF ASC(MID(s$, idx$, 1)) <> ref$ THEN RETURN idx$
        idx$ += 1
    WEND
    RETURN 0
END DEF

' Integer to hexadecimal string
DEF FN Hex$(n$)
    LET digits$ = "0123456789ABCDEF"
    LET v$ = n$
    LET out$ = ""
    IF v$ = 0 THEN RETURN "0"
    WHILE v$ > 0
        out$ = MID(digits$, MOD(v$, 16) + 1, 1) + out$
        v$ = INT(v$ / 16)
    WEND
    RETURN out$
END DEF

[inits]
    DIM tests$
    tests$(0) = ""
    tests$(1) = "   "
    tests$(2) = "2"
    tests$(3) = "333"
    tests$(4) = ".55"
    tests$(5) = "tttTTT"
    tests$(6) = "4444 444k"

    LET s$   = ""
    LET n$   = 0
    LET pos$ = 0
    LET ch$  = ""
    LET hx$  = ""

[main]
    PRINT "Determines if a string has all the same characters."
    PRINT

    FOR i$ = 0 TO ROWCOUNT(tests$()) - 1
        s$   = tests$(i$)
        n$   = LEN(s$)
        pos$ = FN FirstDiff$(s$)
        IF pos$ = 0 THEN
            PRINT FSTRING("'{{-s$-}}' of length {{-n$-}} contains all the same character.")
        ELSE
            ch$ = MID(s$, pos$, 1)
            hx$ = FN Hex$(ASC(ch$))
            PRINT FSTRING("'{{-s$-}}' of length {{-n$-}} is different at position {{-pos$-}}: '{{-ch$-}}' (0x{{-hx$-}})")
        END IF
    NEXT
END

' Output:
' Determines if a string has all the same characters.
'
' '' of length 0 contains all the same character.
' '   ' of length 3 contains all the same character.
' '2' of length 1 contains all the same character.
' '333' of length 3 contains all the same character.
' '.55' of length 3 is different at position 2: '5' (0x35)
' 'tttTTT' of length 6 is different at position 4: 'T' (0x54)
' '4444 444k' of length 9 is different at position 5: ' ' (0x20)
