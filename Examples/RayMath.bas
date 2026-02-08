' ============================================
' RayMath.bas - Math utilities for raycasting
' Compile: bazzbasic.exe -lib RayMath.bas
' ============================================

' Normalize angle to 0..2*PI range
DEF FN normalizeAngle$(angle$, twoPi$)
    LET a$ = angle$
    WHILE a$ < 0
        a$ = a$ + twoPi$
    WEND
    WHILE a$ >= twoPi$
        a$ = a$ - twoPi$
    WEND
    RETURN a$
END DEF

' Clamp value between min and max
DEF FN clamp$(value$, minVal$, maxVal$)
    IF value$ < minVal$ THEN RETURN minVal$
    IF value$ > maxVal$ THEN RETURN maxVal$
    RETURN value$
END DEF

' Calculate wall brightness based on distance
DEF FN wallBrightness$(distance$, maxDist$)
    LET b$ = 255 - (distance$ * 25)
    IF b$ < 20 THEN b$ = 20
    IF b$ > 255 THEN b$ = 255
    RETURN b$
END DEF

' Check if coordinates are within map bounds
DEF FN inBounds$(x$, y$, mapW$, mapH$)
    IF x$ < 0 THEN RETURN FALSE
    IF y$ < 0 THEN RETURN FALSE
    IF x$ >= mapW$ THEN RETURN FALSE
    IF y$ >= mapH$ THEN RETURN FALSE
    RETURN TRUE
END DEF
