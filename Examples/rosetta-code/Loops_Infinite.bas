' ============================================
' ROSETTA: https://rosettacode.org/wiki/Loops/Infinite
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Prints SPAM forever with an infinite WHILE TRUE loop; a GOTO-based version is shown in the comments.
' CATEGORY: basics
' TAGS: infinite loop, while true, goto
' MINVERSION: 1.5
' ============================================

' BazzBasic supports infinite loops in two natural ways.

' --- Method 1: WHILE TRUE ---

[main]
    WHILE TRUE
        PRINT "SPAM"
    WEND

' --- Method 2: GOTO ---
'
' [main]
'     PRINT "SPAM"
' GOTO [main]

' Output (infinite):
' SPAM
' SPAM
' SPAM
' ...
