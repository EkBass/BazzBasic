' SoundPlayer.bas
' BazzBasic https://github.com/EkBass/BazzBasic

' Royalty free song https://pixabay.com/users/audioknap-52540465/
LET SONGPATH# = "Examples\\audio\\music-free-458044.mp3"
LET song$ = LOADSOUND(SONGPATH#)

SOUNDONCE(song$)
PRINT "Sound playing in background..."
SLEEP 5000
PRINT "Continuing while sound plays...\nBut lets stop it now."
SLEEP 2000
SOUNDSTOP(song$)

' Royalty free https://pixabay.com/users/viralaudio-44793737/?utm_source=link-attribution&utm_medium=referral&utm_campaign=music&utm_content=405921
LET CLIPPATH# = "Examples\\audio\\descent-whoosh-long-cinematic-sound-effect-405921.mp3"
LET clip$ = LOADSOUND(CLIPPATH#)

PRINT "Lets play with the clip and wait its done."
SOUNDONCEWAIT(clip$)

PRINT "Now lets repeat it for a while."
SOUNDREPEAT(clip$)
SLEEP 20000

PRINT "Pretty easy, huh?"
PRINT "Now both at same time."
SOUNDONCE(song$)
SOUNDREPEAT(clip$)
SLEEP 20000

SOUNDSTOPALL
PRINT "Bye"
END