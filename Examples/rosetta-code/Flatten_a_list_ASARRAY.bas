' ============================================
' ROSETTA: https://rosettacode.org/wiki/Flatten_a_list
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Flattens a nested list by parsing it as JSON with ASARRAY and reading the leaf values in order.
' CATEGORY: algorithms
' TAGS: flatten list, nested data, asarray, json
' MINVERSION: 1.5
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
