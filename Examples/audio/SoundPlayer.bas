' ============================================
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Plays an MP3 song in the background, stops it early, plays and loops a short clip, then plays both at once.
' CATEGORY: audio
' TAGS: sound playback, loadsound, soundonce, soundrepeat, soundstop
' REQUIRES: assets/458044.mp3, assets/whoosh.mp3
' MINVERSION: 1.5
' ============================================
' Audio credits (royalty-free, Pixabay):
'   Song:  pixabay.com/users/audioknap-52540465/
'   Clip:  pixabay.com/users/viralaudio-44793737/

[inits]
    LET SONG_PATH# = "assets/458044.mp3"
    LET CLIP_PATH# = "assets/whoosh.mp3"

    LET song$ = LOADSOUND(SONG_PATH#)
    LET clip$ = LOADSOUND(CLIP_PATH#)

[main]
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
