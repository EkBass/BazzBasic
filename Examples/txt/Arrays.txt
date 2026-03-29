' ============================================
' https://rosettacode.org/wiki/Arrays
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

' # Task
' Show basic array syntax in your language.
' Basically, create an array, assign a value to it, and retrieve an element   (if available, show both fixed-length arrays and dynamic arrays, pushing a value into it).

' See also for ASARRAY & ASJSON
' - Examples/JSON.bas
' - https://github.com/EkBass/BazzBasic/blob/main/Examples/JSON.bas

' dynamic-array
DIM numbers$

' In BazzBasic, cells do not have value until you give it
FOR i$ = 0 TO 4
	numbers$(i$) = (i$ + 1) * 10
NEXT


' show dynamic-array
PRINT "Numeric array:"
FOR i$ = 0 TO 4
	PRINT "numbers$("; i$; ") = "; numbers$(i$)
NEXT


' associative-array
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

' Output
' Numeric array:
' numbers$(0) = 10
' numbers$(1) = 20
' numbers$(2) = 30
' numbers$(3) = 40
' numbers$(4) = 50

' Associative array:
' Name: Alice
' Age: 30
' City: Helsinki

' 2D array (3x3):
' 0 1 2
' 3 4 5
' 6 7 8
