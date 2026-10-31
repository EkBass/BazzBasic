' ============================================
' ROSETTA: https://rosettacode.org/wiki/Rate_counter
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Measures how fast a small job runs in jobs per second, first by running it for a fixed time and then by running a fixed number of jobs and timing them, with three runs for each mode.
' CATEGORY: system
' TAGS: rate counter, ticks, timing, benchmark
' MINVERSION: 1.5
' ============================================
' Measures how fast a job runs, two ways:
'   1. Time-bounded:  run jobs for N milliseconds, count how many ran
'   2. Count-bounded: run Y jobs, measure how long it took
' Each mode reports three runs as jobs per second.
'
' Timing notes:
'   TICKS returns whole milliseconds since program start, so every
'   reading can be off by up to 1 ms. A measurement uses two readings,
'   so short runs are unreliable: a 1 ms run can be off by 100%,
'   a 1000 ms run by about 0.1%. Use runs of at least a few hundred ms.
'   The time-bounded loop reads TICKS on every pass, so that overhead
'   is included in its rate; the count-bounded loop reads it only twice.
'   The first run may also be slightly slower while the runtime warms up.

[inits]
    LET duration$   = 0     ' time-bounded run length, in ms
    LET jobsTarget$ = 0     ' count-bounded run size
    LET jobs$       = 0
    LET start$      = 0
    LET elapsed$    = 0
    LET rate$       = 0
    LET work$       = 0     ' state used by the dummy job

    DIM durations$
        durations$(0) = 100
        durations$(1) = 500
        durations$(2) = 1000

    DIM counts$
        counts$(0) = 10000
        counts$(1) = 50000
        counts$(2) = 200000

[main]
    PRINT "Time-bounded: run jobs for a fixed time"
    FOR i$ = 0 TO ROWCOUNT(durations$()) - 1
        duration$ = durations$(i$)
        GOSUB [sub:RunForTime]
    NEXT

    PRINT ""
    PRINT "Count-bounded: run a fixed number of jobs"
    FOR i$ = 0 TO ROWCOUNT(counts$()) - 1
        jobsTarget$ = counts$(i$)
        GOSUB [sub:RunForCount]
    NEXT
END

' The job being measured: a small piece of arithmetic
[sub:Job]
    work$ = SQR(work$ + 1)
RETURN

' Run jobs until duration$ ms have passed, then report the rate
[sub:RunForTime]
    jobs$    = 0
    elapsed$ = 0
    start$   = TICKS
    WHILE elapsed$ < duration$
        GOSUB [sub:Job]
        jobs$ += 1
        elapsed$ = TICKS - start$
    WEND
    rate$ = INT(jobs$ * 1000 / elapsed$)
    PRINT FSTRING("  {{-jobs$-}} jobs in {{-elapsed$-}} ms = {{-rate$-}} jobs/s")
RETURN

' Run jobsTarget$ jobs, then report the time taken and the rate
[sub:RunForCount]
    start$ = TICKS
    FOR j$ = 1 TO jobsTarget$
        GOSUB [sub:Job]
    NEXT
    elapsed$ = TICKS - start$
    IF elapsed$ = 0 THEN
        PRINT FSTRING("  {{-jobsTarget$-}} jobs in under 1 ms, too fast to measure")
    ELSE
        rate$ = INT(jobsTarget$ * 1000 / elapsed$)
        PRINT FSTRING("  {{-jobsTarget$-}} jobs in {{-elapsed$-}} ms = {{-rate$-}} jobs/s")
    END IF
RETURN

' Output (varies by machine):
' (paste a real run here)