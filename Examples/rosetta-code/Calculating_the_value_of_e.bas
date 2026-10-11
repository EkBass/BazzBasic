' ============================================
' https://rosettacode.org/wiki/Calculating_the_value_of_e
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

' While BazzBasic has Euler as built-in constant (EULER#)
' this task requires calculating it, so here goes.

' e = 1/0! + 1/1! + 1/2! + 1/3! + ...
' Terms are added until the sum stops changing
' at double precision.

[inits]
    LET e$     = 1      ' running sum, starts with 1/0!
    LET prev$  = 0      ' sum from previous round
    LET term$  = 1      ' current term 1/n!
    LET n$     = 0

[main]
    WHILE e$ <> prev$
        prev$ = e$
        n$ += 1
        term$ /= n$     ' 1/n! built from 1/(n-1)!
        e$ += term$
    WEND

    PRINT FSTRING("Calculated e : {{-e$-}}")
    PRINT FSTRING("Built-in   e : {{-EULER#-}}")
    PRINT FSTRING("Terms summed : {{-n$-}}")
END

' Output:
' Calculated e : 2.7182818284590455
' Built-in   e : 2.718281828459045
' Terms summed : 18