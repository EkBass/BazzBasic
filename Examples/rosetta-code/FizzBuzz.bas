' ============================================
' ROSETTA: https://rosettacode.org/wiki/FizzBuzz
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Prints the numbers 1 to 100, replacing multiples of 3 with Fizz, multiples of 5 with Buzz and multiples of both with FizzBuzz.
' CATEGORY: basics
' TAGS: fizzbuzz, loop, modulo, conditions
' MINVERSION: 1.5
' ============================================
' Print numbers 1 to 100.
' Multiples of 3  -> "Fizz"
' Multiples of 5  -> "Buzz"
' Multiples of both -> "FizzBuzz"

[main]
    FOR n$ = 1 TO 100
        IF MOD(n$, 15) = 0 THEN
            PRINT "FizzBuzz"
        ELSEIF MOD(n$, 3) = 0 THEN
            PRINT "Fizz"
        ELSEIF MOD(n$, 5) = 0 THEN
            PRINT "Buzz"
        ELSE
            PRINT n$
        END IF
    NEXT
END

' Output (first 20 lines):
' 1
' 2
' Fizz
' 4
' Buzz
' Fizz
' 7
' 8
' Fizz
' Buzz
' 11
' Fizz
' 13
' 14
' FizzBuzz
' 16
' 17
' Fizz
' 19
' Buzz
