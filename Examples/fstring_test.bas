REM ============================================
REM Test: FSTRING() string interpolation
REM ============================================

PRINT "Testing FSTRING..."
PRINT ""

REM --- Test 1: Basic substitution ---
LET a$ = "Hello"
LET b$ = "Foo"
LET r1$ = FSTRING("{{-a$-}} world. This is {{-b$-}}")
PRINT "Test 1: " + r1$
PRINT "Expect: Hello world. This is Foo"
PRINT ""

REM --- Test 2: Numbers auto-stringify ---
LET score$ = 42
LET hp$ = 87.5
LET r2$ = FSTRING("Score: {{-score$-}}, HP: {{-hp$-}}")
PRINT "Test 2: " + r2$
PRINT "Expect: Score: 42, HP: 87.5"
PRINT ""

REM --- Test 3: Constants (#) work too ---
LET MAX# = 100
LET TITLE# = "BazzBasic"
LET r3$ = FSTRING("Welcome to {{-TITLE#-}}, max = {{-MAX#-}}")
PRINT "Test 3: " + r3$
PRINT "Expect: Welcome to BazzBasic, max = 100"
PRINT ""

REM --- Test 4: Whitespace inside placeholder is trimmed ---
LET name$ = "Krisu"
LET r4$ = FSTRING("Hi {{- name$ -}}, hi {{-name$-}}, hi {{-  name$  -}}")
PRINT "Test 4: " + r4$
PRINT "Expect: Hi Krisu, hi Krisu, hi Krisu"
PRINT ""

REM --- Test 5: Mixed $ and # in same template ---
LET PLAYER# = "Hero"
LET level$ = 5
LET r5$ = FSTRING("{{-PLAYER#-}} is at level {{-level$-}}")
PRINT "Test 5: " + r5$
PRINT "Expect: Hero is at level 5"
PRINT ""

REM --- Test 6: Adjacent placeholders ---
LET first$ = "BAZZ"
LET last$ = "BASIC"
LET r6$ = FSTRING("{{-first$-}}{{-last$-}}")
PRINT "Test 6: " + r6$
PRINT "Expect: BAZZBASIC"
PRINT ""

REM --- Test 7: Template with no placeholders passes through ---
LET r7$ = FSTRING("Just a plain string with no markers.")
PRINT "Test 7: " + r7$
PRINT "Expect: Just a plain string with no markers."
PRINT ""

REM --- Test 8: Empty template ---
LET r8$ = FSTRING("")
PRINT "Test 8: [" + r8$ + "]"
PRINT "Expect: []"
PRINT ""

REM --- Test 9: Single { and } chars are literal ---
LET who$ = "world"
LET r9$ = FSTRING("Hello {curly} {{-who$-}}")
PRINT "Test 9: " + r9$
PRINT "Expect: Hello {curly} world"
PRINT ""

REM --- Test 10: Template stored in variable ---
LET tmpl$ = "Hi {{-a$-}}!"
LET r10$ = FSTRING(tmpl$)
PRINT "Test 10: " + r10$
PRINT "Expect: Hi Hello!"
PRINT ""

REM --- Test 11: Array access with numeric literal index ---
DIM arr$
    arr$(0) = "zero"
    arr$(1) = "one"
    arr$(2) = "two"
LET r11$ = FSTRING("{{-arr$(0)-}}, {{-arr$(1)-}}, {{-arr$(2)-}}")
PRINT "Test 11: " + r11$
PRINT "Expect: zero, one, two"
PRINT ""

REM --- Test 12: Array access with variable index ---
LET i$ = 1
LET r12$ = FSTRING("Index {{-i$-}} is {{-arr$(i$)-}}")
PRINT "Test 12: " + r12$
PRINT "Expect: Index 1 is one"
PRINT ""

REM --- Test 13: Array access with constant index ---
LET IDX# = 2
LET r13$ = FSTRING("Constant index: {{-arr$(IDX#)-}}")
PRINT "Test 13: " + r13$
PRINT "Expect: Constant index: two"
PRINT ""

REM --- Test 14: Array with string keys ---
DIM player$
    player$("name")  = "Krisu"
    player$("class") = "Bass"
    player$("level") = 99
LET r14$ = FSTRING("{{-player$(name)-}} the {{-player$(class)-}}, lvl {{-player$(level)-}}")
PRINT "Test 14: " + r14$
PRINT "Expect: Krisu the Bass, lvl 99"
PRINT ""

REM --- Test 15: Multidimensional array ---
DIM grid$
    grid$(0, 0) = "A"
    grid$(0, 1) = "B"
    grid$(1, 0) = "C"
    grid$(1, 1) = "D"
LET r15$ = FSTRING("[{{-grid$(0,0)-}}{{-grid$(0,1)-}}/{{-grid$(1,0)-}}{{-grid$(1,1)-}}]")
PRINT "Test 15: " + r15$
PRINT "Expect: [AB/CD]"
PRINT ""

REM --- Test 16: Multidimensional with mixed literal + variable indices ---
LET row$ = 1
LET r16$ = FSTRING("Row {{-row$-}}: {{-grid$(row$, 0)-}} and {{-grid$(row$, 1)-}}")
PRINT "Test 16: " + r16$
PRINT "Expect: Row 1: C and D"
PRINT ""

REM --- Test 17: Whitespace tolerated inside array indexing ---
LET r17$ = FSTRING("{{- arr$( 0 ) -}} / {{- arr$( 1 ) -}}")
PRINT "Test 17: " + r17$
PRINT "Expect: zero / one"
PRINT ""

REM --- Test 18: Array element holds a number ---
DIM nums$
    nums$(0) = 3.14
    nums$(1) = 42
LET r18$ = FSTRING("pi={{-nums$(0)-}} answer={{-nums$(1)-}}")
PRINT "Test 18: " + r18$
PRINT "Expect: pi=3.14 answer=42"
PRINT ""

PRINT "All FSTRING tests done!"
END
