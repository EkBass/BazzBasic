' ============================================
' https://rosettacode.org/wiki/Gray_code
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' Binary reflected Gray code. BazzBasic has no bitwise operators,
' so XOR is done arithmetically, one bit at a time.

DEF FN Xor$(a$, b$)
    LET result$ = 0
    LET bit$ = 1
    WHILE a$ > 0 OR b$ > 0
        IF MOD(a$, 2) <> MOD(b$, 2) THEN result$ += bit$
        a$ = INT(a$ / 2)
        b$ = INT(b$ / 2)
        bit$ *= 2
    WEND
    RETURN result$
END DEF

' g = b XOR (b >> 1)
DEF FN GrayEncode$(n$)
    RETURN FN Xor$(n$, INT(n$ / 2))
END DEF

' b = g XOR (g >> 1) XOR (g >> 2) XOR ...
DEF FN GrayDecode$(g$)
    LET result$ = g$
    LET shift$ = INT(g$ / 2)
    WHILE shift$ > 0
        result$ = FN Xor$(result$, shift$)
        shift$ = INT(shift$ / 2)
    WEND
    RETURN result$
END DEF

DEF FN ToBinary$(n$)
    IF n$ = 0 THEN RETURN "0"
    LET s$ = ""
    WHILE n$ > 0
        s$ = MOD(n$, 2) + s$
        n$ = INT(n$ / 2)
    WEND
    RETURN s$
END DEF

DEF FN PadRight$(s$, w$)
    RETURN s$ + REPEAT(" ", w$ - LEN(s$))
END DEF

[inits]
    LET enc$ = 0
    LET dec$ = 0

[main]
    FOR i$ = 0 TO 31
        enc$ = FN GrayEncode$(i$)
        dec$ = FN GrayDecode$(enc$)
        PRINT RIGHT(" " + i$, 2); ": ";
        PRINT FN PadRight$(FN ToBinary$(i$), 5); " => ";
        PRINT FN PadRight$(FN ToBinary$(enc$), 5); " => ";
        PRINT FN PadRight$(FN ToBinary$(dec$), 5); " => ";
        PRINT RIGHT(" " + dec$, 2)
    NEXT
END

' Output:
'  0: 0     => 0     => 0     =>  0
'  1: 1     => 1     => 1     =>  1
'  2: 10    => 11    => 10    =>  2
'  3: 11    => 10    => 11    =>  3
'  4: 100   => 110   => 100   =>  4
'  5: 101   => 111   => 101   =>  5
'  6: 110   => 101   => 110   =>  6
'  7: 111   => 100   => 111   =>  7
'  8: 1000  => 1100  => 1000  =>  8
'  9: 1001  => 1101  => 1001  =>  9
' 10: 1010  => 1111  => 1010  => 10
' 11: 1011  => 1110  => 1011  => 11
' 12: 1100  => 1010  => 1100  => 12
' 13: 1101  => 1011  => 1101  => 13
' 14: 1110  => 1001  => 1110  => 14
' 15: 1111  => 1000  => 1111  => 15
' 16: 10000 => 11000 => 10000 => 16
' 17: 10001 => 11001 => 10001 => 17
' 18: 10010 => 11011 => 10010 => 18
' 19: 10011 => 11010 => 10011 => 19
' 20: 10100 => 11110 => 10100 => 20
' 21: 10101 => 11111 => 10101 => 21
' 22: 10110 => 11101 => 10110 => 22
' 23: 10111 => 11100 => 10111 => 23
' 24: 11000 => 10100 => 11000 => 24
' 25: 11001 => 10101 => 11001 => 25
' 26: 11010 => 10111 => 11010 => 26
' 27: 11011 => 10110 => 11011 => 27
' 28: 11100 => 10010 => 11100 => 28
' 29: 11101 => 10011 => 11101 => 29
' 30: 11110 => 10001 => 11110 => 30
' 31: 11111 => 10000 => 11111 => 31
