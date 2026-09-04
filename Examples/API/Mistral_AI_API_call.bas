' ============================================
' Mistral AI API call — BazzBasic
' https://github.com/EkBass/BazzBasic
' Public domain
' ============================================
' Requires .env file in same directory as script:
'   MISTRAL_API_KEY=yourKeyHere
' ============================================

[check:env]
    IF FileExists(".env") = 0 THEN
        PRINT "Error: .env file not found."
        END
    END IF

[inits]
    DIM env$
    env$ = FileRead(".env")
    LET ApiKey# = env$("MISTRAL_API_KEY")

    DIM headers$
    headers$("Authorization") = "Bearer " + ApiKey#
    headers$("Content-Type")  = "application/json"

    DIM body$
    body$("model")              = "mistral-tiny"  ' or "mistral-small", "mistral-medium", etc.
    body$("messages,0,role")    = "user"
    body$("messages,0,content") = "Hello"
    body$("max_tokens")         = 100

    LET jsonBody$
    LET raw$
    LET count$
    DIM result$

[main]
    jsonBody$ = ASJSON(body$)
    raw$      = HTTPPOST("https://api.mistral.ai/v1/chat/completions", jsonBody$, headers$)
    count$    = ASARRAY(result$, raw$)
    PRINT result$("choices,0,message,content")
END

' Output (depends on the API response, e.g.):
' Hello! How can I assist you today?