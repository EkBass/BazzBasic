' ============================================
' https://rosettacode.org/wiki/Greatest_element_of_a_list
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' Arrays can't be passed to DEF FN directly, so the list travels
' as a JSON string and is rebuilt inside the function.

DEF FN FindMax$(json$)
    DIM values$
    LET count$ = ASARRAY(values$, json$)
    LET max$ = values$(ARRKEY(values$(), 0))
    FOR i$ = 1 TO count$ - 1
        max$ = MAX(max$, values$(ARRKEY(values$(), i$)))
    NEXT
    RETURN max$
END DEF

[inits]
    DIM list$
    LET size$ = RND(10) + 5         ' 5..14 values, decided at run-time

[main]
    FOR i$ = 0 TO size$ - 1
        list$(i$) = RND(201) - 100  ' -100..100
        PRINT list$(i$); " ";
    NEXT
    PRINT ""
    PRINT "Greatest element: "; FN FindMax$(ASJSON(list$))
END

' Output (random, example run):
' -12 -51 -34 -61 89 82 94 -17 -20 -86
' Greatest element: 94
