' ============================================
' ROSETTA: https://rosettacode.org/wiki/Rainbow
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Draws the word RAINBOW in a graphics window with every letter in a different rainbow colour, using RGB colours and DRAWSTRING.
' CATEGORY: drawing
' TAGS: rainbow, rgb, drawstring, colors
' MINVERSION: 1.5
' ============================================
'
' Console COLOR is limited to the 16-color palette (no orange, indigo
' or violet), so the word is drawn on the graphics screen with true
' RGB colors via DRAWSTRING.

[inits]
    LET SCREEN_W# = 200
    LET SCREEN_H# = 60
    LET TEXT_X# = 50
    LET TEXT_Y# = 22
    LET STEP_X# = 14
    LET WORD# = "RAINBOW"

    DIM colors$
    colors$(0, 0) = 255 : colors$(0, 1) =   0 : colors$(0, 2) =   0   ' red
    colors$(1, 0) = 255 : colors$(1, 1) = 128 : colors$(1, 2) =   0   ' orange
    colors$(2, 0) = 255 : colors$(2, 1) = 255 : colors$(2, 2) =   0   ' yellow
    colors$(3, 0) =   0 : colors$(3, 1) = 255 : colors$(3, 2) =   0   ' green
    colors$(4, 0) =   0 : colors$(4, 1) =   0 : colors$(4, 2) = 255   ' blue
    colors$(5, 0) =  75 : colors$(5, 1) =   0 : colors$(5, 2) = 130   ' indigo
    colors$(6, 0) = 128 : colors$(6, 1) =   0 : colors$(6, 2) = 255   ' violet

    LET col$ = 0
    LET wkv$ = 0

    SCREEN 0, SCREEN_W#, SCREEN_H#, "Rainbow"

[main]
    SCREENLOCK ON
    LINE (0, 0)-(SCREEN_W#, SCREEN_H#), 0, BF
    FOR i$ = 0 TO LEN(WORD#) - 1
        col$ = RGB(colors$(i$, 0), colors$(i$, 1), colors$(i$, 2))
        DRAWSTRING MID(WORD#, i$ + 1, 1), TEXT_X# + i$ * STEP_X#, TEXT_Y#, col$
    NEXT
    SCREENLOCK OFF

    wkv$ = WAITKEY()
END

' Output:
' A 200x60 window titled "Rainbow" showing the word RAINBOW on black,
' letters in red, orange, yellow, green, blue, indigo and violet.
