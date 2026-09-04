' BazzBasic version 1.4c
' https://ekbass.github.io/BazzBasic/

' Our beautiful Finnish flag
' Follows the official proportions given for the flag
' https://www.qwant.com/?q=suomen+lipun+mitat&client=brz-brave&t=images&o=0%3AB7777298A812E81931E04B69F3DD38111AF26780

' Just by changing colors, you can use this to draw at least dozen other flags.

[inits]
    LET BLOCK#  = 30
    LET WIDTH#  = BLOCK# * 18
    LET HEIGHT# = BLOCK# * 11
    LET WHITE#  = 15
    LET BLUE#   = 1

    SCREEN 0, WIDTH#, HEIGHT#, "Finnish flag with BazzBasic"

[draw]
    SCREENLOCK ON

        ' all white background
        LINE(0, 0) - (WIDTH#, HEIGHT#), WHITE#, bf

        ' The horizontal line of the cross in the right place with the right proportions
        LINE(0, BLOCK# * 4) - (WIDTH#, BLOCK# * 7), BLUE#, bf

        ' The vertical line of the cross in the right place with the right proportions
        LINE(BLOCK# * 5, 0) - (BLOCK# * 8, HEIGHT#), BLUE#, bf
    SCREENLOCK OFF
    LET kwk$ = WAITKEY()
END
