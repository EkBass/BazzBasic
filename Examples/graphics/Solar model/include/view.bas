' view.bas - Solar System: input, camera, projection, discs, orbit paths, ring, labels, list, HUD
' Every LINE/CIRCLE value is clamped to SAFE_LO#..SAFE_PX# before CINT; a clamp that bites
' counts clampHits$ (the selftest requires 0).
' Retained list panel (B8 A10): while the list is open the model never draws at x > drawMaxX$.

LET RING_IN# = 74500
LET RING_OUT# = 136800

' --- last frame's projection per body (also used by pick/hover) ---
DIM pSx$, pSy$, pRd$, pVis$
' --- placed label boxes; 0 and 1 = the two HUD boxes, 2 = the list panel when open ---
DIM plX1$, plY1$, plX2$, plY2$
plX1$(0) = 0 : plY1$(0) = 0 : plX2$(0) = 720 : plY2$(0) = 34
plX1$(1) = 0 : plY1$(1) = 1052 : plX2$(1) = 820 : plY2$(1) = 1080
LET nPl$ = 2

' --- per-frame counters ---
LET cBodies$ = 0
LET cOrbits$ = 0
LET cRings$ = 0
LET cLabels$ = 0
LET cSpans$ = 0
LET cSegs$ = 0
LET cVlines$ = 0
LET cHover$ = 0
LET cRows$ = 0
LET clampHits$ = 0

' --- phase timers (B7 R3-1): TICKS marks in [view:draw], per-phase sums read by the selftest ---
LET phT0$ = 0
LET phT1$ = 0
LET phT2$ = 0
LET phT3$ = 0
LET phT4$ = 0
LET phTL$ = 0
LET phT5$ = 0
LET phT6$ = 0
LET phSim$ = 0
LET phProj$ = 0
LET phOrb$ = 0
LET phDisc$ = 0
LET phLbl$ = 0
LET phList$ = 0
LET phHud$ = 0
LET phPres$ = 0

' --- input state (keys: KEYDOWN, was-state per key for the press edge; B7 rev 5, S101) ---
LET kNow$ = 0
LET kwEsc$ = 0
LET kwC$ = 0
LET kwH$ = 0
LET kwSpace$ = 0
LET kwF$ = 0
LET kwNumPlus$ = 0
LET kwS$ = 0
LET kwNumMinus$ = 0
LET kwL$ = 0
LET helpShow$ = 0
LET mx$ = 0
LET my$ = 0
LET mNow$ = 0
LET mWas$ = 0
LET mDrag$ = 0
LET mPressPanel$ = 0
LET mPressX$ = 0
LET mPressY$ = 0
LET mLastX$ = 0
LET mLastY$ = 0
LET w$ = 0
LET nz$ = 0
LET z0$ = 0
LET z1$ = 0
LET wxm$ = 0
LET wym$ = 0

' --- pick / hover (A8, S110): in pkX$ pkY$, out pkIdx$ ---
LET pkX$ = 0
LET pkY$ = 0
LET pkIdx$ = -1
LET pkD$ = 0
LET pkBestD$ = 0
LET pkBestR$ = 0
LET pkOk$ = 0
LET hovIdx$ = -1
LET hovRow$ = -1

' --- body list (A9, A10) ---
DIM lsIdx$, nLs$, lsList$, lsPos$, lsInd$, lsName$, lsK1$, lsK2$
nLs$(0) = 0 : nLs$(1) = 0 : nLs$(2) = 0
LET listTop$ = 0
LET lsFull$ = 1
LET lsNext$ = 0
LET lsEnd$ = -1
LET lsRow$ = -1
LET lsLockRow$ = -1
LET lsPrevHov$ = -1
LET lsPrevLock$ = -1
LET lsY$ = 0
LET lsBar$ = 0
LET lsB$ = 0
LET lsJ$ = 0
LET lrP$ = 0
LET lrX$ = 0
LET lrY$ = 0
LET lrZ$ = 0
LET lrPx$ = 0
LET lrPy$ = 0
LET lrPz$ = 0
LET lrDash$ = 0
LET lrTxt$ = ""
LET lsHead$ = ""
LET lcR$ = 0
LET lcK$ = 0
LET lpBody$ = 0
LET lpH$ = 0
LET lpGo$ = 0
LET lpM$ = 0
LET lpK$ = 0
LET lpJ$ = 0

' --- projection / discs ---
LET vSx$ = 0
LET vSy$ = 0
LET vRd$ = 0
LET dsx$ = 0
LET dsy$ = 0
LET drd$ = 0
LET dcol$ = 0
LET dAll$ = 0
LET dy$ = 0
LET h2$ = 0
LET half$ = 0
LET x1$ = 0
LET x2$ = 0

' --- clamp helpers: in lx1$ ly1$ lx2$ ly2$ lCol$ lBF$ / ccX$ ccY$ ccR$ ccCol$ ccFill$ ---
LET lx1$ = 0
LET ly1$ = 0
LET lx2$ = 0
LET ly2$ = 0
LET lCol$ = 0
LET lBF$ = 0
LET cq1$ = 0
LET cq2$ = 0
LET cq3$ = 0
LET cq4$ = 0
LET ccX$ = 0
LET ccY$ = 0
LET ccR$ = 0
LET ccCol$ = 0
LET ccFill$ = 0

' --- line clip (Liang-Barsky): in/out lx1$ ly1$ lx2$ ly2$, out clOk$ ---
LET clOk$ = 0
LET clRej$ = 0
LET clT0$ = 0
LET clT1$ = 0
LET clDx$ = 0
LET clDy$ = 0
LET clP$ = 0
LET clQ$ = 0
LET clR$ = 0
LET clX1$ = 0
LET clY1$ = 0

' --- orbit path: in opX$ opY$ opA$ opB$ opCw$ opSw$ opCol$ opCircle$, out opDrawn$ ---
LET opX$ = 0
LET opY$ = 0
LET opA$ = 0
LET opB$ = 0
LET opCw$ = 1
LET opSw$ = 0
LET opCol$ = 0
LET opCircle$ = 1
LET opDrawn$ = 0
LET oPar$ = 0
LET oQ$ = 0
LET oDx$ = 0
LET oDy$ = 0
LET oU$ = 0
LET oV$ = 0
LET oRr$ = 0
LET oD$ = 0
LET oKk$ = 0
LET oDel$ = 0
LET oThc$ = 0
LET oTh0$ = 0
LET oTh1$ = 0
LET oGo$ = 0
LET oStMax$ = 0
LET oSegN$ = 0
LET oStep$ = 0
LET oCs$ = 0
LET oSn$ = 0
LET oC$ = 0
LET oS$ = 0
LET oTt$ = 0
LET px0$ = 0
LET py0$ = 0
LET px1$ = 0
LET py1$ = 0
LET oSkip$ = 0
LET oCt$ = 0
LET oCx0$ = 0
LET oCy0$ = 0
LET oCx1$ = 0
LET oCy1$ = 0

' --- labels / HUD / clock ---
LET lt$ = 0
LET lbX$ = 0
LET lbY$ = 0
LET lbW$ = 0
LET lbHit$ = 0
LET lbCap$ = 0
LET lbXr$ = 0
LET hudTxt$ = ""
LET hudScale$ = ""
LET hudLock$ = ""
LET kmPx$ = 0
LET ckT$ = 0
LET ckHm$ = 0
LET ckTxt$ = ""
LET ckDay$ = 0
LET ckMinT$ = 0
LET ckHh$ = 0
LET ckMm$ = 0

GOTO [view:moduleEnd]

' D6: keyboard + mouse (interactive mode only), before SCREENLOCK ON
' Keys: KEYDOWN + press edge (down now, up last frame) = one action per press; holding does not repeat.
' No INKEY: it consumes its buffer per call and loses presses in a busy loop (S101).
[view:input]
    kNow$ = KEYDOWN(KEY_ESC#)
    IF kNow$ = 1 AND kwEsc$ = 0 THEN running$ = FALSE
    kwEsc$ = kNow$
    kNow$ = KEYDOWN(KEY_C#)
    IF kNow$ = 1 AND kwC$ = 0 THEN lockIdx$ = -1
    kwC$ = kNow$
    kNow$ = KEYDOWN(KEY_H#)
    IF kNow$ = 1 AND kwH$ = 0 THEN helpShow$ = 1 - helpShow$
    kwH$ = kNow$
    kNow$ = KEYDOWN(KEY_SPACE#)
    IF kNow$ = 1 AND kwSpace$ = 0 THEN
        IF spIdx$ > 0 THEN
            spSaved$ = spIdx$
            spIdx$ = 0
        ELSE
            spIdx$ = spSaved$
        END IF
    END IF
    kwSpace$ = kNow$
    kNow$ = KEYDOWN(KEY_F#)
    IF kNow$ = 1 AND kwF$ = 0 THEN spIdx$ = MIN(7, spIdx$ + 1)
    kwF$ = kNow$
    kNow$ = KEYDOWN(KEY_NUMPAD_PLUS#)
    IF kNow$ = 1 AND kwNumPlus$ = 0 THEN spIdx$ = MIN(7, spIdx$ + 1)
    kwNumPlus$ = kNow$
    kNow$ = KEYDOWN(KEY_S#)
    IF kNow$ = 1 AND kwS$ = 0 THEN spIdx$ = MAX(0, spIdx$ - 1)
    kwS$ = kNow$
    kNow$ = KEYDOWN(KEY_NUMPAD_MINUS#)
    IF kNow$ = 1 AND kwNumMinus$ = 0 THEN spIdx$ = MAX(0, spIdx$ - 1)
    kwNumMinus$ = kNow$
    ' L: list Off -> Major -> Other -> Off
    kNow$ = KEYDOWN(KEY_L#)
    IF kNow$ = 1 AND kwL$ = 0 THEN
        listMode$ = listMode$ + 1
        IF listMode$ > 2 THEN listMode$ = 0
        listTop$ = 0
        lsFull$ = 1
    END IF
    kwL$ = kNow$

    mx$ = MOUSEX
    my$ = MOUSEY
    mNow$ = MOUSELEFT

    ' wheel: one read per frame; over the list = scroll it, else zoom
    ' (unlocked: the world point under the cursor stays put)
    w$ = MOUSEWHEEL
    IF w$ <> 0 THEN
        IF listMode$ > 0 AND mx$ >= LIST_X# THEN
            listTop$ = CLAMP(listTop$ - 3 * w$, 0, MAX(0, nLs$(listMode$) - LIST_ROWS#))
            lsFull$ = 1
        ELSE
            nz$ = CLAMP(zIdx$ + w$, 0, ZMAX#)
            IF nz$ <> zIdx$ THEN
                z0$ = zoomTab$(zIdx$)
                z1$ = zoomTab$(nz$)
                IF lockIdx$ < 0 THEN
                    wxm$ = camX$ + (mx$ - camCX$) / z0$
                    wym$ = camY$ - (my$ - CY#) / z0$
                    camX$ = wxm$ - (mx$ - camCX$) / z1$
                    camY$ = wym$ + (my$ - CY#) / z1$
                END IF
                zIdx$ = nz$
            END IF
        END IF
    END IF
    zoom$ = zoomTab$(zIdx$)

    ' left button: press records the point, > DRAG_PX# starts a drag (unlocks), release w/o drag = click
    ' a press over the list panel never drags; its release is a list click
    IF mNow$ = 1 AND mWas$ = 0 THEN
        mPressX$ = mx$
        mPressY$ = my$
        mDrag$ = 0
        mPressPanel$ = 0
        IF listMode$ > 0 AND mx$ >= LIST_X# THEN mPressPanel$ = 1
    END IF
    IF mNow$ = 1 AND mWas$ = 1 AND mPressPanel$ = 0 THEN
        IF mDrag$ = 0 THEN
            IF DISTANCE(mx$, my$, mPressX$, mPressY$) > DRAG_PX# THEN
                mDrag$ = 1
                lockIdx$ = -1
                mLastX$ = mPressX$
                mLastY$ = mPressY$
            END IF
        END IF
        IF mDrag$ = 1 THEN
            camX$ = camX$ - (mx$ - mLastX$) / zoom$
            camY$ = camY$ + (my$ - mLastY$) / zoom$
            mLastX$ = mx$
            mLastY$ = my$
        END IF
    END IF
    IF mNow$ = 0 AND mWas$ = 1 THEN
        IF mDrag$ = 0 THEN
            IF mPressPanel$ = 1 THEN
                GOSUB [view:listClick]
            ELSE
                GOSUB [view:click]
            END IF
        END IF
        mDrag$ = 0
        mPressPanel$ = 0
    END IF
    mWas$ = mNow$
RETURN

' A8 pick (S110): nearest visible body whose CENTRE is within PICK_PX# of (pkX$, pkY$),
' last frame's projection. Tie: smaller disc, then lower index. Bodies under the panel are not pickable.
[view:pick]
    pkIdx$ = -1
    pkBestD$ = 0
    pkBestR$ = 0
    FOR pk$ = 0 TO nBody$ - 1
        IF pVis$(pk$) = 1 THEN
            pkOk$ = 1
            IF listMode$ > 0 AND pSx$(pk$) >= LIST_X# THEN pkOk$ = 0
            IF pkOk$ = 1 THEN
                pkD$ = DISTANCE(pkX$, pkY$, pSx$(pk$), pSy$(pk$))
                IF pkD$ <= PICK_PX# THEN
                    IF pkIdx$ < 0 THEN
                        pkIdx$ = pk$
                        pkBestD$ = pkD$
                        pkBestR$ = pRd$(pk$)
                    ELSEIF pkD$ < pkBestD$ OR (pkD$ = pkBestD$ AND pRd$(pk$) < pkBestR$) THEN
                        pkIdx$ = pk$
                        pkBestD$ = pkD$
                        pkBestR$ = pRd$(pk$)
                    END IF
                END IF
            END IF
        END IF
    NEXT
RETURN

' Click at the release point: pick = lock, nothing = unlock
[view:click]
    pkX$ = mx$
    pkY$ = my$
    GOSUB [view:pick]
    lockIdx$ = pkIdx$
RETURN

' Hover (interactive loop, after input): row under the cursor over the panel, else the pick at the cursor
[view:hover]
    hovIdx$ = -1
    hovRow$ = -1
    IF listMode$ > 0 AND mx$ >= LIST_X# THEN
        IF my$ >= LIST_Y0# THEN
            lcR$ = FLOOR((my$ - LIST_Y0#) / ROW_H#)
            lcK$ = listTop$ + lcR$
            IF lcR$ < LIST_ROWS# AND lcK$ < nLs$(listMode$) THEN hovRow$ = lcK$
        END IF
    ELSEIF mDrag$ = 0 THEN
        pkX$ = mx$
        pkY$ = my$
        GOSUB [view:pick]
        hovIdx$ = pkIdx$
    END IF
RETURN

' Click on the panel: the row under the cursor -> lock + list zoom
[view:listClick]
    IF listMode$ > 0 AND my$ >= LIST_Y0# THEN
        lcR$ = FLOOR((my$ - LIST_Y0#) / ROW_H#)
        lcK$ = listTop$ + lcR$
        IF lcR$ < LIST_ROWS# AND lcK$ < nLs$(listMode$) THEN
            lpBody$ = lsIdx$(listMode$, lcK$)
            GOSUB [view:listPick]
        END IF
    END IF
RETURN

' Lock body lpBody$ and zoom to its list notch
[view:listPick]
    lockIdx$ = lpBody$
    zIdx$ = bListN$(lpBody$)
    zoom$ = zoomTab$(zIdx$)
RETURN

' A9 (once, after [sim:prepare]): list membership, static sort key, indent, name text, insertion sort.
' B8 rev 1: also an empty last-frame projection, so hover/pick/click work before the first draw (S114).
[view:listPrepare]
    FOR lp$ = 0 TO nBody$ - 1
        pVis$(lp$) = 0
        pSx$(lp$) = 0
        pSy$(lp$) = 0
        pRd$(lp$) = 0
    NEXT
    FOR lp$ = 0 TO nBody$ - 1
        ' list 1 (Major) = star, planet, moon of a planet; list 2 (Other) = the rest
        lsList$(lp$) = 2
        IF bKind$(lp$) = "star" OR bKind$(lp$) = "planet" THEN lsList$(lp$) = 1
        IF bKind$(lp$) = "moon" AND bPar$(lp$) >= 0 THEN
            IF bKind$(bPar$(lp$)) = "planet" THEN lsList$(lp$) = 1
        END IF
        ' heliocentric ancestor: climb while parent >= 0 and parent <> iSun$ (flag loop)
        lpH$ = lp$
        lpGo$ = 1
        WHILE lpGo$ = 1
            IF bPar$(lpH$) < 0 THEN
                lpGo$ = 0
            ELSEIF bPar$(lpH$) = iSun$ THEN
                lpGo$ = 0
            ELSE
                lpH$ = bPar$(lpH$)
            END IF
        WEND
        lsK1$(lp$) = bA$(lpH$)
        lsK2$(lp$) = 0
        IF lpH$ <> lp$ THEN lsK2$(lp$) = bA$(lp$)
        ' indent: parent >= 0, parent <> iSun$, same list
        lsInd$(lp$) = 0
        lsName$(lp$) = bName$(lp$)
        IF bPar$(lp$) >= 0 THEN
            IF bPar$(lp$) <> iSun$ THEN
                IF lsList$(bPar$(lp$)) = lsList$(lp$) THEN
                    lsInd$(lp$) = 1
                    lsName$(lp$) = " -" + bName$(lp$)
                END IF
            END IF
        END IF
        ' insertion sort in data order (equal keys keep data order)
        lpM$ = lsList$(lp$)
        lpK$ = nLs$(lpM$)
        lpGo$ = 1
        WHILE lpGo$ = 1
            IF lpK$ = 0 THEN
                lpGo$ = 0
            ELSE
                lpJ$ = lsIdx$(lpM$, lpK$ - 1)
                IF lsK1$(lpJ$) > lsK1$(lp$) OR (lsK1$(lpJ$) = lsK1$(lp$) AND lsK2$(lpJ$) > lsK2$(lp$)) THEN
                    lsIdx$(lpM$, lpK$) = lpJ$
                    lpK$ = lpK$ - 1
                ELSE
                    lpGo$ = 0
                END IF
            END IF
        WEND
        lsIdx$(lpM$, lpK$) = lp$
        nLs$(lpM$) = nLs$(lpM$) + 1
    NEXT
    ' list position of every body (for the lock row)
    FOR lpM$ = 1 TO 2
        FOR lpK$ = 0 TO nLs$(lpM$) - 1
            lsPos$(lsIdx$(lpM$, lpK$)) = lpK$
        NEXT
    NEXT
RETURN

' Camera follows the locked body; zoom from the notch table; camera centre and model area (A2, A10)
[view:camera]
    IF lockIdx$ >= 0 THEN
        camX$ = wx$(lockIdx$)
        camY$ = wy$(lockIdx$)
    END IF
    zoom$ = zoomTab$(zIdx$)
    IF listMode$ > 0 THEN
        camCX$ = LIST_CX#
        drawMaxX$ = LIST_X# - 1
    ELSE
        camCX$ = CX#
        drawMaxX$ = MAX_X#
    END IF
RETURN

' One frame: clear, orbits, discs (+ ring after Saturn), lock marker, labels, list, HUD
[view:draw]
    phT0$ = TICKS
    cBodies$ = 0
    cOrbits$ = 0
    cRings$ = 0
    cLabels$ = 0
    cSpans$ = 0
    cSegs$ = 0
    cVlines$ = 0
    cHover$ = 0
    cRows$ = 0
    clampHits$ = 0
    GOSUB [view:project]
    SCREENLOCK ON
    LINE (0, 0)-(drawMaxX$, MAX_Y#), 0, BF
    phT1$ = TICKS
    GOSUB [view:orbits]
    phT2$ = TICKS
    GOSUB [view:discs]
    GOSUB [view:lockMarker]
    phT3$ = TICKS
    GOSUB [view:labels]
    phT4$ = TICKS
    GOSUB [view:list]
    phTL$ = TICKS
    GOSUB [view:hud]
    phT5$ = TICKS
    SCREENLOCK OFF
    phT6$ = TICKS
    phProj$ += phT1$ - phT0$
    phOrb$ += phT2$ - phT1$
    phDisc$ += phT3$ - phT2$
    phLbl$ += phT4$ - phT3$
    phList$ += phTL$ - phT4$
    phHud$ += phT5$ - phTL$
    phPres$ += phT6$ - phT5$
RETURN

' A2: screen position, disc radius and visibility of every body (camera subtracted first)
[view:project]
    FOR vi$ = 0 TO nBody$ - 1
        vSx$ = camCX$ + (wx$(vi$) - camX$) * zoom$
        vSy$ = CY# - (wy$(vi$) - camY$) * zoom$
        vRd$ = MAX(bR$(vi$) * zoom$, bMinR$(vi$))
        pSx$(vi$) = vSx$
        pSy$(vi$) = vSy$
        pRd$(vi$) = vRd$
        pVis$(vi$) = 0
        IF bSmall$(vi$) = 0 OR bA$(vi$) * zoom$ >= 4 THEN
            IF vSx$ + vRd$ >= 0 AND vSx$ - vRd$ <= drawMaxX$ AND vSy$ + vRd$ >= 0 AND vSy$ - vRd$ <= MAX_Y# THEN
                pVis$(vi$) = 1
                cBodies$ += 1
            END IF
        END IF
    NEXT
RETURN

' A3: projected orbit lines (mode 0, not the Sun), then the Voyager lines
[view:orbits]
    FOR oi$ = 0 TO nBody$ - 1
        oPar$ = bPar$(oi$)
        IF oPar$ >= 0 AND bMode$(oi$) = 0 THEN
            opA$ = bOA$(oi$) * zoom$
            opB$ = bOB$(oi$) * zoom$
            IF opB$ >= bOrbMin$(oi$) THEN
                opX$ = camCX$ + (wx$(oPar$) + bEx$(oi$) - camX$) * zoom$
                opY$ = CY# - (wy$(oPar$) + bEy$(oi$) - camY$) * zoom$
                opCw$ = bCw$(oi$)
                opSw$ = bSw$(oi$)
                opCircle$ = 0
                IF bEll$(oi$) = 0 AND (opA$ - opB$) / 2 <= CIRC_ERR_PX# THEN
                    opA$ = (opA$ + opB$) / 2
                    opB$ = opA$
                    opCw$ = 1
                    opSw$ = 0
                    opCircle$ = 1
                END IF
                opCol$ = bOrbCol$(oi$)
                GOSUB [view:orbitPath]
                IF opDrawn$ = 1 THEN cOrbits$ += 1
            END IF
        END IF
    NEXT
    ' Voyager lines: Sun -> probe, clipped to the model area before the clamp
    FOR oi$ = 0 TO nBody$ - 1
        IF bMode$(oi$) = 1 THEN
            lx1$ = pSx$(iSun$)
            ly1$ = pSy$(iSun$)
            lx2$ = pSx$(oi$)
            ly2$ = pSy$(oi$)
            GOSUB [view:clipLine]
            IF clOk$ = 1 THEN
                lCol$ = C_VLINE#
                lBF$ = 0
                GOSUB [view:clampLine]
                cVlines$ += 1
            END IF
        END IF
    NEXT
RETURN

' Liang-Barsky clip of lx1$,ly1$-lx2$,ly2$ to 0..drawMaxX$ x 0..MAX_Y#; clOk$ 1 = something left
[view:clipLine]
    clOk$ = 0
    clRej$ = 0
    clT0$ = 0
    clT1$ = 1
    clDx$ = lx2$ - lx1$
    clDy$ = ly2$ - ly1$
    FOR ce$ = 1 TO 4
        IF ce$ = 1 THEN
            clP$ = 0 - clDx$
            clQ$ = lx1$
        ELSEIF ce$ = 2 THEN
            clP$ = clDx$
            clQ$ = drawMaxX$ - lx1$
        ELSEIF ce$ = 3 THEN
            clP$ = 0 - clDy$
            clQ$ = ly1$
        ELSE
            clP$ = clDy$
            clQ$ = MAX_Y# - ly1$
        END IF
        IF clP$ = 0 THEN
            IF clQ$ < 0 THEN clRej$ = 1
        ELSE
            clR$ = clQ$ / clP$
            IF clP$ < 0 THEN
                clT0$ = MAX(clT0$, clR$)
            ELSE
                clT1$ = MIN(clT1$, clR$)
            END IF
        END IF
    NEXT
    IF clRej$ = 0 AND clT0$ <= clT1$ THEN
        ' both new ends from the ORIGINAL start point
        clX1$ = lx1$ + clT0$ * clDx$
        clY1$ = ly1$ + clT0$ * clDy$
        lx2$ = lx1$ + clT1$ * clDx$
        ly2$ = ly1$ + clT1$ * clDy$
        lx1$ = clX1$
        ly1$ = clY1$
        clOk$ = 1
    END IF
RETURN

' Discs in data order; Saturn's ring right after Saturn
[view:discs]
    FOR di$ = 0 TO nBody$ - 1
        IF pVis$(di$) = 1 THEN GOSUB [view:disc]
        IF di$ = iSaturn$ THEN GOSUB [view:rings]
    NEXT
RETURN

' A2 disc of body di$: CIRCLE, full-area box, or clipped horizontal spans (right edge = drawMaxX$)
[view:disc]
    dsx$ = pSx$(di$)
    dsy$ = pSy$(di$)
    drd$ = pRd$(di$)
    dcol$ = bCol$(di$)
    IF drd$ <= R_DISC_SAFE# AND dsx$ + drd$ <= drawMaxX$ THEN
        ccX$ = dsx$
        ccY$ = dsy$
        ccR$ = drd$
        ccCol$ = dcol$
        ccFill$ = 1
        GOSUB [view:clampCircle]
    ELSE
        dAll$ = 0
        IF DISTANCE(0, 0, dsx$, dsy$) <= drd$ AND DISTANCE(drawMaxX$, 0, dsx$, dsy$) <= drd$ AND DISTANCE(0, MAX_Y#, dsx$, dsy$) <= drd$ AND DISTANCE(drawMaxX$, MAX_Y#, dsx$, dsy$) <= drd$ THEN dAll$ = 1
        IF dAll$ = 1 THEN
            lx1$ = 0
            ly1$ = 0
            lx2$ = drawMaxX$
            ly2$ = MAX_Y#
            lCol$ = dcol$
            lBF$ = 1
            GOSUB [view:clampLine]
        ELSE
            FOR spy$ = MAX(0, CEIL(dsy$ - drd$)) TO MIN(MAX_Y#, FLOOR(dsy$ + drd$)) STEP SPAN_BAND#
                dy$ = spy$ + (SPAN_BAND# - 1) / 2 - dsy$
                h2$ = drd$ * drd$ - dy$ * dy$
                IF h2$ > 0 THEN
                    half$ = SQR(h2$)
                    x1$ = MAX(0, dsx$ - half$)
                    x2$ = MIN(drawMaxX$, dsx$ + half$)
                    IF x1$ <= x2$ THEN
                        lx1$ = x1$
                        ly1$ = spy$
                        lx2$ = x2$
                        ly2$ = MIN(MAX_Y#, spy$ + SPAN_BAND# - 1)
                        lCol$ = dcol$
                        lBF$ = 1
                        GOSUB [view:clampLine]
                        cSpans$ += 1
                    END IF
                END IF
            NEXT
        END IF
    END IF
RETURN

' Saturn ring: two unfilled paths, drawn when RING_OUT# zoom >= 4
[view:rings]
    IF RING_OUT# * zoom$ >= 4 THEN
        opX$ = pSx$(iSaturn$)
        opY$ = pSy$(iSaturn$)
        opCw$ = 1
        opSw$ = 0
        opCircle$ = 1
        opCol$ = C_RING#
        opA$ = RING_IN# * zoom$
        opB$ = opA$
        GOSUB [view:orbitPath]
        IF opDrawn$ = 1 THEN cRings$ += 1
        opA$ = RING_OUT# * zoom$
        opB$ = opA$
        GOSUB [view:orbitPath]
        IF opDrawn$ = 1 THEN cRings$ += 1
    END IF
RETURN

' A3: visible arc of an ellipse/circle in "circle space"; one CIRCLE or a polyline of that arc
' (visibility disc stays centred on CX#; drawing stays left of drawMaxX$, A10)
[view:orbitPath]
    opDrawn$ = 0
    oGo$ = 0
    oQ$ = opA$ / opB$
    oDx$ = CX# - opX$
    oDy$ = opY$ - CY#
    oU$ = oDx$ * opCw$ + oDy$ * opSw$
    oV$ = (oDy$ * opCw$ - oDx$ * opSw$) * oQ$
    oRr$ = HALF_DIAG# * oQ$
    oD$ = SQR(oU$ * oU$ + oV$ * oV$)
    IF oD$ < 0.5 THEN
        IF opA$ <= oRr$ THEN
            oGo$ = 1
            oTh0$ = 0 - PI#
            oTh1$ = PI#
        END IF
    ELSE
        oKk$ = (opA$ * opA$ + oD$ * oD$ - oRr$ * oRr$) / (2 * opA$ * oD$)
        IF oKk$ < 1 THEN
            IF oKk$ <= -1 THEN
                oGo$ = 1
                oTh0$ = 0 - PI#
                oTh1$ = PI#
            ELSE
                oDel$ = ATAN2(SQR(1 - oKk$ * oKk$), oKk$)
                oThc$ = ATAN2(oV$, oU$)
                oTh0$ = oThc$ - oDel$
                oTh1$ = oThc$ + oDel$
                oGo$ = 1
            END IF
        END IF
    END IF
    IF oGo$ = 1 THEN
        opDrawn$ = 1
        IF opCircle$ = 1 AND opA$ <= R_CIRCLE# AND opX$ + opA$ <= drawMaxX$ THEN
            ccX$ = opX$
            ccY$ = opY$
            ccR$ = opA$
            ccCol$ = opCol$
            ccFill$ = 0
            GOSUB [view:clampCircle]
        ELSE
            oStMax$ = SQR(8 * SAG_PX# / opA$)
            oSegN$ = CLAMP(CEIL((oTh1$ - oTh0$) / oStMax$), 8, ORBIT_SEG_MAX#)
            cSegs$ += oSegN$
            oStep$ = (oTh1$ - oTh0$) / oSegN$
            oCs$ = COS(oStep$)
            oSn$ = SIN(oStep$)
            oC$ = COS(oTh0$)
            oS$ = SIN(oTh0$)
            px0$ = opX$ + opA$ * oC$ * opCw$ - opB$ * oS$ * opSw$
            py0$ = opY$ - (opA$ * oC$ * opSw$ + opB$ * oS$ * opCw$)
            IF ABS(px0$) > SAFE_PX# OR ABS(py0$) > SAFE_PX# THEN
                clampHits$ += 1
                px0$ = CLAMP(px0$, SAFE_LO#, SAFE_PX#)
                py0$ = CLAMP(py0$, SAFE_LO#, SAFE_PX#)
            END IF
            FOR oj$ = 1 TO oSegN$
                oTt$ = oC$ * oCs$ - oS$ * oSn$
                oS$ = oS$ * oCs$ + oC$ * oSn$
                oC$ = oTt$
                px1$ = opX$ + opA$ * oC$ * opCw$ - opB$ * oS$ * opSw$
                py1$ = opY$ - (opA$ * oC$ * opSw$ + opB$ * oS$ * opCw$)
                IF ABS(px1$) > SAFE_PX# OR ABS(py1$) > SAFE_PX# THEN
                    clampHits$ += 1
                    px1$ = CLAMP(px1$, SAFE_LO#, SAFE_PX#)
                    py1$ = CLAMP(py1$, SAFE_LO#, SAFE_PX#)
                END IF
                oSkip$ = 0
                IF px0$ < 0 AND px1$ < 0 THEN oSkip$ = 1
                IF px0$ > drawMaxX$ AND px1$ > drawMaxX$ THEN oSkip$ = 1
                IF py0$ < 0 AND py1$ < 0 THEN oSkip$ = 1
                IF py0$ > MAX_Y# AND py1$ > MAX_Y# THEN oSkip$ = 1
                IF oSkip$ = 0 THEN
                    ' a segment with one end beyond drawMaxX$ is cut there (temp values; px0/py0 stay uncut)
                    oCx0$ = px0$
                    oCy0$ = py0$
                    oCx1$ = px1$
                    oCy1$ = py1$
                    IF px0$ > drawMaxX$ THEN
                        oCt$ = (drawMaxX$ - px0$) / (px1$ - px0$)
                        oCx0$ = drawMaxX$
                        oCy0$ = py0$ + oCt$ * (py1$ - py0$)
                    ELSEIF px1$ > drawMaxX$ THEN
                        oCt$ = (drawMaxX$ - px0$) / (px1$ - px0$)
                        oCx1$ = drawMaxX$
                        oCy1$ = py0$ + oCt$ * (py1$ - py0$)
                    END IF
                    LINE (CINT(oCx0$), CINT(oCy0$))-(CINT(oCx1$), CINT(oCy1$)), opCol$
                END IF
                px0$ = px1$
                py0$ = py1$
            NEXT
        END IF
    END IF
RETURN

' Unfilled circle around the locked body (radius rd + 5), only if <= R_LOCK# and left of drawMaxX$
[view:lockMarker]
    IF lockIdx$ >= 0 THEN
        IF pVis$(lockIdx$) = 1 AND pRd$(lockIdx$) + 5 <= R_LOCK# AND pSx$(lockIdx$) + pRd$(lockIdx$) + 5 <= drawMaxX$ THEN
            ccX$ = pSx$(lockIdx$)
            ccY$ = pSy$(lockIdx$)
            ccR$ = pRd$(lockIdx$) + 5
            ccCol$ = C_LOCK#
            ccFill$ = 0
            GOSUB [view:clampCircle]
        END IF
    END IF
RETURN

' A6: labels; hover label first (always, outside the cap), then the locked body,
' then star/planet, dwarf/asteroid/tno/comet/probe/voyager, moon/station/l2
[view:labels]
    nPl$ = 2
    lbCap$ = LABEL_MAX#
    lbXr$ = SCREEN_W#
    IF listMode$ > 0 THEN
        plX1$(2) = LIST_X#
        plY1$(2) = 0
        plX2$(2) = SCREEN_W#
        plY2$(2) = SCREEN_H#
        nPl$ = 3
        lbCap$ = LABEL_MAX_LIST#
        lbXr$ = LIST_X#
    END IF
    IF hovIdx$ >= 0 THEN
        IF pVis$(hovIdx$) = 1 THEN
            IF listMode$ = 0 OR pSx$(hovIdx$) < LIST_X# THEN
                lbW$ = LEN(bName$(hovIdx$)) * CHAR_W#
                lbX$ = CLAMP(pSx$(hovIdx$) + pRd$(hovIdx$) + 4, 0, lbXr$ - lbW$)
                lbY$ = CLAMP(pSy$(hovIdx$) - 9, 0, SCREEN_H# - 18)
                plX1$(nPl$) = lbX$
                plY1$(nPl$) = lbY$
                plX2$(nPl$) = lbX$ + lbW$
                plY2$(nPl$) = lbY$ + 18
                nPl$ += 1
                DRAWSTRING bName$(hovIdx$), CINT(lbX$), CINT(lbY$), C_HOVER#
                cHover$ = 1
            END IF
        END IF
    END IF
    IF lockIdx$ >= 0 AND lockIdx$ <> hovIdx$ THEN
        lt$ = lockIdx$
        GOSUB [view:tryLabel]
    END IF
    FOR lg$ = 1 TO 3
        FOR lb$ = 0 TO nBody$ - 1
            IF cLabels$ >= lbCap$ THEN EXIT FOR
            IF bGrp$(lb$) = lg$ AND lb$ <> lockIdx$ AND lb$ <> hovIdx$ THEN
                IF bA$(lb$) * zoom$ >= bLblMin$(lb$) THEN
                    lt$ = lb$
                    GOSUB [view:tryLabel]
                END IF
            END IF
        NEXT
    NEXT
RETURN

' One label candidate lt$: visible, rd <= LABEL_MAX_R#, anchor inside, box overlaps no placed box
[view:tryLabel]
    IF pVis$(lt$) = 1 AND pRd$(lt$) <= LABEL_MAX_R# THEN
        lbX$ = pSx$(lt$) + pRd$(lt$) + 4
        lbY$ = pSy$(lt$) - 9
        IF lbX$ >= 0 AND lbX$ <= SCREEN_W# - 60 AND lbY$ >= 0 AND lbY$ <= SCREEN_H# - 18 THEN
            lbW$ = LEN(bName$(lt$)) * CHAR_W#
            lbHit$ = 0
            FOR lk$ = 0 TO nPl$ - 1
                IF lbX$ < plX2$(lk$) AND lbX$ + lbW$ > plX1$(lk$) AND lbY$ < plY2$(lk$) AND lbY$ + 18 > plY1$(lk$) THEN
                    lbHit$ = 1
                    EXIT FOR
                END IF
            NEXT
            IF lbHit$ = 0 THEN
                plX1$(nPl$) = lbX$
                plY1$(nPl$) = lbY$
                plX2$(nPl$) = lbX$ + lbW$
                plY2$(nPl$) = lbY$ + 18
                nPl$ += 1
                DRAWSTRING bName$(lt$), CINT(lbX$), CINT(lbY$), C_LABEL#
                cLabels$ += 1
            END IF
        END IF
    END IF
RETURN

' A9/A10 retained list panel: full paint when lsFull$ = 1, else LIST_REPAINT# rows round-robin
' plus the rows whose bar changed (hover row, lock row)
[view:list]
    IF listMode$ > 0 THEN
        lsLockRow$ = -1
        IF lockIdx$ >= 0 THEN
            IF lsList$(lockIdx$) = listMode$ THEN lsLockRow$ = lsPos$(lockIdx$)
        END IF
        lsEnd$ = MIN(nLs$(listMode$) - 1, listTop$ + LIST_ROWS# - 1)
        cRows$ = lsEnd$ - listTop$ + 1
        IF lsFull$ = 1 THEN
            LINE (LIST_X#, 0)-(MAX_X#, MAX_Y#), 0, BF
            LINE (LIST_X#, 0)-(LIST_X#, MAX_Y#), C_ORBIT#
            lsHead$ = "Major bodies   x, y, z (AU)   L: next"
            IF listMode$ = 2 THEN lsHead$ = "Other bodies   x, y, z (AU)   L: next"
            DRAWSTRING lsHead$, LIST_X# + 8, 8, C_LIST_HEAD#
            FOR lsJ$ = listTop$ TO lsEnd$
                lsRow$ = lsJ$
                GOSUB [view:listRow]
            NEXT
            lsFull$ = 0
            lsNext$ = listTop$
        ELSE
            IF hovRow$ <> lsPrevHov$ THEN
                lsRow$ = lsPrevHov$
                GOSUB [view:listRow]
                lsRow$ = hovRow$
                GOSUB [view:listRow]
            END IF
            IF lsLockRow$ <> lsPrevLock$ THEN
                lsRow$ = lsPrevLock$
                GOSUB [view:listRow]
                lsRow$ = lsLockRow$
                GOSUB [view:listRow]
            END IF
            FOR lsJ$ = 1 TO LIST_REPAINT#
                IF lsNext$ < listTop$ OR lsNext$ > lsEnd$ THEN lsNext$ = listTop$
                lsRow$ = lsNext$
                GOSUB [view:listRow]
                lsNext$ = lsNext$ + 1
            NEXT
        END IF
        lsPrevHov$ = hovRow$
        lsPrevLock$ = lsLockRow$
    END IF
RETURN

' Repaint list row lsRow$ (list position) if it is in the window: bar strip, rebuilt text, one DRAWSTRING
[view:listRow]
    IF lsRow$ >= listTop$ AND lsRow$ <= lsEnd$ THEN
        lsY$ = LIST_Y0# + (lsRow$ - listTop$) * ROW_H#
        lsBar$ = 0
        IF lsRow$ = hovRow$ THEN lsBar$ = C_ROW_HOV#
        IF lsRow$ = lsLockRow$ THEN lsBar$ = C_ROW_LOCK#
        LINE (LIST_X# + 1, lsY$)-(MAX_X#, lsY$ + ROW_H# - 1), lsBar$, BF
        lsB$ = lsIdx$(listMode$, lsRow$)
        lrX$ = wx$(lsB$) / KM_PER_AU#
        lrY$ = wy$(lsB$) / KM_PER_AU#
        lrZ$ = wz$(lsB$) / KM_PER_AU#
        lrDash$ = 0
        lrP$ = bPar$(lsB$)
        IF lsInd$(lsB$) = 1 THEN
            IF lrP$ <> iSun$ THEN
                lrPx$ = wx$(lrP$) / KM_PER_AU#
                lrPy$ = wy$(lrP$) / KM_PER_AU#
                lrPz$ = wz$(lrP$) / KM_PER_AU#
                IF ROUND(100 * lrX$) = ROUND(100 * lrPx$) AND ROUND(100 * lrY$) = ROUND(100 * lrPy$) AND ROUND(100 * lrZ$) = ROUND(100 * lrPz$) THEN lrDash$ = 1
            END IF
        END IF
        IF lrDash$ = 1 THEN
            lrTxt$ = "-"
        ELSE
            lrTxt$ = FN SFixed$(lrX$, 2) + ", " + FN SFixed$(lrY$, 2) + ", " + FN SFixed$(lrZ$, 2)
        END IF
        DRAWSTRING lsName$(lsB$) + "   " + lrTxt$, LIST_X# + 8, lsY$, C_LIST#
    END IF
RETURN

' D7 HUD: one DRAWSTRING (joined top line); a second one (help line) when H is on or the model is paused
[view:hud]
    ckT$ = simT$
    ckHm$ = 0
    IF spIdx$ <= 1 THEN ckHm$ = 1
    GOSUB [view:clockText]
    kmPx$ = 1 / zoom$
    IF kmPx$ >= 1000000 THEN
        hudScale$ = FN Fixed$(kmPx$ / KM_PER_AU#, 2) + " AU"
    ELSE
        hudScale$ = FN Fixed$(kmPx$, 0) + " km"
    END IF
    hudLock$ = "-"
    IF lockIdx$ >= 0 THEN hudLock$ = bName$(lockIdx$)
    LINE (0, 0)-(719, 33), 0, BF
    hudTxt$ = "Speed: " + speedTxt$(spIdx$) + " | Date: " + ckTxt$ + " | Zoom: " + zIdx$ + "/" + ZMAX# + "   1 px = " + hudScale$ + " | Lock: " + hudLock$ + " | H help"
    DRAWSTRING hudTxt$, HUD_X#, HUD_Y#, C_HUD#
    IF helpShow$ = 1 OR spIdx$ = 0 THEN
        LINE (0, 1052)-(819, 1079), 0, BF
        DRAWSTRING HELP#, HUD_X#, HELP_Y#, C_HUD#
    END IF
RETURN

' A4 HUD time: in ckT$ (days since start), ckHm$ (1 = add " hh:mm"); out ckTxt$
[view:clockText]
    ckMinT$ = FLOOR(ckT$ * 1440 + CLOCK_EPS#)
    ckDay$ = FLOOR(ckMinT$ / 1440)
    ckHh$ = FLOOR((ckMinT$ - ckDay$ * 1440) / 60)
    ckMm$ = ckMinT$ - ckDay$ * 1440 - ckHh$ * 60
    ckTxt$ = FN DateText$(START_DAY# + ckDay$)
    IF ckHm$ = 1 THEN ckTxt$ = ckTxt$ + " " + RIGHT("0" + STR(ckHh$), 2) + ":" + RIGHT("0" + STR(ckMm$), 2)
RETURN

' LINE through the clamp: every value CLAMPed before CINT; each changed value counts
[view:clampLine]
    cq1$ = CLAMP(lx1$, SAFE_LO#, SAFE_PX#)
    cq2$ = CLAMP(ly1$, SAFE_LO#, SAFE_PX#)
    cq3$ = CLAMP(lx2$, SAFE_LO#, SAFE_PX#)
    cq4$ = CLAMP(ly2$, SAFE_LO#, SAFE_PX#)
    IF cq1$ <> lx1$ OR cq2$ <> ly1$ OR cq3$ <> lx2$ OR cq4$ <> ly2$ THEN
        clampHits$ += (cq1$ <> lx1$) + (cq2$ <> ly1$) + (cq3$ <> lx2$) + (cq4$ <> ly2$)
    END IF
    IF lBF$ = 1 THEN
        LINE (CINT(cq1$), CINT(cq2$))-(CINT(cq3$), CINT(cq4$)), lCol$, BF
    ELSE
        LINE (CINT(cq1$), CINT(cq2$))-(CINT(cq3$), CINT(cq4$)), lCol$
    END IF
RETURN

' CIRCLE through the clamp (centre and radius); ccFill$ 1 = filled
[view:clampCircle]
    cq1$ = CLAMP(ccX$, SAFE_LO#, SAFE_PX#)
    cq2$ = CLAMP(ccY$, SAFE_LO#, SAFE_PX#)
    cq3$ = CLAMP(ccR$, SAFE_LO#, SAFE_PX#)
    IF cq1$ <> ccX$ OR cq2$ <> ccY$ OR cq3$ <> ccR$ THEN
        clampHits$ += (cq1$ <> ccX$) + (cq2$ <> ccY$) + (cq3$ <> ccR$)
    END IF
    IF ccFill$ = 1 THEN
        CIRCLE (CINT(cq1$), CINT(cq2$)), MAX(1, CINT(cq3$)), ccCol$, 1
    ELSE
        CIRCLE (CINT(cq1$), CINT(cq2$)), MAX(1, CINT(cq3$)), ccCol$
    END IF
RETURN

[view:moduleEnd]
