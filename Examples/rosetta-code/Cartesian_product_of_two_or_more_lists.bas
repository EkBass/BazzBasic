' ============================================
' ROSETTA: https://rosettacode.org/wiki/Cartesian_product_of_two_or_more_lists
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Computes the Cartesian product of two lists and the n-ary product of a list of lists, including the cases with an empty list.
' CATEGORY: algorithms
' TAGS: cartesian product, lists, tuples, asjson
' MINVERSION: 1.5
' ============================================
'
' Representation:
'   list        "1,2"          elements separated by ","
'   tuple list  "1,3;1,4"      tuples separated by ";", elements by ","
'   empty list  ""             the product with an empty list is ""
'
' The n-ary function takes a single argument: a list of lists, passed as
' JSON (arrays cannot be passed to DEF FN directly).

' Extend every tuple with every element of list$ (one step of the product)
DEF FN Extend$(tuples$, list$)
    IF tuples$ = "" OR list$ = "" THEN RETURN ""
    DIM t$, e$
    LET nt$ = SPLIT(t$, tuples$, ";")
    LET ne$ = SPLIT(e$, list$, ",")
    LET out$ = ""
    FOR i$ = 0 TO nt$ - 1
        FOR j$ = 0 TO ne$ - 1
            IF out$ <> "" THEN out$ += ";"
            out$ += t$(i$) + "," + e$(j$)
        NEXT
    NEXT
    RETURN out$
END DEF

' Binary product: every element of a$ becomes a 1-tuple, then extend by b$
DEF FN Cartesian$(a$, b$)
    RETURN FN Extend$(REPLACE(a$, ",", ";"), b$)
END DEF

' N-ary product: fold Extend$ over a JSON list of lists
DEF FN CartesianN$(json$)
    DIM lists$
    LET n$ = ASARRAY(lists$, json$)
    IF n$ = 0 THEN RETURN ""
    LET acc$ = REPLACE(lists$(0), ",", ";")
    FOR i$ = 1 TO n$ - 1
        acc$ = FN Extend$(acc$, lists$(i$))
    NEXT
    RETURN acc$
END DEF

' "1,2" -> "{1, 2}"
DEF FN ShowList$(list$)
    RETURN "{" + REPLACE(list$, ",", ", ") + "}"
END DEF

' "1,3;1,4" -> "{(1, 3), (1, 4)}"
DEF FN ShowTuples$(tuples$)
    IF tuples$ = "" THEN RETURN "{}"
    LET s$ = REPLACE(tuples$, ",", ", ")
    s$ = REPLACE(s$, ";", "), (")
    RETURN "{(" + s$ + ")}"
END DEF

[inits]
    LET a$ = ""
    LET b$ = ""
    LET label$ = ""
    LET json$ = ""
    DIM lists$

[main]
    a$ = "1,2" : b$ = "3,4" : GOSUB [sub:binary]
    a$ = "3,4" : b$ = "1,2" : GOSUB [sub:binary]
    a$ = "1,2" : b$ = ""    : GOSUB [sub:binary]
    a$ = ""    : b$ = "1,2" : GOSUB [sub:binary]
    PRINT

    lists$(0) = "1776,1789"
    lists$(1) = "7,12"
    lists$(2) = "4,14,23"
    lists$(3) = "0,1"
    GOSUB [sub:nary]

    DELARRAY lists$
    DIM lists$
    lists$(0) = "1,2,3"
    lists$(1) = "30"
    lists$(2) = "500,100"
    GOSUB [sub:nary]

    DELARRAY lists$
    DIM lists$
    lists$(0) = "1,2,3"
    lists$(1) = ""
    lists$(2) = "500,100"
    GOSUB [sub:nary]
END

[sub:binary]
    PRINT FN ShowList$(a$); " x "; FN ShowList$(b$); " = "; FN ShowTuples$(FN Cartesian$(a$, b$))
RETURN

[sub:nary]
    label$ = ""
    FOR i$ = 0 TO ROWCOUNT(lists$()) - 1
        IF i$ > 0 THEN label$ += " x "
        label$ += FN ShowList$(lists$(i$))
    NEXT
    json$ = ASJSON(lists$)
    PRINT label$; " = "; FN ShowTuples$(FN CartesianN$(json$))
RETURN

' Output:
' {1, 2} x {3, 4} = {(1, 3), (1, 4), (2, 3), (2, 4)}
' {3, 4} x {1, 2} = {(3, 1), (3, 2), (4, 1), (4, 2)}
' {1, 2} x {} = {}
' {} x {1, 2} = {}
'
' {1776, 1789} x {7, 12} x {4, 14, 23} x {0, 1} = {(1776, 7, 4, 0), (1776, 7, 4, 1), (1776, 7, 14, 0), (1776, 7, 14, 1), (1776, 7, 23, 0), (1776, 7, 23, 1), (1776, 12, 4, 0), (1776, 12, 4, 1), (1776, 12, 14, 0), (1776, 12, 14, 1), (1776, 12, 23, 0), (1776, 12, 23, 1), (1789, 7, 4, 0), (1789, 7, 4, 1), (1789, 7, 14, 0), (1789, 7, 14, 1), (1789, 7, 23, 0), (1789, 7, 23, 1), (1789, 12, 4, 0), (1789, 12, 4, 1), (1789, 12, 14, 0), (1789, 12, 14, 1), (1789, 12, 23, 0), (1789, 12, 23, 1)}
' {1, 2, 3} x {30} x {500, 100} = {(1, 30, 500), (1, 30, 100), (2, 30, 500), (2, 30, 100), (3, 30, 500), (3, 30, 100)}
' {1, 2, 3} x {} x {500, 100} = {}
