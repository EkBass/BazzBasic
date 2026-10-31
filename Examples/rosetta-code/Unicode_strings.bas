' ============================================
' ROSETTA: https://rosettacode.org/wiki/Unicode_strings
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Demonstrates BazzBasic's Unicode support: Unicode literals and identifiers, UCASE, LCASE, INVERT, MID and LEN on Greek, Russian and Japanese text, CHR and ASC code points and a UTF-8 file round trip.
' CATEGORY: strings
' TAGS: unicode, utf-8, string functions, chr, asc
' MINVERSION: 1.5
' ============================================
'
' How well prepared is BazzBasic for Unicode?
'
' Source code:   .bas files are read as UTF-8, so Unicode string literals
'                can be written directly in the source.
' Identifiers:   variable, constant and function names may contain any
'                Unicode letter (grüße$, π#, 名前$). Labels may contain
'                almost any printable character. Keywords are ASCII only.
' Strings:       BazzBasic runs on .NET, so strings are UTF-16 internally.
'                LEN, MID, LEFT, RIGHT and INVERT count UTF-16 code units:
'                every character of the Basic Multilingual Plane (Latin,
'                Greek, Cyrillic, CJK...) is one unit, but characters
'                outside it (most emoji) are surrogate pairs and count as 2.
'                Combining characters count separately as well.
' ASC / CHR:     work with code points of the BMP (0..65535).
' Case:          UCASE / LCASE use Unicode-aware, culture-invariant rules.
' Files:         FILEREAD / FILEWRITE / FILEAPPEND use UTF-8.
' Network:       HTTPGET / HTTPPOST send and receive UTF-8.
' Graphics:      DRAWSTRING renders UTF-8 text through SDL2_ttf; glyphs
'                appear if the loaded font contains them.
' Console:       output uses the console's active code page. Run in a
'                UTF-8 console (chcp 65001) to see every script correctly.
' Normalization: not supported (no NFC/NFD functions).

[inits]
    LET grüße$  = "Grüße"                   ' Unicode identifier and literal
    LET greek$  = "Ελλάδα"
    LET russia$ = "Привет"
    LET japan$  = "日本語"
    LET emoji$  = "😀"
    LET kana$   = CHR(12354)                ' U+3042 HIRAGANA LETTER A
    LET FILE#   = "unicode_test.txt"
    LET all$    = ""
    LET back$   = ""

[main]
    PRINT "Literals:      "; grüße$; ", "; greek$; ", "; russia$; ", "; japan$
    PRINT "UCASE:         "; UCASE(grüße$); ", "; UCASE(greek$); ", "; UCASE(russia$)
    PRINT "LCASE:         "; LCASE(greek$)
    PRINT "INVERT:        "; INVERT(japan$)
    PRINT "MID(greek$,2,3): "; MID(greek$, 2, 3)
    PRINT "LEN(japan$):   "; LEN(japan$)
    PRINT "LEN(emoji$):   "; LEN(emoji$); "  (surrogate pair)"
    PRINT "CHR(12354):    "; kana$
    PRINT "ASC(kana$):    "; ASC(kana$)

    ' Round trip through a UTF-8 file
    all$ = grüße$ + " " + greek$ + " " + russia$ + " " + japan$ + " " + emoji$
    FILEWRITE FILE#, all$
    back$ = FILEREAD(FILE#)
    FILEDELETE FILE#
    IF back$ = all$ THEN
        PRINT "File round trip: OK"
    ELSE
        PRINT "File round trip: FAILED"
    END IF
END

' Output (in a UTF-8 console, chcp 65001):
' Literals:      Grüße, Ελλάδα, Привет, 日本語
' UCASE:         GRÜßE, ΕΛΛΆΔΑ, ПРИВЕТ
' LCASE:         ελλάδα
' INVERT:        語本日
' MID(greek$,2,3): λλά
' LEN(japan$):   3
' LEN(emoji$):   2  (surrogate pair)
' CHR(12354):    あ
' ASC(kana$):    12354
' File round trip: OK
