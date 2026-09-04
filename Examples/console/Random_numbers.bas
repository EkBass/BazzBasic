' BazzBasic version 1.3
' https://ekbass.github.io/BazzBasic/

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