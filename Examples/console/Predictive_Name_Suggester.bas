' ============================================================
' Predictive Name Suggester
' EkBazz 2026, public domain
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================================

DEF FN IsLetter$(c$)
    IF INSTR("abcdefghijklmnopqrstuvwxyz", LCASE(c$)) > 0 THEN
        RETURN TRUE
    END IF

    RETURN FALSE
END DEF

[inits]
    DIM names$
    GOSUB [fill-names]
    LET typed$ = ""
    LET key$
    LET char$
    LET i$
    LET found$
    LET upper$

[main]
    GOSUB [sub:display]
    WHILE TRUE
        key$ = WAITKEY()
        IF key$ = KEY_ESC# THEN END
        IF key$ = KEY_BACKSPACE# AND LEN(typed$) > 0 THEN
            typed$ = LEFT(typed$, LEN(typed$) - 1)
        END IF
        IF key$ = KEY_ENTER# THEN
            typed$ = ""
        END IF
        char$ = CHR(key$)
        IF FN IsLetter$(char$) THEN
            typed$ = typed$ + char$
        END IF
        GOSUB [sub:display]
    WEND
END

[sub:display]
    CLS
    PRINT "Start typing a name. ESC = quit, ENTER = clear."
    PRINT "-------------------------------------------"
    PRINT "> "; typed$
    PRINT ""

    IF LEN(typed$) = 0 THEN
        PRINT "(waiting for input...)"
        RETURN
    END IF

    IF UCASE(LEFT(typed$, 1)) <> "A" THEN
        PRINT "(suggestions only available for names starting with A)"
        RETURN
    END IF

    found$ = FALSE

    FOR i$ = 0 TO LEN(names$()) - 1
        IF LEN(typed$) <= LEN(names$(i$)) THEN
            upper$ = UCASE(LEFT(names$(i$), LEN(typed$)))
            IF upper$ = UCASE(typed$) THEN
                PRINT "  "; names$(i$)
                found$ = TRUE
            END IF
        END IF
    NEXT

    IF found$ = FALSE THEN
        PRINT "(no matches found)"
    END IF
RETURN

[fill-names]
    names$(0)  = "Ava"
    names$(1)  = "Amelia"
    names$(2)  = "Abigail"
    names$(3)  = "Alexandra"
    names$(4)  = "Alice"
    names$(5)  = "Aaliyah"
    names$(6)  = "Aria"
    names$(7)  = "Aurora"
    names$(8)  = "Autumn"
    names$(9)  = "Athena"
    names$(10) = "Anette"
    names$(11) = "Anna"
    names$(12) = "Annabelle"
    names$(13) = "Anastasia"
    names$(14) = "Alena"
    names$(15) = "Alina"
    names$(16) = "Amara"
    names$(17) = "Adriana"
    names$(18) = "Ayla"
RETURN