' ============================================
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Shows how to produce random floats and integers with RND, including a reusable function for a random integer in a given range.
' CATEGORY: math
' TAGS: random numbers, rnd, range
' MINVERSION: 1.5
' ============================================

DEF FN RndRange$(first$, last$)
    RETURN RND(0) * (last$ - first$) + first$
END DEF

[main]
    ' random float [0, 1)
    PRINT RND(0)

    ' random float [0, 10)
    PRINT RND(0) * 10

    ' random integer [1, 10]
    PRINT INT(RND(0) * 10) + 1

    ' random integer [69, 420]
    PRINT INT(FN RndRange$(69, 421))
END