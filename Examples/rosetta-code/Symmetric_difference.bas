' ==================================================================
' Symmetric difference (BazzBasic solution)
' Rosetta Code: https://rosettacode.org/wiki/Symmetric_difference
' ==================================================================

' The symmetric difference of two sets is the collection of elements
' that belong to either set but not to both.
' Duplicates within a set are ignored (set semantics).

[inits]
    DIM a$, b$, result$, seen$
    LET ai$, bi$, ri$, n$, found$

    ' Set A
    a$(0) = "John"
    a$(1) = "Bob"
    a$(2) = "Mary"
    a$(3) = "Serena"

    ' Set B — contains "Jim" twice to demonstrate duplicate handling
    b$(0) = "Jim"
    b$(1) = "Mary"
    b$(2) = "John"
    b$(3) = "Bob"
    b$(4) = "Jim"

    LET lenA$ = 4
    LET lenB$ = 5
    LET ri$   = 0

[main]
    ' Elements in A not found in B
    FOR ai$ = 0 TO lenA$ - 1
        found$ = FALSE
        FOR bi$ = 0 TO lenB$ - 1
            IF a$(ai$) = b$(bi$) THEN found$ = TRUE
        NEXT
        IF found$ = FALSE THEN
            IF HASKEY(seen$(a$(ai$))) = 0 THEN
                result$(ri$) = a$(ai$)
                seen$(a$(ai$)) = 1
                ri$ = ri$ + 1
            END IF
        END IF
    NEXT

    ' Elements in B not found in A
    FOR bi$ = 0 TO lenB$ - 1
        found$ = FALSE
        FOR ai$ = 0 TO lenA$ - 1
            IF b$(bi$) = a$(ai$) THEN found$ = TRUE
        NEXT
        IF found$ = FALSE THEN
            IF HASKEY(seen$(b$(bi$))) = 0 THEN
                result$(ri$) = b$(bi$)
                seen$(b$(bi$)) = 1
                ri$ = ri$ + 1
            END IF
        END IF
    NEXT

    PRINT "Symmetric difference of A and B:"
    FOR n$ = 0 TO ri$ - 1
        PRINT result$(n$)
    NEXT

END

' Expected output:
' Symmetric difference of A and B:
' Serena
' Jim
