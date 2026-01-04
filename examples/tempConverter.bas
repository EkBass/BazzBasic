DEF FN celsiusToFahrenheit(c$)
    RETURN c$ * 9 / 5 + 32
END DEF

DEF FN fahrenheitToCelsius(f$)
    RETURN (f$ - 32) * 5 / 9
END DEF

PRINT "Temperature Converter"
PRINT "1. Celsius to Fahrenheit"
PRINT "2. Fahrenheit to Celsius"

INPUT "Choose (1 or 2): ", choice$

IF choice$ = 1 THEN
    INPUT "Enter Celsius: ", temp$
    PRINT temp$; " C = "; FN celsiusToFahrenheit(temp$); " F"
ELSEIF choice$ = 2 THEN
    INPUT "Enter Fahrenheit: ", temp$
    PRINT temp$; " F = "; FN fahrenheitToCelsius(temp$); " C"
ELSE
    PRINT "Invalid choice"
END IF
