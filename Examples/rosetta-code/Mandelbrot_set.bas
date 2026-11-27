' https://ekbass.github.io/BazzBasic/
' https://rosettacode.org/wiki/Mandelbrot_set

[inits]
    LET SCREEN_W# = 640
    LET SCREEN_H# = 480
    LET TITLE# = "Mandelbrot set"
    LET MAXITER# = 250
    LET RE_MIN# = -2.5
    LET RE_SPAN# = 3.5
    LET IM_TOP# = 1.25
    LET IM_SPAN# = 2.5
    DIM pal$
    FOR i$ = 0 TO MAXITER#
        LET t$ = i$ / MAXITER#
        IF t$ < 1 / 3 THEN
            LET u$ = t$ * 3
            pal$(i$) = RGB(0, INT(LERP(0, 255, u$)), INT(LERP(139, 255, u$)))
        ELSEIF t$ < 2 / 3 THEN
            LET u$ = (t$ - 1 / 3) * 3
            pal$(i$) = RGB(INT(LERP(0, 255, u$)), 255, 255)
        ELSE
            LET u$ = (t$ - 2 / 3) * 3
            pal$(i$) = RGB(255, INT(LERP(255, 165, u$)), INT(LERP(255, 0, u$)))
        END IF
    NEXT
    DIM it$
    LET selftest$ = FALSE
    IF ARGCOUNT >= 1 THEN
        IF SAME(ARGS(0), "selftest") THEN selftest$ = TRUE
    END IF
    LET x$ = 0
    LET y$ = 0
    LET re$ = 0
    LET im$ = 0
    LET zr$ = 0
    LET zi$ = 0
    LET zn$ = 0
    LET k$ = 0
    LET kk$ = 0
    LET interior$ = 0
    LET t0$ = 0
    LET b0$ = 0
    LET renderMs$ = 0
    LET blitMs$ = 0
    LET report$ = ""

[main]
    IF selftest$ THEN
        GOSUB [selftest:compute]
        PRINT "Mandelbrot selftest"
        PRINT "pixels in set: " + interior$
        PRINT "render ms: " + renderMs$
        LET report$ = "Mandelbrot selftest report\n" +
            "screen: " + SCREEN_W# + "x" + SCREEN_H# + "\n" +
            "region: real " + RE_MIN# + ".." + (RE_MIN# + RE_SPAN#) + ", imag " + (IM_TOP# - IM_SPAN#) + ".." + IM_TOP# + "\n" +
            "maxiter: " + MAXITER# + "\n" +
            "pixels in set: " + interior$ + "\n" +
            "render ms: " + renderMs$ + "\n"
        FILEWRITE "selftest/report.txt", report$
        GOSUB [selftest:blit]
    ELSE
        GOSUB [interactive:run]
    END IF
END

[sub:escape]    ' in: re$, im$   out: k$ (k$ > MAXITER# = interior)
    LET zr$ = 0
    LET zi$ = 0
    LET k$ = 0
    WHILE zr$ * zr$ + zi$ * zi$ <= 4 AND k$ <= MAXITER#
        LET zn$ = zr$ * zr$ - zi$ * zi$ + re$
        zi$ = 2 * zr$ * zi$ + im$
        zr$ = zn$
        k$ = k$ + 1
    WEND
RETURN

[selftest:compute]    ' fills it$(x,y) for ALL 640x480 (lower half mirrored), counts interior, measures with TICKS
    LET t0$ = TICKS
    LET interior$ = 0
    FOR y$ = 0 TO 239
        FOR x$ = 0 TO 639
            LET re$ = RE_MIN# + RE_SPAN# * x$ / 639
            LET im$ = IM_TOP# - IM_SPAN# * y$ / 479
            GOSUB [sub:escape]
            it$(x$, y$) = k$
            it$(x$, 479 - y$) = k$
            IF k$ > MAXITER# THEN interior$ = interior$ + 2
        NEXT
    NEXT
    LET renderMs$ = TICKS - t0$
RETURN

[selftest:blit]
    SCREEN 0, SCREEN_W#, SCREEN_H#, TITLE#
    SCREENLOCK ON
    LET b0$ = TICKS
    FOR y$ = 0 TO 239
        FOR x$ = 0 TO 639
            LET kk$ = CINT(it$(x$, y$))
            IF kk$ > MAXITER# THEN
                PSET (x$, y$), BLACK#
                PSET (x$, 479 - y$), BLACK#
            ELSE
                PSET (x$, y$), pal$(kk$)
                PSET (x$, 479 - y$), pal$(kk$)
            END IF
        NEXT
    NEXT
    LET blitMs$ = TICKS - b0$
    SAVESCREEN "selftest/mandelbrot.png"
    SCREENLOCK OFF
    FILEAPPEND "selftest/report.txt", "blit ms: " + blitMs$ + "\n"
RETURN

[interactive:run]
    SCREEN 0, SCREEN_W#, SCREEN_H#, TITLE#
    SCREENLOCK ON
    FOR y$ = 0 TO 239
        FOR x$ = 0 TO 639
            LET re$ = RE_MIN# + RE_SPAN# * x$ / 639
            LET im$ = IM_TOP# - IM_SPAN# * y$ / 479
            GOSUB [sub:escape]
            LET kk$ = CINT(k$)
            IF kk$ > MAXITER# THEN
                PSET (x$, y$), BLACK#
                PSET (x$, 479 - y$), BLACK#
            ELSE
                PSET (x$, y$), pal$(kk$)
                PSET (x$, 479 - y$), pal$(kk$)
            END IF
        NEXT
    NEXT
    DRAWSTRING "Mandelbrot set - ESC to quit", 8, 8, WHITE#
    SCREENLOCK OFF
    WHILE KEYDOWN(KEY_ESC#) = FALSE
        SCREENLOCK ON
        SCREENLOCK OFF
    WEND
RETURN
