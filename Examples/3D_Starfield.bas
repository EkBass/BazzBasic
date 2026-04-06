' ============================================================
' 3D Starfield — BazzBasic v1.1
' Original QBasic version by Antti Laaksonen (2002)
' https://www.ohjelmointiputka.net/koodivinkit/23485-qb-avaruuslento
'
' Ported and extended for BazzBasic
' ============================================================

[inits]
    SCREEN 12

	LET STAR_COUNT# = 500
	LET CX#         = 320       ' Center X  (screen width  / 2)
	LET CY#         = 240       ' Center Y  (screen height / 2)
	LET MAX_T#      = 400       ' Distance limit before star resets
    ' Parallel arrays — one slot per star per field
	
    DIM t$          ' Current age / distance multiplier
    DIM sx$         ' X direction component  (-1 to 1)
    DIM sy$         ' Y direction component  (-1 to 1)

    ' Working variables — declared here, not inside the loop
    LET running$    = TRUE
    LET bright$     = 0
    LET oldX$       = 0
    LET oldY$       = 0
    LET newX$       = 0
    LET newY$       = 0

    ' Scatter stars at random ages so screen fills immediately
    FOR i$ = 0 TO STAR_COUNT# - 1
        t$(i$)  = RND(400) + 30
        sx$(i$) = -1 + RND(0) * 2
        sy$(i$) = -1 + RND(0) * 2
    NEXT

' ---- 3. MAIN LOOP ------------------------------------------
[main]
    WHILE running$
        IF INKEY = KEY_ESC# THEN running$ = FALSE
        GOSUB [sub:update]
        SLEEP 16
    WEND
END

' ---- 4. SUBROUTINES ----------------------------------------
[sub:update]
    SCREENLOCK ON

    FOR i$ = 0 TO STAR_COUNT# - 1

    IF t$(i$) = 0 THEN
            t$(i$)  = 30
            sx$(i$) = -1 + RND(0) * 2
            sy$(i$) = -1 + RND(0) * 2

        ELSEIF t$(i$) < MAX_T# THEN
            ' ---- ERASE old pixel ----
            oldX$ = CX# + (t$(i$) - 1) * sx$(i$)
            oldY$ = CY# + (t$(i$) - 1) * sy$(i$)
            PSET (oldX$, oldY$), 0

            ' ---- DRAW new pixel, brighter the further it is ----
            newX$   = CX# + t$(i$) * sx$(i$)
            newY$   = CY# + t$(i$) * sy$(i$)
            bright$ = CINT(t$(i$) / MAX_T# * 255)
            PSET (newX$, newY$), RGB(bright$, bright$, bright$)

            t$(i$) = t$(i$) + 1

        ELSE
            ' Star has left the screen — erase its last pixel, flag for reset
            oldX$ = CX# + (t$(i$) - 1) * sx$(i$)
            oldY$ = CY# + (t$(i$) - 1) * sy$(i$)
            PSET (oldX$, oldY$), 0
            t$(i$) = 0
        END IF

    NEXT

    SCREENLOCK OFF
RETURN