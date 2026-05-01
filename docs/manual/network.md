## Network

**Note:**
httpbin.org is a good test address — it returns JSON showing what you sent. HTTPPOST sends Content-Type: application/json by default.


### HTTPGET
Allows you to send HTTP GET requests to a specified URL and retrieve the response as a string.

```vb
LET response$ = HTTPGET("https://httpbin.org/get")
PRINT response$
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


## HTTP Server (LISTEN)

BazzBasic can act as a small local HTTP server to receive POST requests from a browser-side HTML page or other tooling. The intended use is **local-only** glue: a static HTML page on the user's machine talks to BazzBasic via `fetch()`.

The server is bound to `127.0.0.1` only — no admin rights are needed on Windows, and the listener is never exposed to the network.

### Commands

| Command | Description |
|---------|-------------|
| `STARTLISTEN port` | Open the given port. `GETREQUEST()` will block forever until a request arrives. |
| `STARTLISTEN port, timeout_ms` | Same, but `GETREQUEST()` returns an empty string if no request arrives within the timeout. |
| `GETREQUEST()` | Block until a request arrives, then return the **POST/PUT/PATCH body** or the **GET query string** (without the leading `?`). Returns `""` on timeout. |
| `SENDRESPONSE str$` | Send `200 OK` with the given body, `Content-Type: text/plain; charset=utf-8`, and CORS headers. Must be called after each `GETREQUEST()` so the browser does not hang. |
| `STOPLISTEN` | Close the port. Silent no-op if no listener is active. |

### Behaviour

- Only one listener can be active at a time. Calling `STARTLISTEN` while a listener is already open is an error — call `STOPLISTEN` first.
- `OPTIONS` preflight requests sent by browsers for CORS are answered automatically with `200 OK` + CORS headers and **never reach user code**. The script keeps waiting in `GETREQUEST()` for the real request.
- If you call `GETREQUEST()` again without first calling `SENDRESPONSE`, the previous request is automatically closed with an empty `200 OK` so the browser does not hang. This makes the API forgiving but you should still call `SENDRESPONSE` explicitly.
- All responses include `Access-Control-Allow-Origin: *`, so an HTML page loaded with `file://` or from a different port can post to your script without any extra setup.

### Example: receive a JSON form post

```vb
STARTLISTEN 8080
PRINT "Listening on http://127.0.0.1:8080 ..."

LET json$ = GETREQUEST()
PRINT "Received: " + json$

' Parse the JSON into an array
DIM data$
LET data$ = ASARRAY(json$)
PRINT "Name: " + data$("name")

SENDRESPONSE "{""status"":""ok""}"
STOPLISTEN
END
```

Matching browser-side JavaScript:

```javascript
fetch("http://127.0.0.1:8080", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ name: "Krisu", level: 99 })
})
.then(r => r.json())
.then(data => console.log(data));
```

### Example: poll loop with timeout

```vb
STARTLISTEN 8080, 2000

LET running$ = 1
WHILE running$
    LET req$ = GETREQUEST()
    IF LEN(req$) = 0 THEN
        PRINT "Idle..."
    ELSE
        PRINT "Got: " + req$
        SENDRESPONSE "ok"
        IF req$ = "quit" THEN
            LET running$ = 0
        END IF
    END IF
WEND

STOPLISTEN
END
```

### Notes & limitations

- Only one request is handled at a time, sequentially. This is intentional — BazzBasic is single-threaded and aims for simple local glue, not high-traffic web serving.
- The response is always `200 OK` with `text/plain` content type. If you need to return JSON, just put JSON text in the body — browsers can still parse it with `response.json()`. Custom status codes are not supported in this version.
- `GET` requests give you the query string (e.g. `name=Krisu&age=50`), not the URL path. Routing by path is not supported in this version.
- For outgoing HTTP calls (calling other servers), see `HTTPGET` and `HTTPPOST` above.
