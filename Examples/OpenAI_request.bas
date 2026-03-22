' BazzBasic: https://ekbass.github.io/BazzBasic/
' OpenAI API call via BazzBasic
' krisu.virtanen@gmail.com
' public domain


' file: OpenAI_request.bas
IF FileExists(".env") = 0 THEN
    PRINT "Error: .env file not found"
    END
END IF

DIM env$
    LET env$ = FileRead(".env")
    LET ApiKey# = env$("OPENAI_API_KEY")

DIM headers$
    headers$("Authorization") = "Bearer " + ApiKey#
    headers$("Content-Type") = "application/json"

DIM body$
    body$("model") = "gpt-4.1-mini"
    body$("messages,0,role") = "user"
    body$("messages,0,content") = "Hello"
    body$("max_tokens") = 100

LET jsonBody$ = ASJSON(body$)
LET raw$ = HTTPPOST("https://api.openai.com/v1/chat/completions", jsonBody$, headers$)

DIM result$
LET count$ = ASARRAY(result$, raw$)

PRINT result$("choices,0,message,content")
' end file


' file: .env
' set your OpenAI API key to .env file at same location where "OpenAI_request.bas" locates
' OPENAI_API_KEY=sk-proj-y7N_7-V....... add your key and remove comment char from start of line
' end file