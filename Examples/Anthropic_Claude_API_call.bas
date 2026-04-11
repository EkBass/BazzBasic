' ============================================
' Anthropic Claude API call — BazzBasic
' https://github.com/EkBass/BazzBasic
' Public domain
' ============================================
' Requires .env file in same directory as script:
'   ANTHROPIC_API_KEY=sk-ant-yourKeyHere
' ============================================

[check:env]
    IF FileExists(".env") = 0 THEN
        PRINT "Error: .env file not found."
        END
    END IF

[inits]
    DIM env$
    env$ = FileRead(".env")
    LET ApiKey# = env$("ANTHROPIC_API_KEY")

    DIM headers$
    headers$("x-api-key")         = ApiKey#
    headers$("anthropic-version") = "2023-06-01"
    headers$("Content-Type")      = "application/json"

    DIM body$
    body$("model")              = "claude-sonnet-4-20250514"
    body$("max_tokens")         = 100
    body$("messages,0,role")    = "user"
    body$("messages,0,content") = "Hello"

    DIM result$
    LET jsonBody$ = ""
    LET raw$      = ""
    LET count$    = 0

[main]
    jsonBody$ = ASJSON(body$)
    raw$      = HTTPPOST("https://api.anthropic.com/v1/messages", jsonBody$, headers$)
    count$    = ASARRAY(result$, raw$)

    PRINT result$("content,0,text")
END
