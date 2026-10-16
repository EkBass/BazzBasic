' ============================================
' Mistral AI API call — BazzBasic
' https://github.com/EkBass/BazzBasic
' Public domain
' ============================================
' Requires .env file in same directory as script:
'   MISTRAL_API_KEY=yourKeyHere
' ============================================

' DISCLAIMER:
' This code was written around 04.2026 with help from the provider's own AI,
' starting from a tested Claude example, and targets the model mistral-small-latest.
' It has not been tested by the BazzBasic author.
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
    LET ApiKey# = env$("MISTRAL_API_KEY")

    DIM headers$
    headers$("Authorization") = "Bearer " + ApiKey#
    headers$("Content-Type")  = "application/json"

    DIM body$
    body$("model")              = "mistral-small-latest"  ' or "mistral-medium-latest", "mistral-large-latest"
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