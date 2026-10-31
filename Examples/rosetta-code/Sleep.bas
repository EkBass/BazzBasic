' ============================================
' ROSETTA: https://rosettacode.org/wiki/Sleep
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Asks the user for a number of seconds, prints a message, pauses for that long with SLEEP (which takes milliseconds) and then prints another message.
' CATEGORY: system
' TAGS: sleep, delay, input
' MINVERSION: 1.5
' ============================================

[main]
    ' INPUT can auto-declare variables used with
    INPUT "How many seconds do I sleep? ", a$
    PRINT "Starting to sleep..."

    ' BazzBasic SLEEP's in milliseconds
    ' So conversion to seconds =* 1000
    SLEEP a$ * 1000
    PRINT "Back..."
END