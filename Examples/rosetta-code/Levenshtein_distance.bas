' ============================================
' Levenshtein distance (Wagner-Fischer dynamic programming)
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

' Returns the minimum number of single-character insertions,
' deletions and substitutions needed to turn s$ into t$.
' Comparison is case-sensitive (ASC), because BazzBasic's
' string "=" operator ignores case.
DEF FN Levenshtein$(s$, t$)
    LET m$ = LEN(s$)
    LET n$ = LEN(t$)
    LET i$ = 0
    LET j$ = 0
    LET cost$ = 0
    DIM d$

    ' Distance from a prefix to the empty string
    FOR i$ = 0 TO m$ : d$(i$, 0) = i$ : NEXT
    FOR j$ = 0 TO n$ : d$(0, j$) = j$ : NEXT

    FOR j$ = 1 TO n$
        FOR i$ = 1 TO m$
            IF ASC(MID(s$, i$, 1)) = ASC(MID(t$, j$, 1)) THEN
                cost$ = 0
            ELSE
                cost$ = 1
            END IF
            d$(i$, j$) = MIN(d$(i$ - 1, j$) + 1, MIN(d$(i$, j$ - 1) + 1, d$(i$ - 1, j$ - 1) + cost$))
        NEXT
    NEXT

    RETURN d$(m$, n$)
END DEF

[inits]
    DIM pairs$
    pairs$(0, 0) = "kitten"      : pairs$(0, 1) = "sitting"
    pairs$(1, 0) = "rosettacode" : pairs$(1, 1) = "raisethysword"
    pairs$(2, 0) = "saturday"    : pairs$(2, 1) = "sunday"
    pairs$(3, 0) = ""            : pairs$(3, 1) = "abc"
    pairs$(4, 0) = "BazzBasic"   : pairs$(4, 1) = "bazzbasic"
    LET PAIR_COUNT# = 5
    LET k$ = 0

[main]
    FOR k$ = 0 TO PAIR_COUNT# - 1
        PRINT "'"; pairs$(k$, 0); "' -> '"; pairs$(k$, 1); "' = "; FN Levenshtein$(pairs$(k$, 0), pairs$(k$, 1))
    NEXT
END

' Output:
' 'kitten' -> 'sitting' = 3
' 'rosettacode' -> 'raisethysword' = 8
' 'saturday' -> 'sunday' = 3
' '' -> 'abc' = 3
' 'BazzBasic' -> 'bazzbasic' = 2