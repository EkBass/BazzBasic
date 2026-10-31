' ============================================
' ROSETTA: https://rosettacode.org/wiki/Substring/Top_and_tail
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Removes the first character, the last character, and both the first and last characters from the string BazzBasic and prints the results.
' CATEGORY: strings
' TAGS: substring, top and tail, left, right, mid
' MINVERSION: 1.5
' ============================================
[inits]
    LET s$ = "BazzBasic"

[main]
    PRINT "Original:                 "; s$
    PRINT "First character removed:  "; RIGHT(s$, LEN(s$) - 1)
    PRINT "Last character removed:   "; LEFT(s$, LEN(s$) - 1)
    PRINT "First and last removed:   "; MID(s$, 2, LEN(s$) - 2)
END

' Output:
' Original:                 BazzBasic
' First character removed:  azzBasic
' Last character removed:   BazzBasi
' First and last removed:   azzBasi