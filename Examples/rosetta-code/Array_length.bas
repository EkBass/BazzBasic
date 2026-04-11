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
	' works with 1-dimension
    PRINT LEN(cars$()) 	' LEN with array works if only 1-dimension.
						' If more, ROWCOUNT works only with first dimension while LET returns the size of whole array

	' preferred way
	PRINT ROWCOUNT(cars$())
END

' Output:
' 4
' 4