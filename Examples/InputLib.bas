REM ============================================
REM Library: InputLib.bas
REM Functions that use INPUT and LINE INPUT
REM ============================================

DEF FN getName$()
    LET result$
    LINE INPUT "Enter your full name: ", result$
    RETURN result$
END DEF

DEF FN getAge$()
    LET age$
    INPUT "Enter your age: ", age$
    RETURN age$
END DEF

DEF FN getAddress$()
    LET addr$
    LINE INPUT "Enter address (with spaces): ", addr$
    RETURN addr$
END DEF
