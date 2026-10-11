' ============================================
' https://rosettacode.org/wiki/Box_the_compass
' BazzBasic: https://github.com/EkBass/BazzBasic
' Task: write a function that turns a heading in degrees into one
'       of the 32 compass points, and print a table for 33 headings.
' ============================================

' The 32 points, clockwise from North. A constant, so the
' functions below can read it (they cannot see $ variables).
LET POINTS# = "North,North by east,North-northeast,Northeast by north," +
              "Northeast,Northeast by east,East-northeast,East by north," +
              "East,East by south,East-southeast,Southeast by east," +
              "Southeast,Southeast by south,South-southeast,South by east," +
              "South,South by west,South-southwest,Southwest by south," +
              "Southwest,Southwest by west,West-southwest,West by south," +
              "West,West by north,West-northwest,Northwest by west," +
              "Northwest,Northwest by north,North-northwest,North by west"
LET SECTOR# = 11.25             ' 360 / 32 degrees per point

' 0-based point number: each point covers half a sector on either side
DEF FN PointIndex$(deg$)
    RETURN MOD(INT(deg$ / SECTOR# + 0.5), 32)
END DEF

DEF FN CompassPoint$(deg$)
    DIM names$
    LET n$ = SPLIT(names$, POINTS#, ",")
    RETURN names$(FN PointIndex$(deg$))
END DEF

' Format a number with exactly two decimals, e.g. 67.5 -> "67.50"
DEF FN Fmt2$(x$)
    LET cents$ = ROUND(x$ * 100)
    RETURN INT(cents$ / 100) + "." + RIGHT("0" + MOD(cents$, 100), 2)
END DEF

[inits]
    DIM raw$
    LET count$ = SPLIT(raw$, "0.0,16.87,16.88,33.75,50.62,50.63,67.5,84.37,84.38," +
                             "101.25,118.12,118.13,135.0,151.87,151.88,168.75," +
                             "185.62,185.63,202.5,219.37,219.38,236.25,253.12," +
                             "253.13,270.0,286.87,286.88,303.75,320.62,320.63," +
                             "337.5,354.37,354.38", ",")
    LET deg$ = 0
    LET idx$ = 0
    LET name$ = ""

[main]
    PRINT "Index  Compass point         Degree"
    FOR i$ = 0 TO count$ - 1
        deg$ = VAL(raw$(i$))
        idx$ = FN PointIndex$(deg$) + 1               ' 1-based, as on Wikipedia
        name$ = FN CompassPoint$(deg$)
        PRINT RIGHT("   " + idx$, 5); "  ";
        PRINT LEFT(name$ + REPEAT(" ", 20), 20);
        PRINT RIGHT("      " + FN Fmt2$(deg$), 8)
    NEXT
END

' Output:
' Index  Compass point         Degree
'     1  North                   0.00
'     2  North by east          16.87
'     3  North-northeast        16.88
'     4  Northeast by north     33.75
'     5  Northeast              50.62
'     6  Northeast by east      50.63
'     7  East-northeast         67.50
'     8  East by north          84.37
'     9  East                   84.38
'    10  East by south         101.25
'    11  East-southeast        118.12
'    12  Southeast by east     118.13
'    13  Southeast             135.00
'    14  Southeast by south    151.87
'    15  South-southeast       151.88
'    16  South by east         168.75
'    17  South                 185.62
'    18  South by west         185.63
'    19  South-southwest       202.50
'    20  Southwest by south    219.37
'    21  Southwest             219.38
'    22  Southwest by west     236.25
'    23  West-southwest        253.12
'    24  West by south         253.13
'    25  West                  270.00
'    26  West by north         286.87
'    27  West-northwest        286.88
'    28  Northwest by west     303.75
'    29  Northwest             320.62
'    30  Northwest by north    320.63
'    31  North-northwest       337.50
'    32  North by west         354.37
'     1  North                 354.38