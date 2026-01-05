PRINT "Simple Calculator"
PRINT "================="

[start]
    INPUT "First number: ", a$
    INPUT "Operator (+, -, *, /): ", op$
    INPUT "Second number: ", b$
    
    IF op$ = "+" THEN
        PRINT "Result: "; a$ + b$
    ELSEIF op$ = "-" THEN
        PRINT "Result: "; a$ - b$
    ELSEIF op$ = "*" THEN
        PRINT "Result: "; a$ * b$
    ELSEIF op$ = "/" THEN
        IF b$ = 0 THEN
            PRINT "Error: Division by zero"
        ELSE
            PRINT "Result: "; a$ / b$
        END IF
    ELSE
        PRINT "Unknown operator"
    END IF
    
    INPUT "Continue? (y/n): ", again$
    IF again$ = "y" THEN GOTO [start]
    
PRINT "Goodbye!"
