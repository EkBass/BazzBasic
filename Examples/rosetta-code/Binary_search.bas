' ============================================
' ROSETTA: https://rosettacode.org/wiki/Binary_search
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Searches a sorted integer array for a value with iterative and recursive binary search and reports the index or that the value was not found.
' CATEGORY: algorithms
' TAGS: binary search, recursion, sorted array, asjson
' MINVERSION: 1.5
' ============================================
' Task: binary search a sorted integer array, iteratively and
'       recursively, and report whether the value was found and where.

' Iterative version. Returns the index of value$, or -1 if not found.
DEF FN BSearchIter$(json$, value$)
    DIM a$
    LET n$ = ASARRAY(a$, json$)
    LET low$ = 0
    LET high$ = n$ - 1
    LET mid$ = 0
    LET result$ = -1
    WHILE low$ <= high$ AND result$ = -1
        mid$ = low$ + INT((high$ - low$) / 2)     ' overflow-safe midpoint
        IF a$(mid$) > value$ THEN
            high$ = mid$ - 1
        ELSEIF a$(mid$) < value$ THEN
            low$ = mid$ + 1
        ELSE
            result$ = mid$
        END IF
    WEND
    RETURN result$
END DEF

' Recursive version. Initially called with low$ = 0, high$ = N - 1.
DEF FN BSearchRec$(json$, value$, low$, high$)
    IF high$ < low$ THEN RETURN -1
    DIM a$
    LET n$ = ASARRAY(a$, json$)
    LET mid$ = low$ + INT((high$ - low$) / 2)
    IF a$(mid$) > value$ THEN RETURN FN BSearchRec$(json$, value$, low$, mid$ - 1)
    IF a$(mid$) < value$ THEN RETURN FN BSearchRec$(json$, value$, mid$ + 1, high$)
    RETURN mid$
END DEF

[inits]
    DIM raw$, data$
    LET count$ = SPLIT(raw$, "-31,0,1,2,2,4,65,83,99,782", ",")
    FOR i$ = 0 TO count$ - 1
        data$(i$) = VAL(raw$(i$))       ' numbers, so < and > compare numerically
    NEXT
    LET json$ = ASJSON(data$)
    LET value$ = 0
    LET idx$ = 0
    LET method$ = ""

[main]
    value$ = 2
    method$ = "Iterative"
    idx$ = FN BSearchIter$(json$, value$)
    GOSUB [sub:Report]
    method$ = "Recursive"
    idx$ = FN BSearchRec$(json$, value$, 0, count$ - 1)
    GOSUB [sub:Report]

    value$ = 5
    method$ = "Iterative"
    idx$ = FN BSearchIter$(json$, value$)
    GOSUB [sub:Report]
    method$ = "Recursive"
    idx$ = FN BSearchRec$(json$, value$, 0, count$ - 1)
    GOSUB [sub:Report]
END

[sub:Report]
    IF idx$ >= 0 THEN
        PRINT method$; ": "; value$; " is at index "; idx$; "."
    ELSE
        PRINT method$; ": "; value$; " is not found."
    END IF
RETURN

' Output:
' Iterative: 2 is at index 4.
' Recursive: 2 is at index 4.
' Iterative: 5 is not found.
' Recursive: 5 is not found.