' ============================================
' ROSETTA: https://rosettacode.org/wiki/Towers_of_Hanoi
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Solves the Towers of Hanoi puzzle recursively for four disks and prints each of the 15 moves from peg A to peg C, using peg B as the spare peg.
' CATEGORY: algorithms
' TAGS: recursion, towers of hanoi, def fn
' MINVERSION: 1.5
' ============================================

' Recursive solution: move n disks from peg 'from' to peg 'to'
' using peg 'via' as auxiliary.
' Return value is unused — all output is produced as a side effect.

DEF FN Hanoi$(n$, from$, to$, via$)
    LET r$
    IF n$ = 1 THEN
        PRINT "Move disk 1 from peg " + from$ + " to peg " + to$
        RETURN ""
    END IF
    r$ = FN Hanoi$(n$ - 1, from$, via$, to$)
    PRINT "Move disk " + STR(INT(n$)) + " from peg " + from$ + " to peg " + to$
    r$ = FN Hanoi$(n$ - 1, via$, to$, from$)
    RETURN ""
END DEF

[inits]
    LET DISKS# = 4
    LET result$

[main]
    result$ = FN Hanoi$(DISKS#, "A", "C", "B")
END

' Output (4 disks, 15 moves):
' Move disk 1 from peg A to peg C
' Move disk 2 from peg A to peg B
' Move disk 1 from peg C to peg B
' Move disk 3 from peg A to peg C
' Move disk 1 from peg B to peg A
' Move disk 2 from peg B to peg C
' Move disk 1 from peg A to peg C
' Move disk 4 from peg A to peg B
' Move disk 1 from peg C to peg B
' Move disk 2 from peg C to peg A
' Move disk 1 from peg B to peg A
' Move disk 3 from peg C to peg B
' Move disk 1 from peg A to peg C
' Move disk 2 from peg A to peg B
' Move disk 1 from peg C to peg B
