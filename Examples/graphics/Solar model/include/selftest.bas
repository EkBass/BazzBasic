' selftest.bas - Solar System: "solar.bas selftest"
' [selftest:console] = checks printed before SCREEN; [selftest:views] = A7 views -> selftest\report.txt + phases.txt + PNGs

LET ST_REPORT# = "selftest/report.txt"
LET ST_PHASES# = "selftest/phases.txt"
LET ST_LISTZOOM# = "Sun|Earth|Mars|Jupiter|Saturn|Uranus|Neptune|Pluto|ISS"
DIM stDate$, stKepM$, stLz$, stListTxt$
stDate$(0) = "0" : stDate$(1) = "59" : stDate$(2) = "365" : stDate$(3) = "789.75"
stDate$(4) = "1000.5" : stDate$(5) = "36524.25" : stDate$(6) = "365250" : stDate$(7) = "3652500.5"
stKepM$(0) = "0.001" : stKepM$(1) = "0.5" : stKepM$(2) = "1" : stKepM$(3) = "2"
stKepM$(4) = "3" : stKepM$(5) = "3.14" : stKepM$(6) = "4" : stKepM$(7) = "6.28"
stListTxt$(0) = "-" : stListTxt$(1) = "Major" : stListTxt$(2) = "Other"
LET nStLz$ = SPLIT(stLz$, ST_LISTZOOM#, "|")
LET stLine$ = ""
LET stOk$ = 0
LET stTotal$ = 0
LET stMv$ = 0
LET stName$ = ""
LET stT0$ = 0
LET stDt$ = 0
LET stSum$ = 0
LET stMaxMs$ = 0
LET stLock$ = ""
LET stFirst$ = 0
LET stClamp$ = 0
LET stB$ = 0
LET stEx$ = 0
LET stEy$ = 0
LET stNm$ = ""

GOTO [selftest:moduleEnd]

' Console checks (before SCREEN: PRINT after SCREEN is not captured)
[selftest:console]
    PRINT "B8 SolarSystem selftest"
    PRINT "bodies: " + nBody$
    stLine$ = "ellipses:"
    FOR sc$ = 0 TO nBody$ - 1
        IF bEll$(sc$) = 1 THEN stLine$ = stLine$ + " " + bName$(sc$)
    NEXT
    PRINT stLine$
    stLine$ = "retrograde:"
    FOR sc$ = 0 TO nBody$ - 1
        IF bDir$(sc$) < 0 OR bInc$(sc$) > 90 THEN stLine$ = stLine$ + " " + bName$(sc$)
    NEXT
    PRINT stLine$
    PRINT "zoom: notches 0-" + ZMAX# + ", Earth at max " + CINT(2 * bR$(iEarth$) * zoomTab$(ZMAX#)) + " px, Sedna aphelion at min " + CINT(bA$(iSedna$) * (1 + bE$(iSedna$)) * zoomTab$(0)) + " px"
    FOR sc$ = 0 TO 7
        ckT$ = VAL(stDate$(sc$))
        ckHm$ = 1
        GOSUB [view:clockText]
        PRINT "date " + stDate$(sc$) + " = " + ckTxt$
    NEXT
    stOk$ = 0
    stTotal$ = 0
    FOR sc$ = 0 TO nBody$ - 1
        IF bEll$(sc$) = 1 THEN
            FOR sk$ = 0 TO 7
                stMv$ = VAL(stKepM$(sk$))
                kM$ = stMv$
                kEc$ = bE$(sc$)
                GOSUB [sim:kepler]
                IF ABS(kE$ - kEc$ * SIN(kE$) - stMv$) <= 0.000000001 THEN stOk$ += 1
                stTotal$ += 1
            NEXT
        END IF
    NEXT
    IF stOk$ = stTotal$ THEN
        PRINT "kepler: " + stOk$ + "/" + stTotal$ + " OK"
    ELSE
        PRINT "kepler: " + stOk$ + "/" + stTotal$ + " FAIL"
    END IF
    stLine$ = "major:"
    FOR sc$ = 0 TO nLs$(1) - 1
        stB$ = lsIdx$(1, sc$)
        IF lsInd$(stB$) = 1 THEN
            stLine$ = stLine$ + " -" + bName$(stB$)
        ELSE
            stLine$ = stLine$ + " " + bName$(stB$)
        END IF
    NEXT
    PRINT stLine$
    stLine$ = "other:"
    FOR sc$ = 0 TO nLs$(2) - 1
        stB$ = lsIdx$(2, sc$)
        IF lsInd$(stB$) = 1 THEN
            stLine$ = stLine$ + " -" + bName$(stB$)
        ELSE
            stLine$ = stLine$ + " " + bName$(stB$)
        END IF
    NEXT
    PRINT stLine$
    stLine$ = "listzoom:"
    FOR sc$ = 0 TO nStLz$ - 1
        stB$ = idx$(stLz$(sc$))
        stLine$ = stLine$ + " " + stLz$(sc$) + " " + bListN$(stB$)
    NEXT
    PRINT stLine$
    GOSUB [selftest:interactive]
RETURN

' B8 rev 1 (S114): interactive-only paths, headless, before any draw. Cursor, drag and list state are set
' by hand; [view:input] is not called (it reads the real keyboard, mouse and wheel).
[selftest:interactive]
    ' 1. fresh state: hover and click before the first [view:project]
    listMode$ = 0
    listTop$ = 0
    mDrag$ = 0
    mx$ = CX#
    my$ = CY#
    GOSUB [view:hover]
    stB$ = hovIdx$
    GOSUB [selftest:nm]
    stLine$ = "interactive fresh: hover=" + stNm$
    GOSUB [view:click]
    stB$ = lockIdx$
    GOSUB [selftest:nm]
    PRINT stLine$ + " click=" + stNm$
    ' 2. one projection at t = 0, notch 29, list off; pick around Earth (S110: centre within PICK_PX#)
    simT$ = 0
    zIdx$ = 29
    lockIdx$ = -1
    camX$ = 0
    camY$ = 0
    cBodies$ = 0
    GOSUB [sim:update]
    GOSUB [view:camera]
    GOSUB [view:project]
    stEx$ = pSx$(iEarth$)
    stEy$ = pSy$(iEarth$)
    stLine$ = "interactive model: visible=" + cBodies$
    my$ = stEy$
    mx$ = stEx$
    GOSUB [view:hover]
    stB$ = hovIdx$
    GOSUB [selftest:nm]
    stLine$ = stLine$ + " centre=" + stNm$
    mx$ = stEx$ + 12
    GOSUB [view:hover]
    stB$ = hovIdx$
    GOSUB [selftest:nm]
    stLine$ = stLine$ + " near=" + stNm$
    mx$ = stEx$ + 25
    GOSUB [view:hover]
    stB$ = hovIdx$
    GOSUB [selftest:nm]
    stLine$ = stLine$ + " off=" + stNm$
    GOSUB [view:click]
    stB$ = lockIdx$
    GOSUB [selftest:nm]
    stLine$ = stLine$ + " click_off=" + stNm$
    mx$ = stEx$ + 12
    GOSUB [view:click]
    stB$ = lockIdx$
    GOSUB [selftest:nm]
    stLine$ = stLine$ + " click_near=" + stNm$
    mDrag$ = 1
    GOSUB [view:hover]
    stB$ = hovIdx$
    GOSUB [selftest:nm]
    PRINT stLine$ + " drag=" + stNm$
    mDrag$ = 0
    ' 3. Major list open: a row (13 = Saturn), past the end, the header
    listMode$ = 1
    mx$ = LIST_X# + 50
    my$ = LIST_Y0# + 13 * ROW_H# + 5
    GOSUB [view:hover]
    stB$ = hovIdx$
    GOSUB [selftest:nm]
    stLine$ = "interactive list major: row=" + hovRow$ + " hover=" + stNm$
    GOSUB [view:listClick]
    stB$ = lockIdx$
    GOSUB [selftest:nm]
    stLine$ = stLine$ + " lock=" + stNm$ + " notch=" + zIdx$
    my$ = LIST_Y0# + 35 * ROW_H# + 5
    GOSUB [view:hover]
    stLine$ = stLine$ + " past_end=" + hovRow$
    GOSUB [view:listClick]
    my$ = LIST_Y0# - 10
    GOSUB [view:hover]
    stLine$ = stLine$ + " header=" + hovRow$
    GOSUB [view:listClick]
    stB$ = lockIdx$
    GOSUB [selftest:nm]
    PRINT stLine$ + " lock_after=" + stNm$
    ' 4. Other list: row 10 = Charon
    listMode$ = 2
    my$ = LIST_Y0# + 10 * ROW_H# + 5
    GOSUB [view:hover]
    stLine$ = "interactive list other: row=" + hovRow$
    GOSUB [view:listClick]
    stB$ = lockIdx$
    GOSUB [selftest:nm]
    PRINT stLine$ + " lock=" + stNm$ + " notch=" + zIdx$
    ' back to the start state (setView resets the rest for every view)
    listMode$ = 0
    listTop$ = 0
    lockIdx$ = -1
    hovIdx$ = -1
    hovRow$ = -1
    mDrag$ = 0
    mx$ = 0
    my$ = 0
    zIdx$ = START_NOTCH#
    simT$ = 0
    camX$ = 0
    camY$ = 0
    cBodies$ = 0
RETURN

' Body name of stB$ into stNm$ ("-" for -1)
[selftest:nm]
    stNm$ = "-"
    IF stB$ >= 0 THEN stNm$ = bName$(stB$)
RETURN

' A7: fourteen fixed views, ST_FRAMES# frames each, timed; report line + PNG per view
[selftest:views]
    VSYNC(FALSE)
    FILEWRITE ST_REPORT#, "B8 selftest report\n"
    FILEWRITE ST_PHASES#, "B8 selftest phases (avg ms per frame, 120 frames; segs = polyline segments of the last frame)\n"
    FOR sv$ = 1 TO 14
        GOSUB [selftest:setView]
        stSum$ = 0
        stMaxMs$ = 0
        stFirst$ = 0
        stClamp$ = 0
        phSim$ = 0
        phProj$ = 0
        phOrb$ = 0
        phDisc$ = 0
        phLbl$ = 0
        phList$ = 0
        phHud$ = 0
        phPres$ = 0
        FOR sf$ = 1 TO ST_FRAMES#
            stT0$ = TICKS
            simT$ = simT$ + speedDps$(spIdx$) / 60
            GOSUB [sim:update]
            GOSUB [view:camera]
            GOSUB [view:draw]
            stDt$ = TICKS - stT0$
            stSum$ = stSum$ + stDt$
            stClamp$ = stClamp$ + clampHits$
            phSim$ = phSim$ + (phT0$ - stT0$)
            IF sf$ = 1 THEN
                stFirst$ = stDt$
            ELSE
                stMaxMs$ = MAX(stMaxMs$, stDt$)
            END IF
        NEXT
        SAVESCREEN "selftest/" + stName$ + ".png"
        stLock$ = "-"
        IF lockIdx$ >= 0 THEN stLock$ = bName$(lockIdx$)
        stLine$ = "view=" + stName$ + " notch=" + zIdx$ + " lock=" + stLock$ + " speed=" + speedTxt$(spIdx$)
        stLine$ = stLine$ + " frames=" + ST_FRAMES# + " avg_ms=" + FN Fixed$(stSum$ / ST_FRAMES#, 1) + " first_ms=" + stFirst$ + " max_ms=" + stMaxMs$
        stLine$ = stLine$ + " bodies=" + cBodies$ + " orbits=" + cOrbits$ + " rings=" + cRings$ + " labels=" + cLabels$
        stLine$ = stLine$ + " spans=" + cSpans$ + " list=" + stListTxt$(listMode$) + " rows=" + cRows$ + " hover=" + cHover$ + " vlines=" + cVlines$
        stLine$ = stLine$ + " clamp=" + stClamp$
        FILEAPPEND ST_REPORT#, stLine$ + "\n"
        stLine$ = "view=" + stName$ + " sim=" + FN Fixed$(phSim$ / ST_FRAMES#, 2) + " proj=" + FN Fixed$(phProj$ / ST_FRAMES#, 2)
        stLine$ = stLine$ + " orbits=" + FN Fixed$(phOrb$ / ST_FRAMES#, 2) + " discs=" + FN Fixed$(phDisc$ / ST_FRAMES#, 2)
        stLine$ = stLine$ + " labels=" + FN Fixed$(phLbl$ / ST_FRAMES#, 2) + " list=" + FN Fixed$(phList$ / ST_FRAMES#, 2)
        stLine$ = stLine$ + " hud=" + FN Fixed$(phHud$ / ST_FRAMES#, 2)
        stLine$ = stLine$ + " present=" + FN Fixed$(phPres$ / ST_FRAMES#, 2) + " segs=" + cSegs$
        FILEAPPEND ST_PHASES#, stLine$ + "\n"
    NEXT
    FILEAPPEND ST_REPORT#, "end\n"
    FILEAPPEND ST_PHASES#, "end\n"
RETURN

' View sv$ (A7 table): t = 0, notch, lock or camera, speed index, list mode, hover
[selftest:setView]
    simT$ = 0
    lockIdx$ = -1
    camX$ = 0
    camY$ = 0
    listMode$ = 0
    listTop$ = 0
    hovIdx$ = -1
    hovRow$ = -1
    lsFull$ = 1
    IF sv$ = 1 THEN
        stName$ = "v1_full"
        zIdx$ = 0
        spIdx$ = 5
    ELSEIF sv$ = 2 THEN
        stName$ = "v2_inner"
        zIdx$ = 29
        spIdx$ = 2
    ELSEIF sv$ = 3 THEN
        stName$ = "v3_earth_iss"
        zIdx$ = 74
        lockIdx$ = iEarth$
        spIdx$ = 1
    ELSEIF sv$ = 4 THEN
        stName$ = "v4_earth_moon"
        zIdx$ = 58
        lockIdx$ = iEarth$
        spIdx$ = 2
    ELSEIF sv$ = 5 THEN
        stName$ = "v5_saturn"
        zIdx$ = 59
        lockIdx$ = iSaturn$
        spIdx$ = 2
    ELSEIF sv$ = 6 THEN
        stName$ = "v6_sedna"
        zIdx$ = 3
        camX$ = bEx$(iSedna$)
        camY$ = bEy$(iSedna$)
        spIdx$ = 7
    ELSEIF sv$ = 7 THEN
        stName$ = "v7_orbit_arc"
        zIdx$ = 74
        camX$ = bA$(iEarth$) * COS(bM0$(iEarth$) + HPI#)
        camY$ = bA$(iEarth$) * SIN(bM0$(iEarth$) + HPI#)
        spIdx$ = 0
    ELSEIF sv$ = 8 THEN
        stName$ = "v8_sun_edge"
        zIdx$ = 74
        camX$ = 696000
        camY$ = 0
        spIdx$ = 0
    ELSEIF sv$ = 9 THEN
        stName$ = "v9_saturn_far"
        zIdx$ = 15
        lockIdx$ = iSaturn$
        spIdx$ = 2
    ELSEIF sv$ = 10 THEN
        stName$ = "v10_list_major"
        zIdx$ = 29
        spIdx$ = 2
        listMode$ = 1
    ELSEIF sv$ = 11 THEN
        stName$ = "v11_list_other"
        zIdx$ = 0
        spIdx$ = 5
        listMode$ = 2
    ELSEIF sv$ = 12 THEN
        stName$ = "v12_list_click"
        listMode$ = 1
        lpBody$ = iSaturn$
        GOSUB [view:listPick]
        hovIdx$ = idx$("Iapetus")
        spIdx$ = 2
    ELSEIF sv$ = 13 THEN
        stName$ = "v13_far_wide"
        zIdx$ = 1
        spIdx$ = 7
        hovIdx$ = idx$("Halley")
    ELSE
        stName$ = "v14_voyager_deep"
        zIdx$ = 74
        camX$ = 100 * KM_PER_AU# * bPx$(idx$("Voyager 1"))
        camY$ = 100 * KM_PER_AU# * bPy$(idx$("Voyager 1"))
        spIdx$ = 0
    END IF
RETURN

[selftest:moduleEnd]
