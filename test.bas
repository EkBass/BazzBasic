' Royalty fre song https://pixabay.com/users/audioknap-52540465/
LET SONGPATH# = "audio/music-free-458044.mp3"
LET song$ = LOADSOUND(SONGPATH#)

SOUNDONCE(song$)
PRINT "Sound playing in background..."
SLEEP 5000
PRINT "Continuing while sound plays...\nBut lets stop it now."
SLEEP 2000
SOUNDSTOP(song$)

