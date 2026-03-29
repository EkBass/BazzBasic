' ============================================
' https://rosettacode.org/wiki/Array_length
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

[inits]
    DIM cars$
    cars$(0) = "Audi"
    cars$(1) = "Toyota"
    cars$(2) = "Buick"
    cars$(3) = "Kia"

[output]
    PRINT LEN(cars$())
END

' Output:
' 4