' ============================================
' ROSETTA: https://rosettacode.org/wiki/Exactly_three_adjacent_3_in_lists
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Checks five lists of numbers and prints true for each list that contains exactly three 3s forming one consecutive run and no other 3 anywhere.
' CATEGORY: algorithms
' TAGS: lists, consecutive runs, split, counting
' MINVERSION: 1.5
' ============================================
' For each list, print true if it contains exactly three 3s
' forming one consecutive run, and no other 3 anywhere.

[inits]
    DIM lists$
    lists$(1) = "9,3,3,3,2,1,7,8,5"
    lists$(2) = "5,2,9,3,3,7,8,4,1"
    lists$(3) = "1,4,3,6,7,3,8,3,2"
    lists$(4) = "1,2,3,4,5,6,7,8,9"
    lists$(5) = "4,6,8,7,2,3,3,3,1"

    DIM nums$
    LET count$  = 0         ' elements in current list
    LET threes$ = 0         ' how many 3s in total
    LET runs$   = 0         ' how many separate runs of 3s
    LET inRun$  = FALSE     ' is the previous element a 3?
    LET result$ = ""

[main]
    FOR i$ = 1 TO ROWCOUNT(lists$())
        count$  = SPLIT(nums$, lists$(i$), ",")
        threes$ = 0
        runs$   = 0
        inRun$  = FALSE

        FOR j$ = 0 TO count$ - 1
            IF VAL(nums$(j$)) = 3 THEN
                threes$ += 1
                IF NOT inRun$ THEN runs$ += 1   ' a new run starts here
                inRun$ = TRUE
            ELSE
                inRun$ = FALSE
            END IF
        NEXT

        ' Exactly three 3s, all in a single run
        IF threes$ = 3 AND runs$ = 1 THEN
            result$ = "true"
        ELSE
            result$ = "false"
        END IF

        PRINT FSTRING("list[{{-i$-}}] = [{{-lists$(i$)-}}]  ->  {{-result$-}}")
    NEXT
END

' Output:
' list[1] = [9,3,3,3,2,1,7,8,5]  ->  true
' list[2] = [5,2,9,3,3,7,8,4,1]  ->  false
' list[3] = [1,4,3,6,7,3,8,3,2]  ->  false
' list[4] = [1,2,3,4,5,6,7,8,9]  ->  false
' list[5] = [4,6,8,7,2,3,3,3,1]  ->  true
