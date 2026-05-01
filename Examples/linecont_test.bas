REM ============================================
REM Test: Implicit line continuation
REM
REM Newlines are suppressed when:
REM   1. The previous token cannot legally end
REM      an expression (operator, comma, etc.)
REM   2. We are inside an open '(...)' pair.
REM ============================================

PRINT "Testing line continuation..."
PRINT ""

REM ===== Arithmetic =====

LET a$ = "Hello" +
         "World"
PRINT "Test 1 (+):  " + a$
PRINT "Expect:      HelloWorld"

LET b$ = 100 -
         30 -
         5
PRINT "Test 2 (-):  " + STR(b$)
PRINT "Expect:      65"

LET c$ = 6 *
         7
PRINT "Test 3 (*):  " + STR(c$)
PRINT "Expect:      42"

LET d$ = 100 /
         4
PRINT "Test 4 (/):  " + STR(d$)
PRINT "Expect:      25"

LET e$ = 23 %
         5
PRINT "Test 5 (%):  " + STR(e$)
PRINT "Expect:      3"

PRINT ""
REM ===== Comparison =====

LET g$ =
        99
PRINT "Test 6 (=):  " + STR(g$)
PRINT "Expect:      99"

IF 5 <
   10 THEN
    PRINT "Test 7 (<):  ok"
END IF
PRINT "Expect:      ok"

IF "a" <>
   "b" THEN
    PRINT "Test 8 (<>): ok"
END IF
PRINT "Expect:      ok"

IF 5 >=
   5 THEN
    PRINT "Test 9 (>=): ok"
END IF
PRINT "Expect:      ok"

PRINT ""
REM ===== Logical =====

LET x$ = 5
LET y$ = 10
IF x$ > 0 AND
   y$ > 0 THEN
    PRINT "Test 10 (AND): ok"
END IF
PRINT "Expect:        ok"

IF x$ < 0 OR
   y$ > 0 THEN
    PRINT "Test 11 (OR):  ok"
END IF
PRINT "Expect:        ok"

PRINT ""
REM ===== Compound assign =====

LET h$ = "start"
LET h$ +=
        " end"
PRINT "Test 12 (+=): " + h$
PRINT "Expect:       start end"

LET i$ = 100
LET i$ -=
        25
PRINT "Test 13 (-=): " + STR(i$)
PRINT "Expect:       75"

LET j$ = 6
LET j$ *=
        7
PRINT "Test 14 (*=): " + STR(j$)
PRINT "Expect:       42"

LET k$ = 100
LET k$ /=
        4
PRINT "Test 15 (/=): " + STR(k$)
PRINT "Expect:       25"

PRINT ""
REM ===== Structural ? comma & paren =====

LET dist$ = DISTANCE(0, 0,
                     3, 4)
PRINT "Test 16 (,):    " + STR(dist$)
PRINT "Expect:         5"

REM Paren-depth: open paren on its own line, close on next
LET len$ = LEN(
    "hello"
)
PRINT "Test 17 (paren-depth): " + STR(len$)
PRINT "Expect:                5"

REM Nested parens spanning multiple lines
LET val$ = MAX(
    MIN(
        100,
        50
    ),
    25
)
PRINT "Test 18 (nested):      " + STR(val$)
PRINT "Expect:                50"

REM Multidim array indices split across lines
DIM grid$
    grid$(0,
          0) = "X"
    grid$(0,
          1) = "O"
PRINT "Test 19 (DIM):  " + grid$(0, 0) + grid$(0, 1)
PRINT "Expect:         XO"

REM Mixing both mechanisms ? open paren AND operator continuation
LET mixed$ = (
    10 +
    20 +
    30
)
PRINT "Test 20 (mixed): " + STR(mixed$)
PRINT "Expect:          60"

PRINT ""
REM ===== Combined / Real-world =====

LET score$ = 75
IF score$ >= 0 AND
   score$ <= 100 AND
   score$ <>
   42 THEN
    PRINT "Test 21: valid score"
END IF
PRINT "Expect:  valid score"

REM Empty lines tolerated mid-continuation
LET m$ = "a" +

         "b" +

         "c"
PRINT "Test 22: " + m$
PRINT "Expect:  abc"

REM Comments after operator
LET n$ = 1 +    ' first
         2 +    ' second
         3      ' third
PRINT "Test 23: " + STR(n$)
PRINT "Expect:  6"

REM FSTRING template across lines
LET who$ = "world"
LET o$ = FSTRING("Hi " +
                 "{{-who$-}}!")
PRINT "Test 24: " + o$
PRINT "Expect:  Hi world!"

REM Spec example from todo.txt
[inits]
    LET p$ = "Hello" +
        "World"
[runtest]
    PRINT "Test 25: " + p$
    PRINT "Expect:  HelloWorld"

PRINT ""
PRINT "All line continuation tests done!"
END
