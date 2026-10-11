' ============================================
' https://rosettacode.org/wiki/Create_a_two-dimensional_array_at_runtime
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' BazzBasic arrays have no declared size: DIM only names the array,
' and every index comes into existence when it is first assigned.
' To give the array a real rows x cols shape decided at runtime,
' we build it explicitly from the user's input.

[inits]
    LET rows$    = 0
    LET cols$    = 0
    LET lastRow$ = 0
    LET lastCol$ = 0
    LET cells$   = 0
    LET rowCnt$  = 0
    DIM grid$

[main]
    INPUT "Enter two positive integers (rows, cols): ", rows$, cols$
    rows$ = VAL(rows$)
    cols$ = VAL(cols$)
    IF rows$ < 1 OR cols$ < 1 OR
       rows$ <> INT(rows$) OR cols$ <> INT(cols$) THEN
        PRINT "Both values must be positive integers."
        GOTO [main]
    END IF

    ' Create the array: rows x cols cells, all zero
    FOR r$ = 0 TO rows$ - 1
        FOR c$ = 0 TO cols$ - 1
            grid$(r$, c$) = 0
        NEXT c$
    NEXT r$

    cells$  = LEN(grid$())
    rowCnt$ = ROWCOUNT(grid$())
    PRINT FSTRING("Created a {{-rows$-}} x {{-cols$-}} array ({{-cells$-}} cells, {{-rowCnt$-}} rows)")

    ' Write one element, then read it back
    lastRow$ = rows$ - 1
    lastCol$ = cols$ - 1
    grid$(lastRow$, lastCol$) = rows$ * cols$
    PRINT FSTRING("grid({{-lastRow$-}}, {{-lastCol$-}}) = {{-grid$(lastRow$, lastCol$)-}}")

    ' Destroy the array
    DELARRAY grid$
    PRINT "Array destroyed."
END

' Output:
' Enter two positive integers (rows, cols): 3, 4
' Created a 3 x 4 array (12 cells, 3 rows)
' grid(2, 3) = 12
' Array destroyed.