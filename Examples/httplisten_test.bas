REM ============================================
REM Test: HTTP LISTEN end-to-end
REM
REM Run this, then from another terminal:
REM   curl -X POST http://127.0.0.1:8765 -d "{""name"":""Krisu""}"
REM ============================================

PRINT "Starting HTTP listener on port 8765..."
STARTLISTEN 8765, 30000

PRINT "Waiting for request (30s timeout)..."
LET body$ = GETREQUEST()

IF LEN(body$) = 0 THEN
    PRINT "Timeout - no request received."
ELSE
    PRINT "Got body: " + body$
END IF

SENDRESPONSE "{""status"":""ok"",""echoed"":""" + body$ + """}"

PRINT "Closing listener..."
STOPLISTEN

PRINT "Done."
END
