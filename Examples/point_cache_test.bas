' ============================================
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Regression test (30.10.2026) for the POINT pixel cache and SAVESCREEN: draws with PSET, LINE, CIRCLE and DRAWSHAPE, checks the colors POINT reads back and writes OK/FAIL lines to point_cache_test.log.
' CATEGORY: drawing
' TAGS: regression test, point, savescreen, pixel cache
' MINVERSION: 1.5
' ============================================
' Results go to point_cache_test.log (PRINT would go to the graphics window)

[inits]
    LET RED# = RGB(255, 0, 0)
    LET GREEN# = RGB(0, 255, 0)
    LET BLUE# = RGB(0, 0, 255)
    LET log$ = ""
    LET pass$ = 0, fail$ = 0
    LET name$, expect$, got$

    SCREEN 0, 320, 200, "POINT cache test"

[main]
    PSET (10, 10), RED#
    name$ = "PSET red (first read fills cache)"
    expect$ = 16711680 : got$ = POINT(10, 10) : GOSUB [check]

    PSET (11, 10), GREEN#
    name$ = "PSET green (write-through)"
    expect$ = 65280 : got$ = POINT(11, 10) : GOSUB [check]

    name$ = "earlier pixel still red"
    expect$ = 16711680 : got$ = POINT(10, 10) : GOSUB [check]

    LINE (0, 20)-(100, 20), BLUE#
    name$ = "LINE invalidates cache"
    expect$ = 255 : got$ = POINT(50, 20) : GOSUB [check]

    LINE (0, 30)-(50, 60), 15, BF
    name$ = "LINE BF palette white"
    expect$ = 16777215 : got$ = POINT(25, 45) : GOSUB [check]

    CIRCLE (200, 100), 20, 4, 1
    name$ = "CIRCLE filled palette red"
    expect$ = 11141120 : got$ = POINT(200, 100) : GOSUB [check]

    LET SHP# = LOADSHAPE("RECTANGLE", 20, 20, GREEN#)
    MOVESHAPE SHP#, 250, 50
    DRAWSHAPE SHP#
    name$ = "DRAWSHAPE invalidates cache"
    expect$ = 65280 : got$ = POINT(250, 50) : GOSUB [check]

    name$ = "out of bounds"
    expect$ = 0 : got$ = POINT(-1, 5) : GOSUB [check]

    name$ = "untouched background"
    expect$ = 0 : got$ = POINT(300, 190) : GOSUB [check]

    SAVESCREEN "point_cache_test.png"
    name$ = "SAVESCREEN wrote file"
    expect$ = 1 : got$ = FILEEXISTS("point_cache_test.png") : GOSUB [check]

    REMOVESHAPE SHP#
    log$ += "pass=" + pass$ + " fail=" + fail$
    FILEWRITE "point_cache_test.log", log$
END

[check]
    IF got$ = expect$ THEN
        pass$ += 1
        log$ += "OK   " + name$ + "\n"
    ELSE
        fail$ += 1
        log$ += "FAIL " + name$ + " expected " + expect$ + " got " + got$ + "\n"
    END IF
RETURN
