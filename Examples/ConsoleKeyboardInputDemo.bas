' Move "@" around the screen with arrow keys
' BazzBasic version. krisu.virtanen@gmail.com
' https://github.com/EkBass/BazzBasic

CLS
PRINT "Press arrow keys to move @, ESC to exit"
PRINT ""

LET x$ = 10
LET y$ = 5

[loop]
    LET k$ = INKEY
    
    IF k$ = KEY_ESC# THEN END
    
    LOCATE y$, x$
    PRINT " "
    
    IF k$ = KEY_UP# THEN
        IF y$ > 1 THEN y$ = y$ - 1
    END IF
    IF k$ = KEY_DOWN# THEN
        IF y$ < 20 THEN y$ = y$ + 1
    END IF
    IF k$ = KEY_LEFT# THEN
        IF x$ > 1 THEN x$ = x$ - 1
    END IF
    IF k$ = KEY_RIGHT# THEN
        IF x$ < 70 THEN x$ = x$ + 1
    END IF
	
	LOCATE y$, x$
    PRINT "@"
    SLEEP 10
    GOTO [loop]
