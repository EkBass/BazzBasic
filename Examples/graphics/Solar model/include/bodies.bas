' bodies.bas - Solar System: the body data block and its loader
' Adding a body = one line in [bodies:data]. Fields (15, "|"-separated, spaces trimmed):
' name | parent | kind | radius_km | a | a_unit (AU|km) | period | p_unit (d|y|AUy) | e |
' colour key | dir (1 / -1 retrograde) | i_deg | Om_deg | w_deg | start_deg
' Kinds: star, planet, moon, station, l2, dwarf, asteroid, tno, comet, probe, voyager.
' i / Om / w = inclination, longitude of the ascending node, argument of perihelion
' (rounded textbook values). Moons, stations and l2: 0 0 0 (z = parent z).
' start_deg = mean anomaly on 2026-01-01 from the perihelion direction (display values,
' except Halley and Parker, computed from their perihelion dates).
' voyager: a = distance on the start date (AU), period = speed in AU per year (p_unit AUy),
'   i = ecliptic latitude, Om = ecliptic longitude, w and start unused (0), e 0.
'   No orbit; a straight line outward from the Sun.
' l2 (JWST): parent Earth, a = distance beyond Earth along Sun->Earth (km),
'   period = halo period, start = halo phase; halo amplitude = JWST_HALO_KM#.
' Parents must stand above their moons.

DIM raw$
LET nRaw$ = 0

' --- parsed body table (index 0 .. nBody$ - 1) ---
DIM bName$, bPar$, bKind$, bR$, bA$, bP$, bE$, bCol$, bDir$
DIM bCw$, bSw$, bM0$, bB$, bMinR$
DIM bInc$, bMode$, bPx$, bPy$, bPz$, bQx$, bQy$, bQz$
DIM idx$
DIM fld$
LET nBody$ = 0
LET nFld$ = 0
LET bdKey$ = ""
LET bdPar$ = ""
LET bdA$ = 0
LET bdP$ = 0
LET bdU$ = ""
LET bdBad$ = 0
LET bdCi$ = 0
LET bdSi$ = 0
LET bdCo$ = 0
LET bdSo$ = 0
LET bdCw$ = 0
LET bdSw$ = 0

GOTO [bodies:moduleEnd]

[bodies:data]
    raw$(nRaw$) = "Sun       | -         | star     | 696000 | 0       | km | 0      | d   | 0     | SUN        |  1 |      0 |     0 |     0 |     0" : nRaw$ += 1
    raw$(nRaw$) = "Mercury   | Sun       | planet   |   2440 | 0.387   | AU | 87.97  | d   | 0.206 | MERCURY    |  1 |    7.0 |  48.3 |  29.1 |   138" : nRaw$ += 1
    raw$(nRaw$) = "Venus     | Sun       | planet   |   6052 | 0.723   | AU | 224.7  | d   | 0.007 | VENUS      |  1 |   3.39 |  76.7 |  54.9 |   275" : nRaw$ += 1
    raw$(nRaw$) = "Earth     | Sun       | planet   |   6371 | 1.0     | AU | 365.25 | d   | 0.017 | EARTH      |  1 |      0 |     0 | 102.9 |    53" : nRaw$ += 1
    raw$(nRaw$) = "Moon      | Earth     | moon     |   1737 | 384400  | km | 27.32  | d   | 0     | MOON       |  1 |      0 |     0 |     0 |   190" : nRaw$ += 1
    raw$(nRaw$) = "ISS       | Earth     | station  |   0.05 | 6791    | km | 0.0644 | d   | 0     | ISS        |  1 |      0 |     0 |     0 |   328" : nRaw$ += 1
    raw$(nRaw$) = "Hubble    | Earth     | station  |   0.01 | 6890    | km | 0.066  | d   | 0     | HUBBLE     |  1 |      0 |     0 |     0 |   105" : nRaw$ += 1
    raw$(nRaw$) = "JWST      | Earth     | l2       |   0.01 | 1500000 | km | 180    | d   | 0     | JWST       |  1 |      0 |     0 |     0 |   243" : nRaw$ += 1
    raw$(nRaw$) = "Mars      | Sun       | planet   |   3390 | 1.524   | AU | 687    | d   | 0.093 | MARS       |  1 |   1.85 |  49.6 | 286.5 |   105" : nRaw$ += 1
    raw$(nRaw$) = "Phobos    | Mars      | moon     |     11 | 9376    | km | 0.319  | d   | 0     | MOON_GREY  |  1 |      0 |     0 |     0 |   243" : nRaw$ += 1
    raw$(nRaw$) = "Deimos    | Mars      | moon     |      6 | 23463   | km | 1.263  | d   | 0     | MOON_BEIGE |  1 |      0 |     0 |     0 |    20" : nRaw$ += 1
    raw$(nRaw$) = "Ceres     | Sun       | dwarf    |    470 | 2.77    | AU | 4.6    | y   | 0.076 | DWARF_A    |  1 |  10.59 |  80.3 |  73.6 |   158" : nRaw$ += 1
    raw$(nRaw$) = "Vesta     | Sun       | asteroid |    263 | 2.36    | AU | 3.63   | y   | 0.089 | ASTEROID   |  1 |   7.14 | 103.8 | 151.2 |   295" : nRaw$ += 1
    raw$(nRaw$) = "Pallas    | Sun       | asteroid |    256 | 2.77    | AU | 4.61   | y   | 0.23  | ASTEROID   |  1 |   34.8 | 173.0 | 310.0 |    73" : nRaw$ += 1
    raw$(nRaw$) = "Hygiea    | Sun       | asteroid |    217 | 3.14    | AU | 5.56   | y   | 0.11  | ASTEROID   |  1 |   3.83 | 283.2 | 312.3 |   210" : nRaw$ += 1
    raw$(nRaw$) = "Jupiter   | Sun       | planet   |  69911 | 5.203   | AU | 11.86  | y   | 0.049 | JUPITER    |  1 |    1.3 | 100.5 | 273.9 |   348" : nRaw$ += 1
    raw$(nRaw$) = "Io        | Jupiter   | moon     |   1822 | 421700  | km | 1.769  | d   | 0     | MOON_GREY  |  1 |      0 |     0 |     0 |   125" : nRaw$ += 1
    raw$(nRaw$) = "Europa    | Jupiter   | moon     |   1561 | 671034  | km | 3.551  | d   | 0     | MOON_BEIGE |  1 |      0 |     0 |     0 |   263" : nRaw$ += 1
    raw$(nRaw$) = "Ganymede  | Jupiter   | moon     |   2634 | 1070412 | km | 7.155  | d   | 0     | MOON_GREY  |  1 |      0 |     0 |     0 |    40" : nRaw$ += 1
    raw$(nRaw$) = "Callisto  | Jupiter   | moon     |   2410 | 1882709 | km | 16.689 | d   | 0     | MOON_BEIGE |  1 |      0 |     0 |     0 |   178" : nRaw$ += 1
    raw$(nRaw$) = "Saturn    | Sun       | planet   |  58232 | 9.537   | AU | 29.46  | y   | 0.057 | SATURN     |  1 |   2.49 | 113.7 | 339.4 |   315" : nRaw$ += 1
    raw$(nRaw$) = "Mimas     | Saturn    | moon     |    198 | 185539  | km | 0.942  | d   | 0     | MOON_GREY  |  1 |      0 |     0 |     0 |    93" : nRaw$ += 1
    raw$(nRaw$) = "Enceladus | Saturn    | moon     |    252 | 237948  | km | 1.37   | d   | 0     | MOON_BEIGE |  1 |      0 |     0 |     0 |   230" : nRaw$ += 1
    raw$(nRaw$) = "Tethys    | Saturn    | moon     |    531 | 294619  | km | 1.888  | d   | 0     | MOON_GREY  |  1 |      0 |     0 |     0 |     8" : nRaw$ += 1
    raw$(nRaw$) = "Dione     | Saturn    | moon     |    561 | 377396  | km | 2.737  | d   | 0     | MOON_BEIGE |  1 |      0 |     0 |     0 |   145" : nRaw$ += 1
    raw$(nRaw$) = "Rhea      | Saturn    | moon     |    764 | 527108  | km | 4.518  | d   | 0     | MOON_GREY  |  1 |      0 |     0 |     0 |   283" : nRaw$ += 1
    raw$(nRaw$) = "Titan     | Saturn    | moon     |   2575 | 1221870 | km | 15.945 | d   | 0     | MOON_BEIGE |  1 |      0 |     0 |     0 |    60" : nRaw$ += 1
    raw$(nRaw$) = "Iapetus   | Saturn    | moon     |    735 | 3560820 | km | 79.32  | d   | 0     | MOON_GREY  |  1 |      0 |     0 |     0 |   198" : nRaw$ += 1
    raw$(nRaw$) = "Uranus    | Sun       | planet   |  25362 | 19.19   | AU | 84.01  | y   | 0.046 | URANUS     |  1 |   0.77 |  74.0 |  96.9 |   335" : nRaw$ += 1
    raw$(nRaw$) = "Miranda   | Uranus    | moon     |    236 | 129390  | km | 1.413  | d   | 0     | MOON_BEIGE |  1 |      0 |     0 |     0 |   113" : nRaw$ += 1
    raw$(nRaw$) = "Ariel     | Uranus    | moon     |    579 | 191020  | km | 2.52   | d   | 0     | MOON_GREY  |  1 |      0 |     0 |     0 |   250" : nRaw$ += 1
    raw$(nRaw$) = "Umbriel   | Uranus    | moon     |    585 | 266000  | km | 4.144  | d   | 0     | MOON_BEIGE |  1 |      0 |     0 |     0 |    28" : nRaw$ += 1
    raw$(nRaw$) = "Titania   | Uranus    | moon     |    789 | 435910  | km | 8.706  | d   | 0     | MOON_GREY  |  1 |      0 |     0 |     0 |   165" : nRaw$ += 1
    raw$(nRaw$) = "Oberon    | Uranus    | moon     |    761 | 583520  | km | 13.46  | d   | 0     | MOON_BEIGE |  1 |      0 |     0 |     0 |   303" : nRaw$ += 1
    raw$(nRaw$) = "Neptune   | Sun       | planet   |  24622 | 30.07   | AU | 164.8  | y   | 0.01  | NEPTUNE    |  1 |   1.77 | 131.8 | 273.2 |    80" : nRaw$ += 1
    raw$(nRaw$) = "Triton    | Neptune   | moon     |   1353 | 354759  | km | 5.877  | d   | 0     | MOON_GREY  | -1 |      0 |     0 |     0 |   218" : nRaw$ += 1
    raw$(nRaw$) = "Proteus   | Neptune   | moon     |    210 | 117647  | km | 1.122  | d   | 0     | MOON_BEIGE |  1 |      0 |     0 |     0 |   355" : nRaw$ += 1
    raw$(nRaw$) = "Pluto     | Sun       | dwarf    |   1188 | 39.48   | AU | 247.9  | y   | 0.249 | DWARF_B    |  1 |  17.16 | 110.3 | 113.8 |   133" : nRaw$ += 1
    raw$(nRaw$) = "Charon    | Pluto     | moon     |    606 | 19591   | km | 6.387  | d   | 0     | CHARON     |  1 |      0 |     0 |     0 |    10" : nRaw$ += 1
    raw$(nRaw$) = "Haumea    | Sun       | dwarf    |    780 | 43.1    | AU | 283    | y   | 0.19  | DWARF_C    |  1 |   28.2 | 122.2 |   239 |   270" : nRaw$ += 1
    raw$(nRaw$) = "Makemake  | Sun       | dwarf    |    715 | 45.4    | AU | 306    | y   | 0.16  | DWARF_A    |  1 |   29.0 |  79.6 | 294.8 |    48" : nRaw$ += 1
    raw$(nRaw$) = "Quaoar    | Sun       | tno      |    555 | 43.7    | AU | 289    | y   | 0.04  | DWARF_B    |  1 |    8.0 | 188.8 |   155 |   185" : nRaw$ += 1
    raw$(nRaw$) = "Eris      | Sun       | dwarf    |   1163 | 67.9    | AU | 559    | y   | 0.44  | DWARF_B    |  1 |   44.0 |  35.9 | 151.6 |   323" : nRaw$ += 1
    raw$(nRaw$) = "Gonggong  | Sun       | tno      |    615 | 67.4    | AU | 553    | y   | 0.5   | DWARF_C    |  1 |   30.9 | 336.8 | 207.7 |   100" : nRaw$ += 1
    raw$(nRaw$) = "Sedna     | Sun       | tno      |    500 | 506     | AU | 11400  | y   | 0.85  | DWARF_B    |  1 |   11.9 | 144.4 | 311.3 |   238" : nRaw$ += 1
    raw$(nRaw$) = "Halley    | Sun       | comet    |      5 | 17.83   | AU | 75.3   | y   | 0.967 | COMET      |  1 |  162.2 |  59.4 | 112.0 | 190.7" : nRaw$ += 1
    raw$(nRaw$) = "Parker    | Sun       | probe    |  0.002 | 0.388   | AU | 88     | d   | 0.88  | PROBE      |  1 |    3.4 |  76.7 |     0 |  81.8" : nRaw$ += 1
    raw$(nRaw$) = "Voyager 1 | Sun       | voyager  |  0.002 | 170     | AU | 3.6    | AUy | 0     | VOYAGER    |  1 |     35 |   255 |     0 |     0" : nRaw$ += 1
    raw$(nRaw$) = "Voyager 2 | Sun       | voyager  |  0.002 | 142.5   | AU | 3.2    | AUy | 0     | VOYAGER    |  1 |    -34 |   290 |     0 |     0" : nRaw$ += 1
RETURN

' Parse and validate every data line (runs before SCREEN, so errors print to the console)
[bodies:load]
    GOSUB [bodies:data]
    FOR bi$ = 0 TO nRaw$ - 1
        nFld$ = SPLIT(fld$, raw$(bi$), "|")
        IF nFld$ <> 15 THEN
            PRINT "bodies.bas: line " + (bi$ + 1) + " has " + nFld$ + " fields, need 15"
            END
        END IF
        FOR bf$ = 0 TO 14
            fld$(bf$) = TRIM(fld$(bf$))
        NEXT
        bdKey$ = fld$(9)
        IF HASKEY(pal$(bdKey$)) = 0 THEN
            PRINT "bodies.bas: " + fld$(0) + ": unknown colour key '" + bdKey$ + "' (field 10)"
            END
        END IF
        bdU$ = fld$(7)
        bdBad$ = 0
        IF bdU$ <> "d" AND bdU$ <> "y" AND bdU$ <> "AUy" THEN bdBad$ = 1
        IF fld$(2) = "voyager" AND bdU$ <> "AUy" THEN bdBad$ = 1
        IF bdBad$ = 1 THEN
            PRINT "bodies.bas: " + fld$(0) + ": unknown period unit '" + bdU$ + "' (field 8)"
            END
        END IF
        bdPar$ = fld$(1)
        IF bdPar$ = "-" THEN
            bPar$(bi$) = -1
        ELSE
            IF HASKEY(idx$(bdPar$)) = 0 THEN
                PRINT "bodies.bas: " + fld$(0) + ": parent '" + bdPar$ + "' is not defined above (field 2)"
                END
            END IF
            bPar$(bi$) = idx$(bdPar$)
        END IF
        bName$(bi$) = fld$(0)
        bKind$(bi$) = fld$(2)
        bR$(bi$) = VAL(fld$(3))
        bdA$ = VAL(fld$(4))
        IF fld$(5) = "AU" THEN bdA$ = bdA$ * KM_PER_AU#
        bA$(bi$) = bdA$
        bdP$ = VAL(fld$(6))
        IF bdU$ = "y" THEN bdP$ = bdP$ * 365.25
        IF bdU$ = "AUy" THEN bdP$ = bdP$ * KM_PER_AU# / 365.25
        bP$(bi$) = bdP$
        bE$(bi$) = VAL(fld$(8))
        bCol$(bi$) = pal$(bdKey$)
        bDir$(bi$) = VAL(fld$(10))
        bInc$(bi$) = VAL(fld$(11))
        bM0$(bi$) = RAD(VAL(fld$(14)))
        bB$(bi$) = bA$(bi$) * SQR(1 - bE$(bi$) * bE$(bi$))
        ' mode 0 normal, 1 voyager (straight line), 2 l2 (JWST)
        bMode$(bi$) = 0
        IF bKind$(bi$) = "voyager" THEN bMode$(bi$) = 1
        IF bKind$(bi$) = "l2" THEN bMode$(bi$) = 2
        ' unit vectors from i, Om, w (degrees)
        bdCi$ = COS(RAD(VAL(fld$(11))))
        bdSi$ = SIN(RAD(VAL(fld$(11))))
        bdCo$ = COS(RAD(VAL(fld$(12))))
        bdSo$ = SIN(RAD(VAL(fld$(12))))
        bdCw$ = COS(RAD(VAL(fld$(13))))
        bdSw$ = SIN(RAD(VAL(fld$(13))))
        IF bMode$(bi$) = 1 THEN
            bPx$(bi$) = bdCi$ * bdCo$
            bPy$(bi$) = bdCi$ * bdSo$
            bPz$(bi$) = bdSi$
            bQx$(bi$) = 0
            bQy$(bi$) = 0
            bQz$(bi$) = 0
        ELSE
            bPx$(bi$) = bdCw$ * bdCo$ - bdSw$ * bdSo$ * bdCi$
            bPy$(bi$) = bdCw$ * bdSo$ + bdSw$ * bdCo$ * bdCi$
            bPz$(bi$) = bdSw$ * bdSi$
            bQx$(bi$) = 0 - bdSw$ * bdCo$ - bdCw$ * bdSo$ * bdCi$
            bQy$(bi$) = bdCw$ * bdCo$ * bdCi$ - bdSw$ * bdSo$
            bQz$(bi$) = bdCw$ * bdSi$
        END IF
        bMinR$(bi$) = 1
        IF bKind$(bi$) = "star" OR bKind$(bi$) = "planet" THEN bMinR$(bi$) = 2
        idx$(fld$(0)) = bi$
        nBody$ = nBody$ + 1
    NEXT
RETURN

[bodies:moduleEnd]
