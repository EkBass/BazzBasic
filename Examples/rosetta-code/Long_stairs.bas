' ============================================
' Wizard's staircase (Rosetta Code: Long stairs)
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

[inits]
    LET TRIALS#       = 10000   ' how many times the runner tries
    LET START_LENGTH# = 100     ' staircase length at start
    LET WIZARD_STEPS# = 5       ' steps the wizard adds per second
    LET REPORT_FROM#  = 600     ' first-trial report window (seconds)
    LET REPORT_TO#    = 609

    LET stepsBehind$  = 0
    LET stairsLength$ = 0
    LET seconds$      = 0
    LET secondsTotal$ = 0
    LET stepsTotal$   = 0

[main]
    PRINT "Seconds", "steps behind", "steps ahead"

    FOR trial$ = 1 TO TRIALS#
        ' runner starts at the bottom of a fresh 100-step staircase
        stepsBehind$  = 0
        seconds$      = 0
        stairsLength$ = START_LENGTH#

        WHILE stepsBehind$ < stairsLength$
            stepsBehind$ += 1                       ' runner climbs one step
            FOR j$ = 1 TO WIZARD_STEPS#             ' wizard conjures five steps
                ' a new step lands behind the runner with probability behind/length
                IF RND(stairsLength$) < stepsBehind$ THEN stepsBehind$ += 1
                stairsLength$ += 1                  ' staircase grows either way
            NEXT
            seconds$ += 1                           ' all that took one second
            ' first attempt: show progress after ten minutes
            IF trial$ = 1 AND BETWEEN(seconds$, REPORT_FROM#, REPORT_TO#) THEN
                PRINT seconds$, stepsBehind$, stairsLength$ - stepsBehind$
            END IF
        WEND

        secondsTotal$ += seconds$
        stepsTotal$   += stairsLength$
    NEXT

    PRINT "Average time taken: "; secondsTotal$ / TRIALS#; " seconds."
    PRINT "Average final staircase length: "; stepsTotal$ / TRIALS#; " steps."
    ' the last number is about 100 * EXP(5) - no coincidence
END

' Output (random, varies per run):
' Seconds	steps behind	steps ahead
' 600	2146	954
' 601	2149	956
' 602	2154	956
' 603	2159	956
' 604	2165	955
' 605	2170	955
' 606	2174	956
' 607	2179	956
' 608	2182	958
' 609	2184	961
' Average time taken: 2920.2375 seconds.
' Average final staircase length: 14701.1875 steps.