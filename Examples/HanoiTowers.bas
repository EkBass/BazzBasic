' ============================================
' TOWERS OF HANOI - BazzBasic Edition
' Original: Creative Computing, Morristown NJ
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' Move all disks from tower 1 to tower 3.
' Never place a larger disk on a smaller one!
' ============================================

' Color constants
LET BLACK# = 0
LET BLUE# = 1
LET GREEN# = 2
LET CYAN# = 3
LET RED# = 4
LET MAGENTA# = 5
LET BROWN# = 6
LET LGRAY# = 7
LET DGRAY# = 8
LET LBLUE# = 9
LET LGREEN# = 10
LET LCYAN# = 11
LET LRED# = 12
LET LMAGENTA# = 13
LET YELLOW# = 14
LET WHITE# = 15

' Game state
DIM tower$
LET maxDisks# = 7
LET moves$ = 0
LET numDisks$ = 3
LET won$ = 0

GOSUB [title]

[newGame]
    GOSUB [setup]
    GOSUB [gameLoop]
    GOTO [newGame]
END

' ============================================
' TITLE SCREEN
' ============================================
[title]
    CLS
    COLOR YELLOW#, BLACK#
    PRINT "\n "; REPEAT("*", 44)
    PRINT " *"; REPEAT(" ", 42); "*"
    PRINT " *"; REPEAT(" ", 14);
    COLOR WHITE#, BLACK#
    PRINT "TOWERS OF HANOI";
    COLOR YELLOW#, BLACK#
    PRINT REPEAT(" ", 13); "*"
    PRINT " *"; REPEAT(" ", 42); "*"
    PRINT " "; REPEAT("*", 44)
    
    COLOR RED#, BLACK#
    PRINT "\n CREATIVE COMPUTING  MORRISTOWN, NEW JERSEY\n"
	COLOR LRED#, BLACK#
    PRINT " BazzBasic Edition: github.com/EkBass/BazzBasic"
	PRINT REPEAT("=", 48); "\n\n"
    
    ' ASCII art of towers
    COLOR CYAN#, BLACK#
    PRINT "           |             |             |"
    COLOR LRED#, BLACK#
    PRINT "          ===            |             |"
    COLOR YELLOW#, BLACK#
    PRINT "         =====           |             |"
    COLOR LGREEN#, BLACK#
    PRINT "        =======          |             |"
    COLOR LGRAY#, BLACK#
    PRINT "     =========================================\n"
    
    COLOR WHITE#, BLACK#
    PRINT " RULES:"
    PRINT " - Move all disks from the LEFT tower to the RIGHT"
    PRINT " - Move only ONE disk at a time"
    PRINT " - NEVER place a larger disk on a smaller one\n"
    
    COLOR YELLOW#, BLACK#
    PRINT " Minimum moves needed: 2^n - 1 (where n = number of disks)\n"
    
    COLOR WHITE#, BLACK#
    PRINT REPEAT("-", 50)
    PRINT " Press ENTER to start...";
    INPUT "", temp$
RETURN

' ============================================
' SETUP - Choose number of disks
' ============================================
[setup]
    CLS
    COLOR WHITE#, BLACK#
    PRINT "\n"; REPEAT("=", 50)
    PRINT " GAME SETUP"
    PRINT REPEAT("=", 50)
    
    [askDisks]
    COLOR CYAN#, BLACK#
    PRINT "\n How many disks (1-7)? ";
    INPUT "", numDisks$
    
    IF numDisks$ < 1 OR numDisks$ > 7 THEN
        COLOR LRED#, BLACK#
        PRINT " Please enter a number between 1 and 7!"
        GOTO [askDisks]
    END IF
    
    IF numDisks$ <> INT(numDisks$) THEN
        COLOR LRED#, BLACK#
        PRINT " Whole numbers only!"
        GOTO [askDisks]
    END IF
    
    ' Initialize towers - clear all
    FOR row$ = 1 TO maxDisks#
        FOR col$ = 1 TO 3
            tower$(row$, col$) = 0
        NEXT
    NEXT
    
    ' Place disks on tower 1
    ' Smallest (1) at top, largest (numDisks$) at bottom
    LET diskSize$ = 1
    FOR row$ = maxDisks# - numDisks$ + 1 TO maxDisks#
        tower$(row$, 1) = diskSize$
        diskSize$ = diskSize$ + 1
    NEXT
    
    moves$ = 0
    won$ = 0
    LET optimalMoves$ = POW(2, numDisks$) - 1
    
    COLOR LGREEN#, BLACK#
    PRINT "\n Starting with "; numDisks$; " disks."
    PRINT " Optimal solution: "; optimalMoves$; " moves."
    COLOR WHITE#, BLACK#
    PRINT "\n Press ENTER to begin...";
    INPUT "", temp$
RETURN

' ============================================
' MAIN GAME LOOP
' ============================================
[gameLoop]
    [turnLoop]
    CLS
    GOSUB [drawTowers]
    
    ' Check for win
    GOSUB [checkWin]
    IF won$ = 1 THEN RETURN
    
    ' Get move from player
    COLOR WHITE#, BLACK#
    PRINT " Moves: "; moves$
    PRINT REPEAT("-", 50)
    
    ' Select source tower
    [getSource]
    COLOR LGREEN#, BLACK#
    PRINT "\n Move from tower (1-3): ";
    INPUT "", fromTower$
    
    IF fromTower$ < 1 OR fromTower$ > 3 THEN
        COLOR LRED#, BLACK#
        PRINT " Invalid tower! Choose 1, 2, or 3."
        GOTO [getSource]
    END IF
    
    ' Check if tower has disks
    GOSUB [findTopDisk]
    LET srcRow$ = topRow$
    LET srcTower$ = fromTower$
    
    IF srcRow$ = 0 THEN
        COLOR LRED#, BLACK#
        PRINT " That tower is empty!"
        GOTO [getSource]
    END IF
    
    LET movingDisk$ = tower$(srcRow$, srcTower$)
    
    ' Select destination tower
    [getDest]
    COLOR LCYAN#, BLACK#
    PRINT " Move to tower (1-3): ";
    INPUT "", toTower$
    
    IF toTower$ < 1 OR toTower$ > 3 THEN
        COLOR LRED#, BLACK#
        PRINT " Invalid tower! Choose 1, 2, or 3."
        GOTO [getDest]
    END IF
    
    IF toTower$ = fromTower$ THEN
        COLOR LRED#, BLACK#
        PRINT " Same tower! Pick a different one."
        GOTO [getDest]
    END IF
    
    ' Check if move is valid (can't place larger on smaller)
    LET fromTower$ = toTower$
    GOSUB [findTopDisk]
    LET destRow$ = topRow$
    
    IF destRow$ > 0 THEN
        LET destDisk$ = tower$(destRow$, toTower$)
        IF movingDisk$ > destDisk$ THEN
            COLOR LRED#, BLACK#
            PRINT "\n *** ILLEGAL MOVE! ***"
            PRINT " Cannot place a LARGER disk on a SMALLER one!"
            SLEEP 1500
            GOTO [turnLoop]
        END IF
    END IF
    
    ' Execute move
    GOSUB [moveDisk]
    moves$ = moves$ + 1
    
    GOTO [turnLoop]

' ============================================
' FIND TOP DISK ON A TOWER
' ============================================
[findTopDisk]
    LET topRow$ = 0
    FOR row$ = 1 TO maxDisks#
        IF tower$(row$, fromTower$) > 0 THEN
            topRow$ = row$
            RETURN
        END IF
    NEXT
RETURN

' ============================================
' MOVE DISK
' ============================================
[moveDisk]
    ' Find destination row: just above the topmost disk, or bottom if empty
    LET destRow$ = maxDisks#
    
    ' Search from top to find first disk
    FOR row$ = 1 TO maxDisks#
        IF tower$(row$, toTower$) > 0 THEN
            ' Found a disk - place new disk above it
            destRow$ = row$ - 1
            GOTO [doMove]
        END IF
    NEXT
    
    ' Tower is empty - destRow$ stays at maxDisks# (bottom)
    
    [doMove]
    tower$(destRow$, toTower$) = tower$(srcRow$, srcTower$)
    tower$(srcRow$, srcTower$) = 0
RETURN

' ============================================
' CHECK FOR WIN
' ============================================
[checkWin]
    won$ = 0
    
    ' Check if all disks are on tower 3
    LET diskCount$ = 0
    FOR row$ = 1 TO maxDisks#
        IF tower$(row$, 3) > 0 THEN
            diskCount$ = diskCount$ + 1
        END IF
    NEXT
    
    IF diskCount$ = numDisks$ THEN
        won$ = 1
        
        LET optimalMoves$ = POW(2, numDisks$) - 1
        
        CLS
        GOSUB [drawTowers]
        
        COLOR YELLOW#, BLACK#
        PRINT "\n "; REPEAT("*", 40)
        
        IF moves$ = optimalMoves$ THEN
            COLOR LGREEN#, BLACK#
            PRINT " ***  PERFECT! OPTIMAL SOLUTION!  ***"
        ELSE
            COLOR LCYAN#, BLACK#
            PRINT " ***  CONGRATULATIONS! YOU WON!  ***"
        END IF
        
        COLOR YELLOW#, BLACK#
        PRINT " "; REPEAT("*", 40)
        
        COLOR WHITE#, BLACK#
        PRINT "\n You solved it in "; moves$; " moves."
        PRINT " Optimal solution: "; optimalMoves$; " moves."
        
        IF moves$ > optimalMoves$ THEN
            LET extra$ = moves$ - optimalMoves$
            COLOR LGRAY#, BLACK#
            PRINT " ("; extra$; " moves over optimal)"
        END IF
        
        COLOR WHITE#, BLACK#
        PRINT "\n Play again? (Y/N): ";
        INPUT "", again$
        
        IF UCASE(LEFT(again$, 1)) <> "Y" THEN
            PRINT "\n Thanks for playing!"
            END
        END IF
    END IF
RETURN

' ============================================
' DRAW TOWERS (ASCII Graphics)
' ============================================
[drawTowers]
    COLOR YELLOW#, BLACK#
    PRINT "\n"; REPEAT("=", 50)
    PRINT REPEAT(" ", 12); "T O W E R S   O F   H A N O I"
    PRINT REPEAT("=", 50); "\n"
    
    ' Draw each row from top to bottom
    FOR row$ = 1 TO maxDisks#
        ' Build the line for all three towers
        FOR col$ = 1 TO 3
            LET disk$ = tower$(row$, col$)
            
            IF disk$ = 0 THEN
                ' Empty slot - draw pole
                PRINT "       ";
                COLOR BROWN#, BLACK#
                PRINT "|";
                COLOR WHITE#, BLACK#
                PRINT "        ";
            ELSE
                ' Draw disk centered
                GOSUB [drawDiskAtCol]
            END IF
        NEXT
        PRINT ""
    NEXT
    
    ' Draw base
    COLOR LGRAY#, BLACK#
    PRINT " "; REPEAT("=", 47)
    
    ' Draw tower numbers
    COLOR WHITE#, BLACK#
    PRINT "       [1]            [2]            [3]"
    PRINT ""
RETURN

' ============================================
' DRAW DISK AT COLUMN (centered in 16-char width)
' ============================================
[drawDiskAtCol]
    ' Each tower column is 16 characters wide
    ' Disk width = disk$ * 2 + 1 (so disk 1 = 3 wide, disk 7 = 15 wide)
    LET diskWidth$ = disk$ * 2 + 1
    LET padding$ = 8 - disk$ - 1
    
    ' Left padding
    PRINT REPEAT(" ", padding$);
    
    ' Set color based on disk size
    IF disk$ = 1 THEN COLOR LRED#, BLACK#
    IF disk$ = 2 THEN COLOR YELLOW#, BLACK#
    IF disk$ = 3 THEN COLOR LGREEN#, BLACK#
    IF disk$ = 4 THEN COLOR LCYAN#, BLACK#
    IF disk$ = 5 THEN COLOR LBLUE#, BLACK#
    IF disk$ = 6 THEN COLOR LMAGENTA#, BLACK#
    IF disk$ = 7 THEN COLOR WHITE#, BLACK#
    
    ' Draw disk
    PRINT REPEAT("=", diskWidth$);
    
    ' Right padding
    COLOR WHITE#, BLACK#
    PRINT REPEAT(" ", padding$);
RETURN
