' Timeout argument parse test
DIM body$
body$("model")              = "qwen3.6"
body$("messages,0,role")    = "user"
body$("messages,0,content") = "Say hi in three words."
DIM result$
DIM h$
PRINT "Calling HTTPPOST with timeout arg..."
LET raw$   = HTTPPOST("http://localhost:11434/v1/chat/completions", ASJSON(body$), h$, 120)
LET count$ = ASARRAY(result$, raw$)
PRINT result$("choices,0,message,content")
PRINT "Done."
END
