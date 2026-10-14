' BazzBasic version 1.3
' https://ekbass.github.io/BazzBasic/
' ============================================================
' 3D Starfield
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

    ' Parallel arrays — one slot per star
    DIM t$          ' Current age / distance multiplier
    DIM sx$         ' X direction component  (-1 to 1)
    DIM sy$         ' Y direction component  (-1 to 1)

    ' Draw buffer arrays — computed each frame, used only in SCREENLOCK block
    DIM ox$         ' Old X to erase
    DIM oy$         ' Old Y to erase
    DIM nx$         ' New X to draw
    DIM ny$         ' New Y to draw
    DIM nb$         ' New brightness (0-255)
    DIM dm$         ' Draw mode: 0=skip, 1=erase only, 2=erase+draw

    ' Working variables
    LET running$ = TRUE

    ' Scatter stars at random ages so screen fills immediately
    FOR i$ = 0 TO STAR_COUNT# - 1
        t$(i$)  = RND(400) + 30
        sx$(i$) = -1 + RND(0) * 2
        sy$(i$) = -1 + RND(0) * 2
    NEXT

' ---- MAIN LOOP ----------------------------------------
[main]
    WHILE running$
        IF INKEY = KEY_ESC# THEN running$ = FALSE
        GOSUB [sub:update]
        SLEEP 16
    WEND
END

' ---- SUBROUTINES ----------------------------------------
[sub:update]

    ' Phase 1: compute all positions BEFORE locking the screen
    FOR i$ = 0 TO STAR_COUNT# - 1
        IF t$(i$) = 0 THEN
            t$(i$)  = 30
            sx$(i$) = -1 + RND(0) * 2
            sy$(i$) = -1 + RND(0) * 2
            dm$(i$) = 0

        ELSEIF t$(i$) < MAX_T# THEN
            ox$(i$) = CX# + (t$(i$) - 1) * sx$(i$)
            oy$(i$) = CY# + (t$(i$) - 1) * sy$(i$)
            nx$(i$) = CX# + t$(i$) * sx$(i$)
            ny$(i$) = CY# + t$(i$) * sy$(i$)
            nb$(i$) = CINT(t$(i$) / MAX_T# * 255)
            t$(i$)  = t$(i$) + 1
            dm$(i$) = 2

        ELSE
            ox$(i$) = CX# + (t$(i$) - 1) * sx$(i$)
            oy$(i$) = CY# + (t$(i$) - 1) * sy$(i$)
            t$(i$)  = 0
            dm$(i$) = 1
        END IF
    NEXT

    ' Phase 2: draw inside SCREENLOCK — only PSET calls, no math
    SCREENLOCK ON
        FOR i$ = 0 TO STAR_COUNT# - 1
            IF dm$(i$) >= 1 THEN PSET (ox$(i$), oy$(i$)), 0
            IF dm$(i$) = 2 THEN PSET (nx$(i$), ny$(i$)), RGB(nb$(i$), nb$(i$), nb$(i$))
        NEXT
    SCREENLOCK OFF

RETURN
