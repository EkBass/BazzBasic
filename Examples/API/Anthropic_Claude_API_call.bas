' ============================================
' Anthropic Claude API call — BazzBasic
' https://github.com/EkBass/BazzBasic
' Public domain
' ============================================
' Requires .env file in same directory as script:
'   ANTHROPIC_API_KEY=sk-ant-yourKeyHere
' ============================================

' DISCLAIMER:
' This code was last verified on 04.04.2026 using claude-sonnet-4-20250514.
' AI providers change their APIs, model names and headers over time,
' so this example may stop working without any change in BazzBasic.
'
' If it fails, check the provider's current API documentation first.
' Provider-specific settings are grouped at the top of this file.
' You can also give this file together with the BazzBasic AI Guide
' to an AI of your choice and ask it to update the code.
'
' https://huggingface.co/datasets/EkBass/BazzBasic_AI_Guide


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
