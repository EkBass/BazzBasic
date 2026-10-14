' ============================================
' https://rosettacode.org/wiki/Haversine_formula
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' Great-circle distance between two points given in degrees.
'   a = sin^2(dLat/2) + cos(lat1) * cos(lat2) * sin^2(dLon/2)
'   c = 2 * atan2(sqrt(a), sqrt(1 - a))
'   d = R * c

DEF FN Haversine$(lat1$, lon1$, lat2$, lon2$, radius$)
    LET dLat$ = RAD(lat2$ - lat1$)
    LET dLon$ = RAD(lon2$ - lon1$)
    LET a$ = POW(SIN(dLat$ / 2), 2) +
             COS(RAD(lat1$)) * COS(RAD(lat2$)) * POW(SIN(dLon$ / 2), 2)
    RETURN radius$ * 2 * ATAN2(SQR(a$), SQR(1 - a$))
END DEF

[inits]
    ' BNA (Nashville) and LAX (Los Angeles)
    LET BNA_LAT# = 36.12
    LET BNA_LON# = -86.67
    LET LAX_LAT# = 33.94
    LET LAX_LON# = -118.40
    LET R_MEAN# = 6371.0      ' IUGG mean earth radius
    LET R_ALT# = 6372.8       ' radius used by most Rosetta entries

[main]
    PRINT "BNA -> LAX great-circle distance:"
    PRINT "  R = 6371.0 km: "; FN Haversine$(BNA_LAT#, BNA_LON#, LAX_LAT#, LAX_LON#, R_MEAN#); " km"
    PRINT "  R = 6372.8 km: "; FN Haversine$(BNA_LAT#, BNA_LON#, LAX_LAT#, LAX_LON#, R_ALT#); " km"
END

' Output:
' BNA -> LAX great-circle distance:
'   R = 6371.0 km: 2886.4444428379834 km
'   R = 6372.8 km: 2887.2599506071106 km
