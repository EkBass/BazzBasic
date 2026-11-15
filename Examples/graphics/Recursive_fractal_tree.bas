' ============================================
' BazzBasic: https://github.com/EkBass/BazzBasic
' DESCRIPTION: 
'   Recursive fractal tree: each branch splits into two shorter ones
'   (75 %, +-30 degrees); brown trunk, green leaves.
'   Translated from micro(A) by Aurel.
' TAGS: fractal, recursion, tree, DEF FN, graphics, LINE
' ============================================

DEF FN drawTree$(x$, y$, length$, angle$)
    ' Lokalno definirane varijable na stogu funkcije
    LET xEnd$ = 0
    LET yEnd$ = 0
    LET col$ = 0
    LET dummy$

    IF length$ > 5 THEN
        IF length$ < 15 THEN
            ' Zeleno lisce na krajevima
            col$ = RGB(50, 220, 50)
        ELSE
            ' Smede deblo i vece grane
            col$ = RGB(139, 69, 19)
        END IF

        ' Izracun kraja linije pomocu kuta u radijanima (PI# je ugradena konstanta)
        xEnd$ = x$ + length$ * COS(angle$ * PI# / 180)
        yEnd$ = y$ + length$ * SIN(angle$ * PI# / 180)

        ' Nacrtaj trenutnu granu
        LINE (x$, y$)-(xEnd$, yEnd$), col$

        ' Rekurzivni pozivi za lijevu i desnu granu
        dummy$ = FN drawTree$(xEnd$, yEnd$, length$ * 0.75, angle$ - 30)
        dummy$ = FN drawTree$(xEnd$, yEnd$, length$ * 0.75, angle$ + 30)
    END IF

    RETURN 0
END DEF

[inits]
    LET result$, wks$

[main]
    ' Otvara SDL2 prozor 800x600 (ekvivalent micro(A) mode 1) s crnom pozadinom
    SCREEN 0, 800, 600, "Fraktalno Stablo"

    ' Pocetne koordinate (dno ekrana, duljina 100, kut -90 stupnjeva prema gore)
    result$ = FN drawTree$(400, 550, 100, -90)

    ' Ceka pritisak tipke prije zatvaranja prozora
    wks$ = WAITKEY()
END