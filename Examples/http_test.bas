LET response$ = HTTPGET("https://httpbin.org/get")
PRINT response$

LET postResult$ = HTTPPOST("https://httpbin.org/post", "{""key"":""value""}")
PRINT postResult$