' ============================================
' Google Gemini API call — BazzBasic
' https://github.com/EkBass/BazzBasic
' Public domain
' ============================================
' Requires .env file in same directory as script:
'  GEMINI_API_KEY=your_api_key_here
' ============================================

[check:env]
    IF FILEEXISTS(".env") = 0 THEN
        PRINT "Error: .env file not found."
        END
    END IF

[inits]
    DIM env$
    env$ = FILEREAD(".env")
    LET API_KEY# = env$("GEMINI_API_KEY")

    ' Gemini uses a query parameter for the API key
    LET URL# = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=" + API_KEY#

    DIM headers$
    headers$("Content-Type") = "application/json"

    DIM body$
    ' Gemini's nested JSON structure: contents -> parts -> text
    body$("contents,0,parts,0,text") = "Explain the BazzBasic programming language in one sentence."

    DIM result$
    LET jsonBody$ = ""
    LET raw$      = ""
    LET count$    = 0

[main]
    jsonBody$ = ASJSON(body$)
    raw$      = HTTPPOST(URL#, jsonBody$, headers$)
    
    ' Parse the response JSON into an array
    count$ = ASARRAY(result$, raw$)

    ' Gemini's response structure: candidates -> content -> parts -> text
    IF HASKEY(result$("candidates,0,content,parts,0,text")) THEN
        PRINT result$("candidates,0,content,parts,0,text")
    ELSE
        PRINT "Error: No response or invalid key. Raw output:"
        PRINT raw$
    END IF
END