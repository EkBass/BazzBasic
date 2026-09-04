' ============================================================
' FindLongestWord
' EkBazz 2026, public domain
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================================

DEF FN FindLongestWord$(sentence$)
    DIM words$
    LET count$ = SPLIT(words$, sentence$, " ")
    LET longestLen$ = 0
    LET longestWord$ = ""
    FOR i$ = 0 TO count$ - 1
        IF LEN(words$(i$)) > longestLen$ THEN
            longestLen$ = LEN(words$(i$))
            longestWord$ = words$(i$)
        END IF
    NEXT
    RETURN longestWord$
END DEF

[inits]
	LET sentence$ = "The quick brown fox jumps over the lazy dog"
	
[main]
    PRINT FN FindLongestWord$(sentence$)
END