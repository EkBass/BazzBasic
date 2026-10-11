' ============================================
' https://rosettacode.org/wiki/Append_numbers_at_same_position_in_strings
' BazzBasic: https://github.com/EkBass/BazzBasic
' Task: given three lists of numbers, join the numbers at the same
'       position into one number, e.g. 1, 10, 19 -> 11019.
' ============================================

[inits]
    DIM list1$, list2$, list3$
    LET count$ = SPLIT(list1$, "1,2,3,4,5,6,7,8,9", ",")
    count$ = SPLIT(list2$, "10,11,12,13,14,15,16,17,18", ",")
    count$ = SPLIT(list3$, "19,20,21,22,23,24,25,26,27", ",")
    LET joined$ = 0
    LET output$ = ""

[main]
    FOR i$ = 0 TO count$ - 1
        joined$ = VAL(FSTRING("{{-list1$(i$)-}}{{-list2$(i$)-}}{{-list3$(i$)-}}"))
        output$ += joined$ + " "
    NEXT
    PRINT TRIM(output$)
END

' Output:
' 11019 21120 31221 41322 51423 61524 71625 81726 91827