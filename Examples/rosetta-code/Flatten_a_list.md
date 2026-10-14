# Version 1: real nested data through ASARRAY

```basic
' ============================================
' https://rosettacode.org/wiki/Flatten_a_list
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

' ASARRAY turns nested JSON into one level of path keys,
' e.g. "2,0,1" -> 4, and drops empty lists. Its values, read
' in insertion order, are the flattened list.
DEF FN Flatten$(json$)
    DIM tree$
    LET count$ = ASARRAY(tree$, json$)
    LET out$   = ""
    FOR i$ = 0 TO count$ - 1
        IF i$ > 0 THEN out$ += ", "
        out$ += tree$(ARRKEY(tree$(), i$))
    NEXT
    RETURN "[" + out$ + "]"
END DEF

[inits]
    LET list$ = "[[1], 2, [[3, 4], 5], [[[]]], [[[6]]], 7, 8, []]"

[main]
    PRINT "Nested:    "; list$
    PRINT "Flattened: "; FN Flatten$(list$)
END

' Output:
' Nested:    [[1], 2, [[3, 4], 5], [[[]]], [[[6]]], 7, 8, []]
' Flattened: [1, 2, 3, 4, 5, 6, 7, 8]
```

# Version 2: scanning the text, in the spirit of your Balanced brackets entry

```basic
' ============================================
' https://rosettacode.org/wiki/Flatten_a_list
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

' Scans the list text and collects every run of characters that is
' not a bracket, comma or space. Each run is one value, so multi-digit
' and negative numbers survive intact.
DEF FN Flatten$(s$)
    LET src$ = s$ + ","             ' sentinel closes a trailing value
    LET out$ = ""
    LET tok$ = ""
    LET ch$  = ""
    FOR i$ = 1 TO LEN(src$)
        ch$ = MID(src$, i$, 1)
        IF INSTR("[], ", ch$) = 0 THEN
            tok$ += ch$
        ELSEIF tok$ <> "" THEN
            IF out$ <> "" THEN out$ += ", "
            out$ += tok$
            tok$ = ""
        END IF
    NEXT
    RETURN "[" + out$ + "]"
END DEF

[inits]
    LET list$ = "[[1], 2, [[3, 4], 5], [[[]]], [[[6]]], 7, 8, []]"

[main]
    PRINT "Nested:    "; list$
    PRINT "Flattened: "; FN Flatten$(list$)
    PRINT "Bigger:    "; FN Flatten$("[[10, [-20]], [], [[300]], 4000]")
END

' Output:
' Nested:    [[1], 2, [[3, 4], 5], [[[]]], [[[6]]], 7, 8, []]
' Flattened: [1, 2, 3, 4, 5, 6, 7, 8]
' Bigger:    [10, -20, 300, 4000]
```