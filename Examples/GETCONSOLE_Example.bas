CLS
COLOR 11, 1
PRINT "abcdefghi"
PRINT "ABCDEFGHI"
COLOR 1, 9
PRINT "987654321"
COLOR 15, 0
' Lets use CHR to translate ASCII-code as character
PRINT "Row 2, col 5 char is: " + CHR(GETCONSOLE(2, 5, 0)) ' Output: E
PRINT "Row 1, col 2 foreground color is: "  + GETCONSOLE(1, 2, 1) ' Output: 11
PRINT "Row 1, col 3 background color is:" + GETCONSOLE(1,3,2) ' Output: 1