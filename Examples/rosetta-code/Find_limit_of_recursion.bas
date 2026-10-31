' ============================================
' ROSETTA: https://rosettacode.org/wiki/Find_limit_of_recursion
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Calls a function recursively without end, printing the depth each time, until the interpreter stops with a recursion-too-deep error.
' CATEGORY: algorithms
' TAGS: recursion, recursion limit, stack overflow, def fn
' MINVERSION: 1.5
' ============================================

DEF FN limit$(c$)
    PRINT c$
    RETURN FN limit$(c$ + 1)
END DEF

PRINT FN limit$(0)
SLEEP 10000
' Output
' 0
' 1
' ...
' ...
' ...
' 141883
' 141884
' 141885
' Error at line 8: Recursion too deep in FN LIMIT$ - out of stack space