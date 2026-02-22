## Network

**Note:**
httpbin.org is a good test address — it returns JSON showing what you sent. HTTPPOST sends Content-Type: application/json by default.


### HTTPGET
Allows you to send HTTP GET requests to a specified URL and retrieve the response as a string.

```vb
DIM response$
LET response$ = HTTPGET("https://httpbin.org/get")
PRINT response$
PRINT postResult$
```
**Output:**
```
{
  "args": {},
  "headers": {
    "Host": "httpbin.org",
    "X-Amzn-Trace-Id": "Root=1-6999cff3-34d8f03c0661810224fe62db"
  },
  "origin": "84.231.65.52",
  "url": "https://httpbin.org/get"
}
```


### HTTPPOST
Allows you to send HTTP POST requests to a specified URL and retrieve the response as a string.

```vb
DIM postResult$
LET postResult$ = HTTPPOST("https://httpbin.org/post", "{""key"":""value""}")
PRINT postResult$
```
**Output;**
```
{
  "args": {},
  "data": "{\"key\":\"value\"}",
  "files": {},
  "form": {},
  "headers": {
    "Content-Length": "15",
    "Content-Type": "application/json; charset=utf-8",
    "Host": "httpbin.org",
    "X-Amzn-Trace-Id": "Root=1-6999d03a-3b47996d66ac7d8e65200a1e"
  },
  "json": {
    "key": "value"
  },
  "origin": "84.231.65.52",
  "url": "https://httpbin.org/post"
}
```
