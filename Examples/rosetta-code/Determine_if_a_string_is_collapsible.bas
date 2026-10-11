' ============================================
' https://rosettacode.org/wiki/Determine_if_a_string_is_collapsible
' BazzBasic: https://github.com/EkBass/BazzBasic
' Collapse immediately repeated characters in a string
' ============================================

' Keep the first character of every run, drop the repeats
DEF FN Collapse$(src$)
    IF LEN(src$) = 0 THEN RETURN ""
    LET prev$   = LEFT(src$, 1)
    LET result$ = prev$
    LET c$      = ""
    FOR i$ = 2 TO LEN(src$)
        c$ = MID(src$, i$, 1)
        IF c$ <> prev$ THEN
            result$ += c$
            prev$ = c$
        END IF
    NEXT
    RETURN result$
END DEF

[inits]
    DIM strings$
    strings$(0) = ""
    strings$(1) = "\"If I were two-faced, would I be wearing this one?\" --- Abraham Lincoln "
    strings$(2) = ".." + REPEAT("1", 63) + "7777888"
    strings$(3) = "I never give 'em hell, I just tell the truth, and they think it's hell. "
    strings$(4) = REPEAT(" ", 52) + "--- Harry S Truman  "

    LET original$  = ""
    LET collapsed$ = ""

[main]
    FOR n$ = 0 TO ROWCOUNT(strings$()) - 1
        original$  = strings$(n$)
        collapsed$ = FN Collapse$(original$)
        PRINT "Original : <<<"; original$;  ">>> (length "; LEN(original$);  ")"
        PRINT "Collapsed: <<<"; collapsed$; ">>> (length "; LEN(collapsed$); ")"
        IF LEN(collapsed$) < LEN(original$) THEN
            PRINT "Collapsible: yes"
        ELSE
            PRINT "Collapsible: no"
        END IF
        PRINT
    NEXT
END

' Output:
' Original : <<<>>> (length 0)
' Collapsed: <<<>>> (length 0)
' Collapsible: no
'
' Original : <<<"If I were two-faced, would I be wearing this one?" --- Abraham Lincoln >>> (length 72)
' Collapsed: <<<"If I were two-faced, would I be wearing this one?" - Abraham Lincoln >>> (length 70)
' Collapsible: yes
'
' Original : <<<..1111111111111111111111111111111111111111111111111111111111111117777888>>> (length 72)
' Collapsed: <<<.178>>> (length 4)
' Collapsible: yes
'
' Original : <<<I never give 'em hell, I just tell the truth, and they think it's hell. >>> (length 72)
' Collapsed: <<<I never give 'em hel, I just tel the truth, and they think it's hel. >>> (length 69)
' Collapsible: yes
'
' Original : <<<                                                    --- Harry S Truman  >>> (length 72)
' Collapsed: <<< - Hary S Truman >>> (length 17)
' Collapsible: yes
