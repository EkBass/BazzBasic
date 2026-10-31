' ============================================
' ROSETTA: https://rosettacode.org/wiki/Find_if_a_point_is_within_a_triangle
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Tests whether given points lie strictly inside a triangle using barycentric coordinates and prints inside or outside for each point.
' CATEGORY: math
' TAGS: triangle, point in triangle, barycentric coordinates, geometry
' MINVERSION: 1.5
' ============================================

' Barycentric test. Returns TRUE if P is strictly inside triangle ABC.
' Swap INBETWEEN for BETWEEN to count points on the edges as inside.
DEF FN InTriangle$(px$, py$, ax$, ay$, bx$, by$, cx$, cy$)
    LET det$ = (by$ - cy$) * (ax$ - cx$) + (cx$ - bx$) * (ay$ - cy$)
    IF det$ = 0 THEN RETURN FALSE       ' degenerate triangle, no area
    LET wa$ = ((by$ - cy$) * (px$ - cx$) + (cx$ - bx$) * (py$ - cy$)) / det$
    LET wb$ = ((cy$ - ay$) * (px$ - cx$) + (ax$ - cx$) * (py$ - cy$)) / det$
    LET wc$ = 1 - wa$ - wb$
    RETURN INBETWEEN(wa$, 0, 1) AND INBETWEEN(wb$, 0, 1) AND INBETWEEN(wc$, 0, 1)
END DEF

[inits]
    LET AX# = 1.5
    LET AY# = 2.4
    LET BX# = 5.1
    LET BY# = -3.1
    LET CX# = -3.8
    LET CY# = 1.2

    DIM pts$
    pts$(0, 0) = 0 : pts$(0, 1) = 0
    pts$(1, 0) = 0 : pts$(1, 1) = 1
    pts$(2, 0) = 3 : pts$(2, 1) = 1

    LET px$      = 0
    LET py$      = 0
    LET verdict$ = ""

[main]
    PRINT "Triangle A("; AX#; ", "; AY#; ")  B("; BX#; ", "; BY#; ")  C("; CX#; ", "; CY#; ")"
    FOR i$ = 0 TO ROWCOUNT(pts$()) - 1
        px$ = pts$(i$, 0)
        py$ = pts$(i$, 1)
        IF FN InTriangle$(px$, py$, AX#, AY#, BX#, BY#, CX#, CY#) THEN
            verdict$ = "inside"
        ELSE
            verdict$ = "outside"
        END IF
        PRINT FSTRING("Point ({{-px$-}}, {{-py$-}}) is {{-verdict$-}}")
    NEXT
END

' Output:
' Triangle A(1.5, 2.4)  B(5.1, -3.1)  C(-3.8, 1.2)
' Point (0, 0) is inside
' Point (0, 1) is inside
' Point (3, 1) is outside