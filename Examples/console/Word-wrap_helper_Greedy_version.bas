' ============================================
' Word-wrap helper — greedy, word-boundary aware
' BazzBasic 1.4c — https://github.com/EkBass/BazzBasic
' ============================================

DEF FN WrapText$(text$, width$, sep$)
    ' --- defaults (params are already declared, so no LET) ---
    IF sep$ = "" THEN
        sep$ = "\n"
    END IF
    IF width$ <= 0 THEN
        width$ = 40
    END IF

    text$ = TRIM(text$)
    IF text$ = "" THEN
        RETURN ""
    END IF

    ' Break into words once, then re-assemble line by line
    DIM words$
    LET wordCount$ = SPLIT(words$, text$, " ")   ' count MUST be captured

    LET result$ = ""
    LET line$   = ""
    LET word$   = ""                              ' declared before the loop

    FOR i$ = 0 TO wordCount$ - 1
        word$ = words$(i$)
        IF word$ <> "" THEN                       ' skip empties from double spaces
            IF line$ = "" THEN
                line$ = word$                     ' first word on a fresh line
            ELSEIF LEN(line$) + 1 + LEN(word$) <= width$ THEN
                line$ = line$ + " " + word$       ' word still fits
            ELSE
                IF result$ = "" THEN
                    result$ = line$               ' flush full line, no leading sep
                ELSE
                    result$ = result$ + sep$ + line$
                END IF
                line$ = word$                     ' next line begins with this word
            END IF
        END IF
    NEXT i$

    ' flush the final pending line
    IF line$ <> "" THEN
        IF result$ = "" THEN
            result$ = line$
        ELSE
            result$ = result$ + sep$ + line$
        END IF
    END IF

    RETURN result$
END DEF

[inits]
    LET demo$ = "This is over 40 characters long and should be wrapped in two lines at some point if code is correct."

[main]
    PRINT FN WrapText$(demo$, 40, "\n")
END