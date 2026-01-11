' FizzBuzz
' BazzBasic version. krisu.virtanen@gmail.com
' https://github.com/EkBass/BazzBasic


FOR i$ = 1 TO 100
    IF i$ % 15 = 0 THEN
        PRINT "FizzBuzz"
    ELSEIF i$ % 3 = 0 THEN
        PRINT "Fizz"
    ELSEIF i$ % 5 = 0 THEN
        PRINT "Buzz"
    ELSE
        PRINT i$
    END IF
NEXT
