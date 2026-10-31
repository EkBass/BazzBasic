' ============================================
' ROSETTA: https://rosettacode.org/wiki/Sum_of_a_series
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Sums the series 1/k^2 for k from 1 to 1000 and compares the result with the exact limit pi^2/6 (zeta(2)).
' CATEGORY: math
' TAGS: series, summation, zeta function, pow, pi
' MINVERSION: 1.5
' ============================================

[inits]
	LET N# = 1000
	LET sum$ = 0

[main]
	FOR k$ = 1 TO N#
		sum$+= 1 / POW(k$, 2)
	NEXT
	PRINT "s(1000) = "; sum$
	PRINT "zeta(2) = "; POW(PI#, 2) / 6
END

' Expected output:
' s(1000) = 1.6439345666815597
' zeta(2) = 1.6449340668482264