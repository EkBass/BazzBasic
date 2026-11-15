' ============================================
' Lindenmayer system (L-system) rewriting
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

' Lindenmayer$ prints generations 0..count$ of an L-system.
' rulesJson$ is the rule table serialized with ASJSON, because a
' DEF FN cannot see global arrays. Each key is one symbol and its
' value is the replacement string. Symbols without a rule are copied
' unchanged. Returns the last printed generation.
DEF FN Lindenmayer$(axiom$, rulesJson$, count$)
    DIM rules$
    LET ruleCount$ = ASARRAY(rules$, rulesJson$)
    LET s$   = axiom$
    LET nxt$ = ""
    LET c$   = ""

    FOR i$ = 0 TO count$
        PRINT s$
        IF i$ = count$ THEN EXIT FOR     ' last generation printed, no need to rewrite
        nxt$ = ""
        FOR j$ = 1 TO LEN(s$)
            c$ = MID(s$, j$, 1)
            IF HASKEY(rules$(c$)) THEN
                nxt$ += rules$(c$)
            ELSE
                nxt$ += c$
            END IF
        NEXT
        s$ = nxt$
    NEXT
    RETURN s$
END DEF

[inits]
    DIM rules$
    rules$("I") = "M"
    rules$("M") = "MI"

    LET final$ = ""

[main]
    final$ = FN Lindenmayer$("I", ASJSON(rules$), 5)
END

' Output:
' I
' M
' MI
' MIM
' MIMMI
' MIMMIMIM