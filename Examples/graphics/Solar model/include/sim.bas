' sim.bas - Solar System: zoom table, derived per-body values, positions (Kepler, 3D)

' --- world positions in km (ecliptic, y up, z out of the plane, Sun at 0,0,0) ---
DIM wx$, wy$, wz$
' --- zoom table: px per km for notch 0 .. ZMAX# ---
DIM zoomTab$
' --- derived per-body values (filled in [sim:prepare]) ---
DIM bEll$, bEx$, bEy$, bSmall$, bGrp$, bLblMin$, bOrbMin$, bOrbCol$
' --- projected orbit (principal semi-axes bOA$ >= bOB$, axis bCw$/bSw$), list zoom notch ---
DIM bOA$, bOB$, bListN$, bMoonA$
LET simT$ = 0
LET iSun$ = -1
LET iEarth$ = -1
LET iSedna$ = -1
LET iSaturn$ = -1
LET sPar$ = 0
LET sM$ = 0
LET sD$ = 0
LET kepX$ = 0
LET kepY$ = 0
LET kM$ = 0
LET kEc$ = 0
LET kE$ = 0
' --- [sim:l2] ---
LET lEx$ = 0
LET lEy$ = 0
LET lEz$ = 0
LET lR$ = 0
LET lUx$ = 0
LET lUy$ = 0
LET lUz$ = 0
LET lH$ = 0
LET lPh$ = 0
LET lLat$ = 0
' --- projected orbit in [sim:prepare] ---
LET prP2x$ = 0
LET prP2y$ = 0
LET prQ2x$ = 0
LET prQ2y$ = 0
LET prBq$ = 0
LET prPP$ = 0
LET prQQ$ = 0
LET prPQ$ = 0
LET prT0$ = 0
LET prA1x$ = 0
LET prA1y$ = 0
LET prB1x$ = 0
LET prB1y$ = 0

GOTO [sim:moduleEnd]

' Zoom table and derived values (once, before SCREEN)
[sim:prepare]
    FOR zn$ = 0 TO ZMAX#
        zoomTab$(zn$) = ZOOM_MAX# / POW(1.25, ZMAX# - zn$)
    NEXT
    FOR pi2$ = 0 TO nBody$ - 1
        wx$(pi2$) = 0
        wy$(pi2$) = 0
        wz$(pi2$) = 0
        bMoonA$(pi2$) = 0
        IF bKind$(pi2$) = "star" THEN iSun$ = pi2$
        ' ellipse (Kepler) when e > 0.2
        bEll$(pi2$) = 0
        IF bE$(pi2$) > 0.2 THEN bEll$(pi2$) = 1
        ' projected orbit (A1): defaults for bodies without an orbit line
        bOA$(pi2$) = 0
        bOB$(pi2$) = 0
        bCw$(pi2$) = 1
        bSw$(pi2$) = 0
        bEx$(pi2$) = 0
        bEy$(pi2$) = 0
        IF bMode$(pi2$) = 0 AND bPar$(pi2$) >= 0 THEN
            prP2x$ = bA$(pi2$) * bPx$(pi2$)
            prP2y$ = bA$(pi2$) * bPy$(pi2$)
            prBq$ = bA$(pi2$)
            IF bEll$(pi2$) = 1 THEN prBq$ = bB$(pi2$)
            prQ2x$ = prBq$ * bQx$(pi2$)
            prQ2y$ = prBq$ * bQy$(pi2$)
            prPP$ = prP2x$ * prP2x$ + prP2y$ * prP2y$
            prQQ$ = prQ2x$ * prQ2x$ + prQ2y$ * prQ2y$
            prPQ$ = prP2x$ * prQ2x$ + prP2y$ * prQ2y$
            prT0$ = 0
            IF ABS(2 * prPQ$) > 0.000000001 * (prPP$ + prQQ$) OR ABS(prPP$ - prQQ$) > 0.000000001 * (prPP$ + prQQ$) THEN
                prT0$ = 0.5 * ATAN2(2 * prPQ$, prPP$ - prQQ$)
            END IF
            prA1x$ = prP2x$ * COS(prT0$) + prQ2x$ * SIN(prT0$)
            prA1y$ = prP2y$ * COS(prT0$) + prQ2y$ * SIN(prT0$)
            prB1x$ = prQ2x$ * COS(prT0$) - prP2x$ * SIN(prT0$)
            prB1y$ = prQ2y$ * COS(prT0$) - prP2y$ * SIN(prT0$)
            bOA$(pi2$) = SQR(prA1x$ * prA1x$ + prA1y$ * prA1y$)
            bOB$(pi2$) = SQR(prB1x$ * prB1x$ + prB1y$ * prB1y$)
            IF bOA$(pi2$) > 0 THEN
                bCw$(pi2$) = prA1x$ / bOA$(pi2$)
                bSw$(pi2$) = prA1y$ / bOA$(pi2$)
            END IF
            IF bOB$(pi2$) < bOA$(pi2$) * 0.01 THEN bOB$(pi2$) = bOA$(pi2$) * 0.01
            ' ellipse centre = parent - a e P (circle: parent)
            IF bEll$(pi2$) = 1 THEN
                bEx$(pi2$) = 0 - bA$(pi2$) * bE$(pi2$) * bPx$(pi2$)
                bEy$(pi2$) = 0 - bA$(pi2$) * bE$(pi2$) * bPy$(pi2$)
            END IF
        END IF
        ' moons, stations and l2 hide when a zoom < 4
        bSmall$(pi2$) = 0
        IF bKind$(pi2$) = "moon" OR bKind$(pi2$) = "station" OR bKind$(pi2$) = "l2" THEN bSmall$(pi2$) = 1
        ' label group (1 star/planet, 2 dwarf/asteroid/tno/comet/probe/voyager, 3 moon/station/l2)
        ' and the a zoom threshold
        bGrp$(pi2$) = 0
        bLblMin$(pi2$) = 12
        IF bKind$(pi2$) = "star" OR bKind$(pi2$) = "planet" THEN bGrp$(pi2$) = 1
        IF bKind$(pi2$) = "dwarf" OR bKind$(pi2$) = "asteroid" OR bKind$(pi2$) = "tno" THEN bGrp$(pi2$) = 2
        IF bKind$(pi2$) = "comet" OR bKind$(pi2$) = "probe" OR bKind$(pi2$) = "voyager" THEN bGrp$(pi2$) = 2
        IF bKind$(pi2$) = "moon" OR bKind$(pi2$) = "station" OR bKind$(pi2$) = "l2" THEN bGrp$(pi2$) = 3
        IF bKind$(pi2$) = "star" THEN bLblMin$(pi2$) = -1
        IF bKind$(pi2$) = "moon" THEN bLblMin$(pi2$) = 30
        IF bKind$(pi2$) = "station" OR bKind$(pi2$) = "l2" THEN bLblMin$(pi2$) = 15
        ' orbit line: heliocentric min 3 px (C_ORBIT#), moons/stations min 6 px (C_ORBIT_MOON#)
        bOrbMin$(pi2$) = 6
        bOrbCol$(pi2$) = C_ORBIT_MOON#
        IF bPar$(pi2$) >= 0 THEN
            IF bKind$(bPar$(pi2$)) = "star" THEN
                bOrbMin$(pi2$) = 3
                bOrbCol$(pi2$) = C_ORBIT#
            END IF
            ' largest moon orbit of the parent (list zoom)
            IF bKind$(pi2$) = "moon" THEN bMoonA$(bPar$(pi2$)) = MAX(bMoonA$(bPar$(pi2$)), bA$(pi2$))
        END IF
    NEXT
    ' list zoom (A9): moon system within LIST_FIT_PX#, else disc radius within LIST_DISC_R#
    FOR pi2$ = 0 TO nBody$ - 1
        bListN$(pi2$) = 0
        FOR zn$ = ZMAX# TO 0 STEP -1
            IF bMoonA$(pi2$) > 0 THEN
                IF bMoonA$(pi2$) * zoomTab$(zn$) <= LIST_FIT_PX# THEN
                    bListN$(pi2$) = zn$
                    EXIT FOR
                END IF
            ELSE
                IF bR$(pi2$) * zoomTab$(zn$) <= LIST_DISC_R# THEN
                    bListN$(pi2$) = zn$
                    EXIT FOR
                END IF
            END IF
        NEXT
        bListN$(pi2$) = CLAMP(bListN$(pi2$), 0, ZMAX#)
    NEXT
    IF HASKEY(idx$("Earth")) THEN iEarth$ = idx$("Earth")
    IF HASKEY(idx$("Sedna")) THEN iSedna$ = idx$("Sedna")
    IF HASKEY(idx$("Saturn")) THEN iSaturn$ = idx$("Saturn")
RETURN

' A1: positions for simT$ (days since the start date), data order (parents first)
[sim:update]
    FOR si$ = 0 TO nBody$ - 1
        sPar$ = bPar$(si$)
        IF sPar$ < 0 THEN
            wx$(si$) = 0
            wy$(si$) = 0
            wz$(si$) = 0
        ELSEIF bMode$(si$) = 1 THEN
            ' voyager: straight line outward, d = a + speed t (nothing clamps d)
            sD$ = bA$(si$) + bP$(si$) * simT$
            wx$(si$) = sD$ * bPx$(si$)
            wy$(si$) = sD$ * bPy$(si$)
            wz$(si$) = sD$ * bPz$(si$)
        ELSEIF bMode$(si$) = 2 THEN
            GOSUB [sim:l2]
        ELSE
            sM$ = bM0$(si$) + bDir$(si$) * TAU# * simT$ / bP$(si$)
            sM$ = sM$ - FLOOR(sM$ / TAU#) * TAU#
            IF bEll$(si$) = 1 THEN
                kM$ = sM$
                kEc$ = bE$(si$)
                GOSUB [sim:kepler]
                kepX$ = bA$(si$) * (COS(kE$) - kEc$)
                kepY$ = bB$(si$) * SIN(kE$)
            ELSE
                kepX$ = bA$(si$) * COS(sM$)
                kepY$ = bA$(si$) * SIN(sM$)
            END IF
            wx$(si$) = wx$(sPar$) + kepX$ * bPx$(si$) + kepY$ * bQx$(si$)
            wy$(si$) = wy$(sPar$) + kepX$ * bPy$(si$) + kepY$ * bQy$(si$)
            wz$(si$) = wz$(sPar$) + kepX$ * bPz$(si$) + kepY$ * bQz$(si$)
        END IF
    NEXT
RETURN

' JWST at L2 (body si$, parent sPar$ = Earth): bA$ beyond the parent along Sun->parent, plus the halo
[sim:l2]
    lEx$ = wx$(sPar$)
    lEy$ = wy$(sPar$)
    lEz$ = wz$(sPar$)
    lR$ = SQR(lEx$ * lEx$ + lEy$ * lEy$ + lEz$ * lEz$)
    lUx$ = 0
    lUy$ = 0
    lUz$ = 0
    IF lR$ > 0 THEN
        lUx$ = lEx$ / lR$
        lUy$ = lEy$ / lR$
        lUz$ = lEz$ / lR$
    END IF
    lH$ = SQR(lUx$ * lUx$ + lUy$ * lUy$)
    lPh$ = bM0$(si$) + TAU# * simT$ / bP$(si$)
    lLat$ = JWST_HALO_KM# * SIN(lPh$)
    wx$(si$) = lEx$ + bA$(si$) * lUx$
    wy$(si$) = lEy$ + bA$(si$) * lUy$
    IF lH$ > 0 THEN
        wx$(si$) = wx$(si$) - lLat$ * lUy$ / lH$
        wy$(si$) = wy$(si$) + lLat$ * lUx$ / lH$
    END IF
    wz$(si$) = lEz$ + bA$(si$) * lUz$ + JWST_HALO_KM# * COS(lPh$)
RETURN

' Kepler's equation E - e SIN(E) = M: Danby start + 8 Newton steps. In: kM$, kEc$. Out: kE$
[sim:kepler]
    kE$ = kM$ + 0.85 * kEc$ * SGN(SIN(kM$))
    FOR kj$ = 1 TO 8
        kE$ = kE$ - (kE$ - kEc$ * SIN(kE$) - kM$) / (1 - kEc$ * COS(kE$))
    NEXT
RETURN

[sim:moduleEnd]
