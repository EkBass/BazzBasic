' ============================================
' GETCONSOLE example — BazzBasic
' Read character and color data from console
' https://github.com/EkBass/BazzBasic
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
