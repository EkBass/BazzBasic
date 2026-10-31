' ============================================
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Prints colored text to the console and reads back a character plus its foreground and background colors with GETCONSOLE.
' CATEGORY: screen
' TAGS: getconsole, console colors, text mode
' MINVERSION: 1.5
' ============================================

[inits]
    LET LCYAN#  = 11
    LET BLUE#   = 1
    LET LBLUE#  = 9
    LET WHITE#  = 15
    LET BLACK#  = 0

[main]
    CLS

    ' Write some colored text to read back
    COLOR LCYAN#, BLUE#
    PRINT "abcdefghi"
    PRINT "ABCDEFGHI"
    COLOR BLUE#, LBLUE#
    PRINT "987654321"
    COLOR WHITE#, BLACK#

    ' Read back character, foreground and background
    PRINT "Row 2, col 5 char is: "; CHR(GETCONSOLE(2, 5, 0))  ' Output: E
    PRINT "Row 1, col 2 foreground: "; GETCONSOLE(1, 2, 1)     ' Output: 11
    PRINT "Row 1, col 3 background: "; GETCONSOLE(1, 3, 2)     ' Output: 1
END
