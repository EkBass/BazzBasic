' MazeWithLabels.bas
' Simple maze game for BazzBasic
' Kristian Virtanen, public domain

GOSUB [initConst]
GOSUB [initMaze]
GOSUB [initPlr]
GOSUB [menuText]


[start-play]
	GOSUB [print-game]
	LET move$
	
	[game-loop]
	WHILE Player$("win") = FALSE
		move$ = INKEY
		
		IF move$ <> FALSE THEN
			GOSUB [check-move]
			IF Player$("moved") = TRUE THEN
				GOSUB [did-win]
				GOSUB [print-game]
				Player$("moved") = FALSE
			ENDIF
			
		ENDIF
		
		SLEEP 1000/40
	WEND	
	
	' victory
	CLS
	PRINT "You solved the maze."
	PRINT "Now go outside for some fresh air."
	
	' return default colors for console
	COLOR WHITE#, BLACK#
END

' If player uses arrow key, we end up here
[check-move]
	' left
	IF move$ = KEY_LEFT# AND GETCONSOLE(Player$("cur_y"), Player$("cur_x") - 1, 0) = PATH# THEN
		Player$("cur_x") = Player$("cur_x") - 1
		Player$("moved") = TRUE
	ENDIF
	' right
	IF move$ = KEY_RIGHT# AND GETCONSOLE(Player$("cur_y"), Player$("cur_x") + 1, 0) = PATH# THEN
		Player$("cur_x") = Player$("cur_x") + 1
		Player$("moved") = TRUE
	ENDIF
	' up
	IF move$ = KEY_UP# AND GETCONSOLE(Player$("cur_y") - 1, Player$("cur_x"), 0) = PATH# THEN
		Player$("cur_y") = Player$("cur_y") - 1
		Player$("moved") = TRUE
	ENDIF
	' down
	IF move$ = KEY_DOWN# AND GETCONSOLE(Player$("cur_y") + 1, Player$("cur_x"), 0) = PATH# THEN
		Player$("cur_y") = Player$("cur_y") + 1
		Player$("moved") = TRUE
	ENDIF
RETURN
	

' some basic stuff	
[initConst]
	' With INCLUDE would be better to share this on its own file.
	' But this is example code, I keep all here
	LET BLACK#		= 0
	LET BLUE# 		= 1
	LET GREEN# 		= 2
	LET CYAN# 		= 3
	LET RED# 		= 4
	LET MAGENTA# 	= 5
	LET BROWN# 		= 6
	LET LGRAY# 		= 7
	LET DGRAY# 		= 8
	LET LBLUE# 		= 9
	LET LGREEN# 	= 10
	LET LCYAN# 		= 11
	LET LRED# 		= 12
	LET LMAGENTA#	= 13
	LET YELLOW# 	= 14
	LET WHITE# 		= 15
	LET PATH# 		= 32	' ASCII code for whitespace
RETURN 


[initMaze]
	' With INCLUDE would be better to share this on its own file.
	' But this is example code, I keep all here
	LET MazeCo# = BLUE# ' Maze is printed on blue 
	LET MAZE# =     "###############################\n#  #     #  #  #        #  #  #\n#  ####  #  #  #  #  ####  #  #\n#  #              #  #        #\n#  ####  ###################  #\n#  #           #              #\n#  #  ####  ####  ##########  #\n#     #     #     #           #\n##########  #  ##########  #  #\n#  #        #  #           #  #\n#  ####  #  #  #  #  ##########\n#        #     #  #  #     #  #\n#  #############  #######  #  #\n#              #  #     #     #\n##########  #  ####  #  ####  #\n#        #  #  #     #  #     #\n####  #  #  #######  #######  #\n#     #  #  #     #  #  #     #\n#  ####  #  #  ####  #  ####  #\n#     #                        \n###############################"
RETURN 


' Data for player character
[initPlr]
	DIM Player$
	Player$("cur_x") 	= 2		' start/cur x
	Player$("cur_y") 	= 2		' start/cur y

	Player$("char") 	= "@" 	' character
	Player$("target_x") = 31	' target x
	Player$("target_y") = 20	' target y
	Player$("color") 	= RED#	' color with what player is printed
	Player$("moved")	= 0	' If player has not moved, no need to print anything
	Player$("win")		= 0
RETURN 


[did-win]
	IF Player$("cur_x") = Player$("target_x") THEN
		IF Player$("cur_y") = Player$("target_Y") THEN
			Player$("win") = TRUE
		ENDIF
	ENDIF
RETURN 


[print-game]
	CLS
	COLOR MazeCo#, BLACK#
	PRINT MAZE#
	LOCATE Player$("cur_y"), Player$("cur_x")
	COLOR Player$("color"), BLACK#
	PRINT Player$("char");
RETURN


[menuText]
	CLS
	
	' the banner
	COLOR YELLOW#, BLACK#
	PRINT "\n\n" + REPEAT("*", 27)
	PRINT "* Maze game for BazzBasic *"
	PRINT REPEAT("*", 27) + "\n\n"
	
	' info
	COLOR LGRAY#, BLACK#
	PRINT "Press <ENTER> and a maze is shown on console.\n"
	PRINT "You start from top-left and try to find a route\n"
	PRINT "to bottom right to exit the maze and to win.\n\n"
	PRINT "Move player with arrow keys. Up, down, left, right.\n"
	COLOR MazeCo#, BLACK# : PRINT "#";
	COLOR LGRAY#, BLACK#
	PRINT " is wall. Empty space is path you can walk."
	PRINT "Your character is: ";
	COLOR Player$("color")
	PRINT Player$("char")
	COLOR LGRAY#, BLACK#
	PRINT "\nGet ready to run."
	INPUT "Press enter...", temp$
RETURN
	