' ============================================
' https://rosettacode.org/wiki/Find_adjacent_primes_which_differ_by_a_square_integer
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' Find adjacent primes under 1,000,000 whose difference
' (greater than 36) is a perfect square.

[inits]
    LET LIMIT#    = 1000000
    LET MIN_DIFF# = 36

    DIM composite$          ' sieve: only composites get a key
    LET prev$ = 2           ' previous prime
    LET diff$ = 0
    LET root$ = 0

[main]
    ' Sieve of Eratosthenes over odd numbers only
    FOR i$ = 3 TO INT(SQR(LIMIT#)) STEP 2
        IF NOT HASKEY(composite$(i$)) THEN
            FOR j$ = i$ * i$ TO LIMIT# - 1 STEP i$ * 2
                composite$(j$) = 1
            NEXT
        END IF
    NEXT

    PRINT "Prime 1", "Prime 2", "Difference"
    FOR n$ = 3 TO LIMIT# - 1 STEP 2
        IF NOT HASKEY(composite$(n$)) THEN
            diff$ = n$ - prev$
            IF diff$ > MIN_DIFF# THEN
                root$ = INT(SQR(diff$))
                IF root$ * root$ = diff$ THEN PRINT prev$, n$, diff$
            END IF
            prev$ = n$
        END IF
    NEXT
END

' Output:
' Prime 1   Prime 2   Difference
' 89689     89753     64
' 107377    107441    64
' 288583    288647    64
' 367957    368021    64
' 381103    381167    64
' 396733    396833    100
' 400759    400823    64
' 445363    445427    64
' 623107    623171    64
' 625699    625763    64
' 637003    637067    64
' 710713    710777    64
' 725209    725273    64
' 779413    779477    64
' 801883    801947    64
' 803749    803813    64
' 821677    821741    64
' 832519    832583    64
' 838249    838349    100
' 844777    844841    64
' 883807    883871    64
' 912103    912167    64
' 919447    919511    64
' 954763    954827    64
' 981823    981887    64
' 997813    997877    64
