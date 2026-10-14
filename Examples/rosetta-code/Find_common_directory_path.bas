' ============================================
' https://rosettacode.org/wiki/Find_common_directory_path
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' BazzBasic has no built-in routine for this task.
'
' Method: append the separator to every path, find the longest
' common character prefix, then cut it back to the last separator.
' The appended separator handles the case where one path is a
' parent of another ("/a/b" vs "/a/b/c" -> "/a/b").

' Paths arrive as a JSON string, since arrays can't be passed to DEF FN
DEF FN CommonPath$(json$, sep$)
    DIM paths$
    LET count$  = ASARRAY(paths$, json$)
    LET prefix$ = paths$(0) + sep$
    LET cand$   = ""
    LET n$      = 0
    LET k$      = 0
    LET rev$    = 0
    LET cut$    = 0

    FOR i$ = 1 TO count$ - 1
        cand$ = paths$(i$) + sep$
        n$ = MIN(LEN(prefix$), LEN(cand$))
        k$ = 0
        WHILE k$ < n$ AND MID(prefix$, k$ + 1, 1) = MID(cand$, k$ + 1, 1)
            k$ += 1
        WEND
        prefix$ = LEFT(prefix$, k$)
    NEXT

    ' Position of the last separator, found via the reversed string
    rev$ = INSTR(INVERT(prefix$), sep$)
    IF rev$ = 0 THEN RETURN ""          ' nothing in common
    cut$ = LEN(prefix$) - rev$ + 1
    IF cut$ = 1 THEN RETURN sep$        ' only the root is shared
    RETURN LEFT(prefix$, cut$ - 1)      ' drop the trailing separator
END DEF

[inits]
    DIM paths$
    paths$(0) = "/home/user1/tmp/coverage/test"
    paths$(1) = "/home/user1/tmp/covert/operator"
    paths$(2) = "/home/user1/tmp/coven/members"

    LET result$ = ""

[main]
    result$ = FN CommonPath$(ASJSON(paths$), "/")
    PRINT "Common path is '"; result$; "'"
END

' Output:
' Common path is '/home/user1/tmp'