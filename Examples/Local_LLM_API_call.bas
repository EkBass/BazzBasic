' ============================================
' Local LLM API call (Ollama) — BazzBasic
' https://github.com/EkBass/BazzBasic
' Public domain
' ============================================
' No .env / API key needed — the server is local.
' Requires: Ollama running with a model pulled, e.g.
'   ollama pull llama3.2
' ============================================

[inits]
    DIM headers$
    headers$("Content-Type") = "application/json"

    DIM body$
    body$("model")              = "bazzbasic:latest"   ' a model you have actually pulled
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