' ============================================
' BazzBasic version 1.4c
' https://ekbass.github.io/BazzBasic/

' Big ASCII clock from a 5x5 sprite sheet
' ============================================

[inits]
    ' 5x5 glyphs for "0123456789:" stored row-major:
    ' each row is one scanline across ALL 11 glyphs (55 cols = 11 x 5).
    ' Glyph order matches ASCII 48..58, so no lookup table is needed.
    DIM digits$
    digits$(1) = "#####--#--###########---##########################--#--"
    digits$(2) = "#---#--#------#----##---##----#--------##---##---#--#--"
    digits$(3) = "#---#--#--#####--##################--#############-----"
    digits$(4) = "#---#--#--#--------#----#----##---#----##---#----#--#--"
    digits$(5) = "#####--#--##########----###########----###########--#--"

    ' Declared here, not inside loops, to avoid repeated existence checks.
    LET clock$ = ""
    LET line$  = ""
    LET ch$    = ""
    LET idx$   = 0
    LET col$   = 0
    LET glyph$ = ""

[main]
    ' Build the string ourselves: a literal ":" survives the Finnish
    ' locale, where TIME("HH:mm:ss") would render the separator as ".".
    WHILE INKEY <> KEY_ESC#
        clock$ = TIME("HH") + ":" + TIME("mm") + ":" + TIME("ss")
        GOSUB [sub:renderBig]
        SLEEP 1000
    WEND
END

[sub:renderBig]
    CLS
    FOR row$ = 1 TO 5
        line$ = ""
        FOR i$ = 1 TO LEN(clock$)
            ch$    = MID(clock$, i$, 1)
            idx$   = ASC(ch$) - 48          ' '0'..'9' -> 0..9, ':' -> 10
            col$   = idx$ * 5 + 1           ' MID is 1-based
            glyph$ = MID(digits$(row$), col$, 5)
            line$  = line$ + glyph$ + " "   ' one blank column between glyphs
        NEXT
        ' Off-pixels '-' become spaces so the digits stand out.
        line$ = REPLACE(line$, "-", " ")
        PRINT line$
    NEXT
    PRINT "ESC to quit"
RETURN

' Output
' ##### #####   #   ##### #####   #   #   # #####
'     #     #   #       #     #   #   #   # #
' ##### #####       #####   ###       ##### #####
' #     #       #   #         #   #       # #   #
' ##### #####   #   ##### #####   #       # #####
' ESC to quit