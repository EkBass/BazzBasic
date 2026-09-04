REM ================================================
REM Reverse_Case_with_BETWEEN.bas
REM BazzBasic - github.com/EkBass/BazzBasic
REM ================================================

DEF FN ReverseCase$(s$)
    LET result$ = ""
	LET c$
	LET a$
	
    FOR i$ = 1 TO LEN(s$)
        c$ = MID(s$, i$, 1)
        a$ = ASC(c$)
        IF BETWEEN(a$, 65, 90) THEN
            result$ = result$ + CHR(a$ + 32)
        ELSEIF BETWEEN(a$, 97, 122) THEN
            result$ = result$ + CHR(a$ - 32)
        ELSE
            result$ = result$ + c$
        END IF
    NEXT
    RETURN result$
END DEF

[main]
    PRINT FN ReverseCase$("Happy Birthday")
    PRINT FN ReverseCase$("MANY THANKS")
    PRINT FN ReverseCase$("sPoNtAnEoUs")
    PRINT FN ReverseCase$("Hello, World! 123")

' Output:
' hAPPY bIRTHDAY
' many thanks
' SpOnTaNeOuS
' hELLO, wORLD! 123