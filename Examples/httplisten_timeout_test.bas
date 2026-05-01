REM Test: GETREQUEST timeout returns empty string
PRINT "Listening on 8766 with 1500ms timeout..."
STARTLISTEN 8766, 1500
LET body$ = GETREQUEST()
IF LEN(body$) = 0 THEN
    PRINT "OK: timeout produced empty string"
ELSE
    PRINT "WRONG: got body: " + body$
END IF
STOPLISTEN
PRINT "Done."
END
