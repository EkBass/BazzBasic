' ============================================
' ROSETTA: https://rosettacode.org/wiki/User_input/Graphical
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Opens a 640x480 graphics window titled User Input, asks for a string and for the integer 75000 with INPUT, prints both back and waits for ESC.
' CATEGORY: input
' TAGS: input statement, text input, graphics screen, waitkey
' MINVERSION: 1.5
' ============================================
[inits]
    LET text$
    LET number$
	LET foo$

[screen]
	SCREEN 0, 640, 480, "User Input"
[main]
    INPUT "Enter a string: ", text$

    ' Since task do not require checkig the integer, we go easy here.
    INPUT "Enter the integer 75000: ", number$
    PRINT "String : " + text$
    PRINT "Integer: " + STR(VAL(number$))

	PRINT "Press ESC to exit."
	foo$ = WAITKEY(KEY_ESC#)
END

' Output:
' Enter a string: Hello
' Enter the integer 75000: 75000
' String : Hello
' Integer: 75000
' Press ESC to exit.