' ============================================
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Sends a "Hello" message to the xAI Grok chat completions API and prints the text of the reply.
' CATEGORY: api
' TAGS: xai, grok, llm, httppost, json
' REQUIRES: .env
' MINVERSION: 1.5
' ============================================
' EkBass, Public domain
' Requires .env file in same directory as script:
'   XAI_API_KEY=xai-yourKeyHere

' DISCLAIMER:
' This code was written around 04.2026 with help from the provider's own AI,
' starting from a tested Claude example, and targets the model grok-4.5.
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
    LET ApiKey# = env$("XAI_API_KEY")

    DIM headers$
    headers$("Authorization") = "Bearer " + ApiKey#
    headers$("Content-Type")  = "application/json"

    DIM body$
	body$("model")                = "grok-4.5"          ' Flagship model as of 2026
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