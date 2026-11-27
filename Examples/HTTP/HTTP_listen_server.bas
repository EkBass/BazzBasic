' ============================================
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: A small local JSON command server built on STARTLISTEN/GETREQUEST/SENDRESPONSE. Answers "add", "echo" and "time" commands and stops on "quit".
' CATEGORY: network
' TAGS: startlisten, getrequest, sendresponse, stoplisten, http, server, json, asarray, asjson
' MINVERSION: 1.7
' ============================================
' Public domain
'
' Try it from PowerShell while the program runs:
'   Invoke-RestMethod http://127.0.0.1:8080 -Method Post -Body '{"cmd":"add","a":2,"b":3}'
'   Invoke-RestMethod http://127.0.0.1:8080 -Method Post -Body '{"cmd":"echo","text":"Hello"}'
'   Invoke-RestMethod http://127.0.0.1:8080 -Method Post -Body '{"cmd":"quit"}'
' or from a browser page:
'   fetch("http://127.0.0.1:8080", {method: "POST", body: JSON.stringify({cmd: "time"})})
'       .then(r => r.json()).then(console.log)

[inits]
    LET PORT#    = 8080
    LET TIMEOUT# = 1000          ' GETREQUEST returns "" after 1 s with no request

    DIM req$
    DIM reply$
    LET body$    = ""
    LET cmd$     = ""
    LET n$       = 0
    LET served$  = 0
    LET running$ = 1

[main]
    STARTLISTEN PORT#, TIMEOUT#
    PRINT "Listening on http://127.0.0.1:" + PORT# + "  (POST {""cmd"":""quit""} to stop)"

    WHILE running$
        body$ = GETREQUEST()
        IF body$ <> "" THEN
            served$ += 1
            ' ASARRAY adds to an array, so start both arrays clean for every request
            DELARRAY req$ : DIM req$
            DELARRAY reply$ : DIM reply$
            cmd$ = ""

            ' ASARRAY stops the program on text that is not JSON, so check first
            IF LEFT(TRIM(body$), 1) = "{" THEN
                n$ = ASARRAY(req$, body$)
                IF HASKEY(req$("cmd")) THEN cmd$ = req$("cmd")
            END IF

            IF cmd$ = "add" AND HASKEY(req$("a")) AND HASKEY(req$("b")) THEN
                reply$("result") = VAL(req$("a")) + VAL(req$("b"))
            ELSEIF cmd$ = "echo" AND HASKEY(req$("text")) THEN
                reply$("result") = req$("text")
            ELSEIF cmd$ = "time" THEN
                reply$("result") = TIME("HH:mm:ss")
            ELSEIF cmd$ = "quit" THEN
                reply$("result") = "bye"
                running$ = 0
            ELSE
                reply$("error") = "Unknown request. Send JSON like {""cmd"":""add"",""a"":2,""b"":3}"
            END IF

            reply$("served") = served$
            SENDRESPONSE ASJSON(reply$)          ' always answer, or the client hangs
            PRINT served$; ": "; body$
        END IF
    WEND

    STOPLISTEN
    PRINT "Server stopped after "; served$; " request(s)."
END

' Output (server console, with the three PowerShell calls above):
' Listening on http://127.0.0.1:8080  (POST {"cmd":"quit"} to stop)
' 1: {"cmd":"add","a":2,"b":3}
' 2: {"cmd":"echo","text":"Hello"}
' 3: {"cmd":"quit"}
' Server stopped after 3 request(s).
