' BazzBasic version 1.3
' https://ekbass.github.io/BazzBasic/
' ============================================
' FigBazz - Big Block-Font Text Renderer
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
'
' Usage:  bazzbasic.exe figbazz.bas "Your Text"
'         (or run without args → interactive prompt)
'
' NOTE: Save this file as UTF-8. The string literals
'       contain Unicode block characters (█ ▀ ▄).
'       They must survive disk round-trip intact.
'
'
' Original: https://github.com/digger72/python-sysmsg/blob/master/sysmsg.py

[inits]
    DIM font$

    ' --- letters (a–z) ---
    font$("a0" ) = "▄▀▀▄ " : font$("a1" ) = "█▀▀█ " : font$("a2" ) = "▀  ▀ "
    font$("b0" ) = "█▀▀▄ " : font$("b1" ) = "█▀▀▄ " : font$("b2" ) = "▀▀▀  "
    font$("c0" ) = "▄▀▀▀ " : font$("c1" ) = "█    " : font$("c2" ) = " ▀▀▀ "
    font$("d0" ) = "█▀▀▄ " : font$("d1" ) = "█  █ " : font$("d2" ) = "▀▀▀  "
    font$("e0" ) = "█▀▀▀ " : font$("e1" ) = "█▀▀  " : font$("e2" ) = "▀▀▀▀ "
    font$("f0" ) = "█▀▀▀ " : font$("f1" ) = "█▀▀  " : font$("f2" ) = "▀    "
    font$("g0" ) = "▄▀▀▀ " : font$("g1" ) = "█ ▀█ " : font$("g2" ) = " ▀▀▀ "
    font$("h0" ) = "█  █ " : font$("h1" ) = "█▀▀█ " : font$("h2" ) = "▀  ▀ "
    font$("i0" ) = "▀█▀ "  : font$("i1" ) = " █  "  : font$("i2" ) = "▀▀▀ "
    font$("j0" ) = "   █ " : font$("j1" ) = "▄  █ " : font$("j2" ) = " ▀▀  "
    font$("k0" ) = "█ ▄▀ " : font$("k1" ) = "█▀▄  " : font$("k2" ) = "▀  ▀ "
    font$("l0" ) = "█    " : font$("l1" ) = "█    " : font$("l2" ) = "▀▀▀▀ "
    font$("m0" ) = "█▄ ▄█ ": font$("m1" ) = "█ ▀ █ ": font$("m2" ) = "▀   ▀ "
    font$("n0" ) = "█▄  █ ": font$("n1" ) = "█ ▀▄█ ": font$("n2" ) = "▀   ▀ "
    font$("o0" ) = "▄▀▀▄ " : font$("o1" ) = "█  █ " : font$("o2" ) = " ▀▀  "
    font$("p0" ) = "█▀▀▄ " : font$("p1" ) = "█▀▀  " : font$("p2" ) = "▀    "
    font$("q0" ) = "▄▀▀▄ " : font$("q1" ) = "█ ▄▀ " : font$("q2" ) = " ▀ ▀ "
    font$("r0" ) = "█▀▀▄ " : font$("r1" ) = "█▀▀▄ " : font$("r2" ) = "▀  ▀ "
    font$("s0" ) = "▄▀▀▀ " : font$("s1" ) = " ▀▀▄ " : font$("s2" ) = "▀▀▀  "
    font$("t0" ) = "▀█▀ "  : font$("t1" ) = " █  "  : font$("t2" ) = " ▀  "
    font$("u0" ) = "█  █ " : font$("u1" ) = "█  █ " : font$("u2" ) = " ▀▀  "
    font$("v0" ) = "█   █ ": font$("v1" ) = " █ █  ": font$("v2" ) = "  ▀   "
    font$("w0" ) = "█   █ ": font$("w1" ) = "█▄▀▄█ ": font$("w2" ) = "▀   ▀ "
    font$("x0" ) = "█  █ " : font$("x1" ) = "▄▀▀▄ " : font$("x2" ) = "▀  ▀ "
    font$("y0" ) = "█ █ "  : font$("y1" ) = " █  "  : font$("y2" ) = " ▀  "
    font$("z0" ) = "▀▀▀█ " : font$("z1" ) = "▄▀▀  " : font$("z2" ) = "▀▀▀▀ "

    ' --- digits (0–9) ---
    font$("00" ) = "▄▀▀▄ " : font$("01" ) = "█▄▀█ " : font$("02" ) = " ▀▀  "
    font$("10" ) = " ▄█  "  : font$("11" ) = "  █  "  : font$("12" ) = " ▀▀▀ "
    font$("20" ) = "▀▀▀▄ " : font$("21" ) = "▄▀▀  " : font$("22" ) = "▀▀▀▀ "
    font$("30" ) = "▀▀▀▄ " : font$("31" ) = " ▀▀▄ " : font$("32" ) = "▀▀▀  "
    font$("40" ) = "█ ▄  " : font$("41" ) = "▀▀█▀ " : font$("42" ) = "  ▀  "
    font$("50" ) = "█▀▀▀ " : font$("51" ) = "▀▀▀▄ " : font$("52" ) = "▀▀▀  "
    font$("60" ) = "▄▀▀  " : font$("61" ) = "█▀▀▄ " : font$("62" ) = " ▀▀  "
    font$("70" ) = "▀▀▀█ " : font$("71" ) = " ▄▀  " : font$("72" ) = " ▀   "
    font$("80" ) = "▄▀▀▄ " : font$("81" ) = "▄▀▀▄ " : font$("82" ) = " ▀▀  "
    font$("90" ) = "▄▀▀▄ " : font$("91" ) = " ▀▀█ " : font$("92" ) = " ▀▀  "

    ' --- punctuation & symbols ---
    font$(":0" ) = "  "    : font$(":1" ) = "▀ "    : font$(":2" ) = "▀ "
    font$(".0" ) = "  "    : font$(".1" ) = "  "    : font$(".2" ) = "▀ "
    font$(";0" ) = "   "   : font$(";1" ) = " ▀ "   : font$(";2" ) = "▄▀ "
    font$(",0" ) = "   "   : font$(",1" ) = "   "   : font$(",2" ) = "▄▀ "
    font$("-0" ) = "    "  : font$("-1" ) = "▀▀▀ "  : font$("-2" ) = "    "
    font$("_0" ) = "    "  : font$("_1" ) = "    "  : font$("_2" ) = "▀▀▀▀"
    font$(" 0" ) = "  "    : font$(" 1" ) = "  "    : font$(" 2" ) = "  "
    font$("/0" ) = "  █ "  : font$("/1" ) = " █  "  : font$("/2" ) = "█   "
    font$("\\",0) = "█   "  : font$("\\",1) = " █  "  : font$("\\",2) = "  █ "
    font$("(0" ) = " ▄▀ "  : font$("(1" ) = "█   "  : font$("(2" ) = " ▀▄ "
    font$(")0" ) = "▀▄  "  : font$(")1" ) = "  █ "  : font$(")2" ) = "▄▀  "
    font$("[0" ) = "█▀▀ "  : font$("[1" ) = "█   "  : font$("[2" ) = "█▄▄ "
    font$("]0" ) = "▀▀█ "  : font$("]1" ) = "  █ "  : font$("]2" ) = "▄▄█ "

    ' --- working variables (declared here to stay outside the hot loop) ---
    LET msg$ = ""
    LET line1$ = ""
    LET line2$ = ""
    LET line3$ = ""
    LET c$ = ""

[main]
    ' ---- get input ----
    IF ARGCOUNT > 0 THEN
        msg$ = ARGS(0)
    ELSE
        LINE INPUT "Enter text: ", msg$
    END IF

    ' Lowercase so font$(c$, row) always resolves;
    ' the font only has lowercase glyphs, matching the Python original.
    msg$ = LCASE(msg$)

    ' ---- build the three output rows ----
    FOR i$ = 1 TO LEN(msg$)
        c$ = MID(msg$, i$, 1)
        ' HASKEY guards against unknown characters —
        ' they are silently skipped, same as the Python version.
        IF HASKEY(font$(c$ + "0")) THEN
            line1$ += font$(c$ + "0")
            line2$ += font$(c$ + "1")
            line3$ += font$(c$ + "2")
        END IF
    NEXT

    ' ---- output ----
    PRINT ""
    PRINT line1$
    PRINT line2$
    PRINT line3$
    PRINT ""

END

' Output:
' Enter text: BazzBasic
' 
' █▀▀▄ ▄▀▀▄ ▀▀▀█ ▀▀▀█ █▀▀▄ ▄▀▀▄ ▄▀▀▀ ▀█▀ ▄▀▀▀
' █▀▀▄ █▀▀█ ▄▀▀  ▄▀▀  █▀▀▄ █▀▀█  ▀▀▄  █  █
' ▀▀▀  ▀  ▀ ▀▀▀▀ ▀▀▀▀ ▀▀▀  ▀  ▀ ▀▀▀  ▀▀▀  ▀▀▀