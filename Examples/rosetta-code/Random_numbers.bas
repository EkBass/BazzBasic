' ============================================
' ROSETTA: https://rosettacode.org/wiki/Random_numbers
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Generates 1000 normally distributed random numbers (mean 1.0, standard deviation 0.5) from uniform RND(0) values with the Box-Muller transform, and prints the sample mean and standard deviation.
' CATEGORY: math
' TAGS: random numbers, normal distribution, box-muller, statistics
' MINVERSION: 1.5
' ============================================
'
' RND(0) is uniform, so the Box-Muller transform turns two uniform
' values into one standard normal value z, then scales it:
'     x = MEAN + SD * z
' 1 - RND(0) keeps u1 above zero so LOG never sees 0.

[inits]
    LET COUNT# = 1000
    LET MEAN# = 1.0
    LET SD# = 0.5

    DIM nums$
    LET u1$ = 0
    LET u2$ = 0
    LET sum$ = 0
    LET sqSum$ = 0
    LET mean$ = 0
    LET sd$ = 0

[main]
    FOR i$ = 0 TO COUNT# - 1
        u1$ = 1 - RND(0)
        u2$ = RND(0)
        nums$(i$) = MEAN# + SD# * SQR(-2 * LOG(u1$)) * COS(TAU# * u2$)
    NEXT

    ' Check the result: sample mean and standard deviation
    FOR i$ = 0 TO COUNT# - 1
        sum$ += nums$(i$)
    NEXT
    mean$ = sum$ / COUNT#

    FOR i$ = 0 TO COUNT# - 1
        sqSum$ += POW(nums$(i$) - mean$, 2)
    NEXT
    sd$ = SQR(sqSum$ / COUNT#)

    PRINT "Mean:               "; mean$
    PRINT "Standard deviation: "; sd$
END

' Output (varies per run):
' Mean:               1.0089315472918624
' Standard deviation: 0.4961842107553903
