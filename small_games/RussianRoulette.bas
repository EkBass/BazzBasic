' Russian Roulette 
' CREATIVE COMPUTING
' MORRISTOWN, NEW JERSEY
'
' BazzBasic version by https://github.com/EkBass/BazzBasic

[start]
	color 11, 0
	cls
	
	print " "; repeat("*",21)
	print " *"; repeat(" ", 19); "*"
	print " *  RUSSIAN ROULETTE *"
	print " *"; repeat(" ", 19); "*"
	print " "; repeat("*",21)
	print"\n CREATIVE COMPUTING\n MORRISTOWN, NEW JERSEY"
	
	color 15, 0
	
[menu]
	let chamber$ = rnd(6)
	print " HERE IS A REVOLVER."
	print " Choose '1' to spin the chamber and pull the trigger."
	print " Choose '2', to be a loser who gives up."
	input "\n Your choice?", a$

	if a$ = 2 then
		print " Oh, such a loser!"
		goto [end]
	elseif a$ = 1 then
		print " Thats my boy!"
		goto [shoot]
	endif

	print "1 or 2 you chicken.\n\n"
	goto [menu]

[shoot]
	let shot$ = rnd(6)

	if shot$ = chamber$ then
		color 4, 0
		print "\n *** BANG!!! ***"
		color 15, 0
		print " You're dead!"
		print " Condolences will be sent to your relatives."
		print "\n \"Next victim please...\""
		sleep 3000
		goto  [start]
	endif
		
	print " *** YOU WIN!!!!!"
	print " Maybe let someone else blow their brains out?"
	sleep 3000
	goto  [start]

[end]
print "\n Bye..."