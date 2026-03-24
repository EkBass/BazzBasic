' ==========================================
' Sound Player — BazzBasic
' Demonstrates LOADSOUND, SOUNDONCE,
' SOUNDREPEAT, SOUNDONCEWAIT, SOUNDSTOP,
' and SOUNDSTOPALL.
'
' Audio credits (royalty-free, Pixabay):
'   Song:  pixabay.com/users/audioknap-52540465/
'   Clip:  pixabay.com/users/viralaudio-44793737/
'
' https://github.com/EkBass/BazzBasic
' ==========================================

[inits]
    LET SONG_PATH# = "Examples\\audio\\music-free-458044.mp3"
    LET CLIP_PATH# = "Examples\\audio\\descent-whoosh-long-cinematic-sound-effect-405921.mp3"

[main]
    LET song$ = LOADSOUND(SONG_PATH#)
    LET clip$ = LOADSOUND(CLIP_PATH#)

    ' --- Play song in background, then stop it early ---
    PRINT "Playing song in the background..."
    SOUNDONCE(song$)
    SLEEP 5000

    PRINT "Stopping song early.\n"
    SLEEP 2000
    SOUNDSTOP(song$)

    ' --- Play clip once and WAIT for it to finish ---
    PRINT "Playing clip once — waiting for it to finish..."
    SOUNDONCEWAIT(clip$)
    PRINT "Clip done.\n"

    ' --- Loop the clip for a while ---
    PRINT "Looping clip for 20 seconds..."
    SOUNDREPEAT(clip$)
    SLEEP 20000
    SOUNDSTOP(clip$)

    ' --- Play both at the same time ---
    PRINT "Playing both at the same time for 20 seconds..."
    SOUNDONCE(song$)
    SOUNDREPEAT(clip$)
    SLEEP 20000

    SOUNDSTOPALL
    PRINT "\nDone."
END
