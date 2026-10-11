' ============================================
' https://rosettacode.org/wiki/Determine_sentence_type
' BazzBasic: https://github.com/EkBass/BazzBasic
' Classify sentences by their final punctuation:
' E = Exclamation!, Q = Question?, S = Serious., N = Neutral
' ============================================

' Type letter is picked by position: ? -> Q, ! -> E, . -> S
DEF FN SentenceType$(sentence$)
    IF LEN(sentence$) = 0 THEN RETURN "N"
    LET p$ = INSTR("?!.", RIGHT(sentence$, 1))
    IF p$ = 0 THEN RETURN "N"
    RETURN MID("QES", p$, 1)
END DEF

[inits]
    LET paragraph$ = "hi there, how are you today? I'd like to present to you the washing machine 9001. You have been nominated to win one of these! Just make sure you don't break it"
    LET current$  = ""
    LET c$        = ""
    LET sentence$ = ""

[main]
    ' Walk the paragraph; every ? ! or . closes a sentence
    FOR i$ = 1 TO LEN(paragraph$)
        c$ = MID(paragraph$, i$, 1)
        current$ += c$
        IF INSTR("?!.", c$) > 0 THEN
            sentence$ = TRIM(current$)
            PRINT sentence$; " -> "; FN SentenceType$(sentence$)
            current$ = ""
        END IF
    NEXT

    ' Whatever is left has no closing punctuation
    sentence$ = TRIM(current$)
    IF LEN(sentence$) > 0 THEN
        PRINT sentence$; " -> "; FN SentenceType$(sentence$)
    END IF
END

' Output:
' hi there, how are you today? -> Q
' I'd like to present to you the washing machine 9001. -> S
' You have been nominated to win one of these! -> E
' Just make sure you don't break it -> N
