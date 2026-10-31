' ============================================
' ROSETTA: https://rosettacode.org/wiki/HTTP, https://rosettacode.org/wiki/HTTPS
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Sends an HTTP GET request and a JSON POST request to httpbin.org over HTTPS and prints both responses.
' CATEGORY: network
' TAGS: httpget, httppost, http, https
' MINVERSION: 1.5
' ============================================

[init]
    LET getResponse$
    LET postResult$

[main]
    getResponse$ = HTTPGET("https://httpbin.org/get")
    PRINT "RESPONSE:\n"; getResponse$

    postResult$ = HTTPPOST("https://httpbin.org/post", "{""key"":""value""}")
    PRINT "\nRESULT:\n"; postResult$
END

' Output:
' RESPONSE:
' {
'   "args": {},
'   "headers": {
'     "Host": "httpbin.org",
'     "X-Amzn-Trace-Id": "Root=1-69c2f335-2aaefcfc57520fdb6cc47036"
'   },
'   "origin": "84.253.208.175",
'   "url": "https://httpbin.org/get"
' }


' RESULT:
' {
'   "args": {},
'   "data": "{\"key\":\"value\"}",
'   "files": {},
'   "form": {},
'   "headers": {
'     "Content-Length": "15",
'     "Content-Type": "application/json; charset=utf-8",
'     "Host": "httpbin.org",
'     "X-Amzn-Trace-Id": "Root=1-69c2f335-1d4a8dc2577714f32f064832"
'   },
'   "json": {
'     "key": "value"
'   },
'   "origin": "84.253.208.175",
'   "url": "https://httpbin.org/post"
' }
