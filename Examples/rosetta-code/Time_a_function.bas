' ============================================
' ROSETTA: https://rosettacode.org/wiki/Time_a_function
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Times a user-defined function by calling it 1000 times and measuring the elapsed milliseconds with TICKS, printing the total and the time per call.
' CATEGORY: system
' TAGS: timing, ticks, benchmark, def fn
' MINVERSION: 1.5
' ============================================

' Calculates the sum of characters (ASCII codes)
DEF FN SumCharCodes$(text$)
    LET count$ = 1

    FOR i$ = 1 TO LEN(text$)
        count$ = count$ + ASC(MID(text$, i$, 1))
    NEXT

    RETURN count$
END DEF

[init]
    LET ticksNow$
    LET ticksAfter$

    LET url$ = "BazzBasic: https://github.com/EkBass/BazzBasic"
    LET sum$

[main]
    ticksNow$ = TICKS
    FOR i$ = 1 TO 1000
        sum$ = FN SumCharCodes$(url$)
    NEXT
    ticksAfter$ = TICKS

[output]
    PRINT "Sum: "; sum$
    PRINT "1000 runs: "; (ticksAfter$ - ticksNow$); " ms"
    PRINT "Per call: "; (ticksAfter$ - ticksNow$) / 1000; " ms"
END

' Output:
' Sum: 4255
' 1000 runs: 57 ms
' Per call: 0.057 ms