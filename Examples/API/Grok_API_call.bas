' ============================================
' xAI Grok API call — BazzBasic
' https://github.com/EkBass/BazzBasic
' EkBass, Public domain
' ============================================
' Requires .env file in same directory as script:
'   XAI_API_KEY=xai-yourKeyHere
' ============================================

[check:env]
    IF FileExists(".env") = 0 THEN
        PRINT "Error: .env file not found."
        END
    END IF

[inits]
    DIM env$
    env$ = FileRead(".env")
    LET ApiKey# = env$("XAI_API_KEY")

    DIM headers$
    headers$("Authorization") = "Bearer " + ApiKey#
    headers$("Content-Type")  = "application/json"

    DIM body$
	body$("model")                = "grok-4.3"          ' Current flagship model
	body$("max_completion_tokens") = 1000
    body$("messages,0,role")    = "user"
    body$("messages,0,content") = "Hello"

    LET jsonBody$
    LET raw$
    LET count$
    DIM result$

[main]
    jsonBody$ = ASJSON(body$)
    raw$      = HTTPPOST("https://api.x.ai/v1/chat/completions", jsonBody$, headers$)
    count$    = ASARRAY(result$, raw$)
    PRINT result$("choices,0,message,content")
END

' Output example:
' Hello! I'm Grok, built by xAI. How can I help you today?