' ============================================
' ROSETTA: https://rosettacode.org/wiki/Dragon_curve
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Draws the Heighway dragon curve (12 levels) in a 640x480 window using the paper-folding turn sequence, scaled to fit the window, and waits for a key press.
' CATEGORY: drawing
' TAGS: dragon curve, fractal, paper folding, line
' MINVERSION: 1.5
' ============================================

[inits]
    LET LEVEL#    = 12
    LET SEGMENTS# = POW(2, LEVEL#)
    LET SCREEN_W# = 640
    LET SCREEN_H# = 480
    LET MARGIN#   = 20
    LET COLOR_BG# = 0
    LET COLOR_FG# = RGB(255, 200, 0)

    ' Unit steps for the four headings: right, down, left, up
    DIM dx$, dy$
    dx$(0) = 1
    dy$(0) = 0
    dx$(1) = 0
    dy$(1) = 1
    dx$(2) = -1
    dy$(2) = 0
    dx$(3) = 0
    dy$(3) = -1

    LET x$       = 0
    LET y$       = 0
    LET nx$      = 0
    LET ny$      = 0
    LET dir$     = 0
    LET k$       = 0
    LET minX$    = 0
    LET maxX$    = 0
    LET minY$    = 0
    LET maxY$    = 0
    LET scale$   = 0
    LET offX$    = 0
    LET offY$    = 0
    LET drawing$ = FALSE
    LET wkv$     = 0

[main]
    ' Pass 1: measure the curve
    GOSUB [sub:walk]

    ' Fit the curve to the window and center it
    scale$ = MIN((SCREEN_W# - 2 * MARGIN#) / (maxX$ - minX$),
                 (SCREEN_H# - 2 * MARGIN#) / (maxY$ - minY$))
    offX$ = (SCREEN_W# - (maxX$ - minX$) * scale$) / 2 - minX$ * scale$
    offY$ = (SCREEN_H# - (maxY$ - minY$) * scale$) / 2 - minY$ * scale$

    ' Pass 2: draw it
    SCREEN 0, SCREEN_W#, SCREEN_H#, "Dragon curve"
    SCREENLOCK ON
    LINE (0, 0)-(SCREEN_W#, SCREEN_H#), COLOR_BG#, BF
    drawing$ = TRUE
    GOSUB [sub:walk]
    SCREENLOCK OFF

    wkv$ = WAITKEY()
END

[sub:walk]
    x$   = 0
    y$   = 0
    dir$ = 0
    FOR n$ = 1 TO SEGMENTS#
        nx$ = x$ + dx$(dir$)
        ny$ = y$ + dy$(dir$)

        IF drawing$ THEN
            LINE (offX$ + x$ * scale$, offY$ + y$ * scale$)-(offX$ + nx$ * scale$, offY$ + ny$ * scale$), COLOR_FG#
        ELSE
            minX$ = MIN(minX$, nx$)
            maxX$ = MAX(maxX$, nx$)
            minY$ = MIN(minY$, ny$)
            maxY$ = MAX(maxY$, ny$)
        END IF

        x$ = nx$
        y$ = ny$

        ' Paper-folding rule: strip factors of 2 from n, then n MOD 4 decides the turn
        IF n$ < SEGMENTS# THEN
            k$ = n$
            WHILE MOD(k$, 2) = 0
                k$ = k$ / 2
            WEND
            IF MOD(k$, 4) = 1 THEN
                dir$ = MOD(dir$ + 1, 4)
            ELSE
                dir$ = MOD(dir$ + 3, 4)
            END IF
        END IF
    NEXT
RETURN