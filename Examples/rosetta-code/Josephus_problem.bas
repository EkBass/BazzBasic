' ============================================
' https://rosettacode.org/wiki/Josephus_problem
' BazzBasic: https://github.com/EkBass/BazzBasic
' Prisoners are numbered 0 .. n-1, counting starts at prisoner 0.
' ============================================

' --------------------------------------------
' KilledAt$(n, k, pos)
' Returns the prisoner (0-based) who dies at position pos (1-based)
' of the killing sequence. pos = n gives the final survivor.
' Work is O(n - pos): the closer to the end, the cheaper.
' --------------------------------------------
DEF FN KilledAt$(n$, k$, pos$)
    LET size$ = n$ - pos$ + 1          ' circle size when this kill happens
    LET x$ = (k$ - 1) % size$          ' index of the victim in that circle
    WHILE size$ < n$                   ' grow the circle back to n prisoners
        size$ += 1
        x$ = (x$ + k$) % size$         ' undo one renumbering step
    WEND
    RETURN x$
END DEF

[inits]
    DIM alive$                         ' alive$(i) = TRUE / FALSE
    DIM kills$                         ' kills$(0 .. n-1) = killing sequence
    LET n$ = 0
    LET k$ = 0
    LET m$ = 0
    LET pos$ = 0
    LET count$ = 0
    LET seq$ = ""
    LET mismatch$ = 0
    LET victim$ = 0

[main]
    ' Example from the task: n = 5, k = 2 -> 1, 3, 0, 4 and #2 survives
    n$ = 5 : k$ = 2 : m$ = 1
    GOSUB [sub:report]

    ' Josephus himself: n = 41, k = 3, and 3 survivors for the "Extra" part
    n$ = 41 : k$ = 3 : m$ = 3
    GOSUB [sub:report]
END

' --------------------------------------------
' Play the executioner: walk the circle and fill kills$(). O(k*n)
' --------------------------------------------
[sub:simulate]
    FOR i$ = 0 TO n$ - 1
        alive$(i$) = TRUE
    NEXT

    pos$ = -1
    FOR killed$ = 0 TO n$ - 1
        count$ = 0
        WHILE count$ < k$
            pos$ = (pos$ + 1) % n$
            IF alive$(pos$) THEN count$ += 1
        WEND
        alive$(pos$) = FALSE
        kills$(killed$) = pos$
    NEXT
RETURN

' --------------------------------------------
' Print sequence, survivors, and cross-check the formula against simulation
' --------------------------------------------
[sub:report]
    GOSUB [sub:simulate]

    seq$ = ""
    FOR i$ = 0 TO n$ - 2               ' last one in kills$ is the survivor
        IF i$ > 0 THEN seq$ += ", "
        seq$ += kills$(i$)
    NEXT
    PRINT FSTRING("n = {{-n$-}}, k = {{-k$-}}")
    PRINT "Killing sequence: "; seq$

    victim$ = FN KilledAt$(n$, k$, n$)
    PRINT "Survivor (formula): #"; victim$; "   (#"; victim$ + 1; " if counting from 1)"

    IF m$ > 1 THEN
        seq$ = ""
        FOR i$ = n$ - m$ + 1 TO n$
            IF i$ > n$ - m$ + 1 THEN seq$ += ", "
            seq$ += FN KilledAt$(n$, k$, i$)
        NEXT
        PRINT FSTRING("Last {{-m$-}} survivors: ") + seq$
    END IF

    mismatch$ = 0
    FOR i$ = 1 TO n$
        IF FN KilledAt$(n$, k$, i$) <> kills$(i$ - 1) THEN mismatch$ += 1
    NEXT
    PRINT "Formula vs. simulation mismatches: "; mismatch$
    PRINT
RETURN

' Output:
' n = 5, k = 2
' Killing sequence: 1, 3, 0, 4
' Survivor (formula): #2   (#3 if counting from 1)
' Formula vs. simulation mismatches: 0
'
' n = 41, k = 3
' Killing sequence: 2, 5, 8, 11, 14, 17, 20, 23, 26, 29, 32, 35, 38, 0, 4, 9, 13, 18, 22, 27, 31, 36, 40, 6, 12, 19, 25, 33, 39, 7, 16, 28, 37, 10, 24, 1, 21, 3, 34, 15
' Survivor (formula): #30   (#31 if counting from 1)
' Last 3 survivors: 34, 15, 30
' Formula vs. simulation mismatches: 0