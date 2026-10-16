' ============================================
' Local LLM API call (Ollama) — BazzBasic
' https://github.com/EkBass/BazzBasic
' Public domain
' ============================================
' No .env / API key needed — the server is local.
' Requires: Ollama running with a model pulled, e.g.
'   ollama pull llama3.2
' ============================================

' DISCLAIMER:
' This code was last verified on 04.04.2026 using llama3.1.
' AI providers change their APIs, model names and headers over time,
' so this example may stop working without any change in BazzBasic.
'
' If it fails, check the provider's current API documentation first.
' Provider-specific settings are grouped at the top of this file.
' You can also give this file together with the BazzBasic AI Guide
' to an AI of your choice and ask it to update the code.
'
' https://huggingface.co/datasets/EkBass/BazzBasic_AI_Guide

[inits]
    DIM headers$
    headers$("Content-Type") = "application/json"

    DIM body$
    body$("model")              = "llama3.1"   ' a model you have actually pulled
    body$("messages,0,role")    = "user"
    body$("messages,0,content") = "Say hello in three words."
    body$("max_tokens")         = 100

    DIM result$
    LET jsonBody$ = ""
    LET raw$      = ""
    LET count$    = 0

[main]
    jsonBody$ = ASJSON(body$)
    raw$      = HTTPPOST("http://localhost:11434/v1/chat/completions", jsonBody$, headers$)
    count$    = ASARRAY(result$, raw$)
    PRINT result$("choices,0,message,content")
END

' Output (depends on the model, e.g.):
' Hello there, friend!

' ==========================================================
' See: https://bbcookbook.miraheze.org/wiki/LLM:Ollama_and_other_local_LLMs
' for Ollama, LM Studio, GPT4All, llama-server and Local AI details for this code
' ==========================================================