REM Demonstrate different array types

' Numeric array
DIM numbers$
FOR i$ = 0 TO 4
    numbers$(i$) = (i$ + 1) * 10
NEXT

PRINT "Numeric array:"
FOR i$ = 0 TO 4
    PRINT "numbers$("; i$; ") = "; numbers$(i$)
NEXT

' Associative array
DIM person$
person$("name") = "Alice"
person$("age") = 30
person$("city") = "Helsinki"

PRINT ""
PRINT "Associative array:"
PRINT "Name: "; person$("name")
PRINT "Age: "; person$("age")
PRINT "City: "; person$("city")

' 2D array
DIM grid$
FOR row$ = 0 TO 2
    FOR col$ = 0 TO 2
        grid$(row$, col$) = row$ * 3 + col$
    NEXT
NEXT

PRINT ""
PRINT "2D array (3x3):"
FOR row$ = 0 TO 2
    FOR col$ = 0 TO 2
        PRINT grid$(row$, col$); " ";
    NEXT
    PRINT ""
NEXT
