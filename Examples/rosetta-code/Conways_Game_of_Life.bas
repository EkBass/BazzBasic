' ============================================
' https://rosettacode.org/wiki/Conway%27s_Game_of_Life
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' Conway's Game of Life on a bounded grid. The world is padded with
' a one-cell border of permanently dead cells, so the neighbour count
' never needs bounds checks. Two generation buffers are swapped each
' step. Shown with a blinker (task requirement) and a glider.

[inits]
    DIM world$                 ' world$(x, y, buffer) - 1 = alive, 0 = dead
    DIM pattern$               ' pattern rows, "#" = alive, "." = dead
    LET w$ = 0                 ' grid width  (from pattern)
    LET h$ = 0                 ' grid height (from pattern)
    LET gens$ = 0              ' generations to show
    LET cur$ = 0               ' index of current generation buffer
    LET buf$ = 1               ' index of next generation buffer
    LET sum$ = 0               ' live neighbour count
    LET row$ = ""              ' one printed grid row

[main]
    PRINT "Blinker"
    pattern$(0) = "....."
    pattern$(1) = "....."
    pattern$(2) = ".###."
    pattern$(3) = "....."
    pattern$(4) = "....."
    gens$ = 3
    GOSUB [sub:run]

    DELARRAY pattern$
    DIM pattern$

    PRINT "Glider"
    pattern$(0) = ".#...."
    pattern$(1) = "..#..."
    pattern$(2) = "###..."
    pattern$(3) = "......"
    pattern$(4) = "......"
    pattern$(5) = "......"
    gens$ = 5
    GOSUB [sub:run]
END

' Load the pattern and show gens$ generations
[sub:run]
    GOSUB [sub:load]
    FOR g$ = 0 TO gens$ - 1
        PRINT FSTRING("Generation {{-g$-}}:")
        GOSUB [sub:show]
        GOSUB [sub:step]
    NEXT g$
RETURN

' Clear both buffers (border included) and copy pattern$ into the world
[sub:load]
    h$ = ROWCOUNT(pattern$())
    w$ = LEN(pattern$(0))
    cur$ = 0
    buf$ = 1
    FOR y$ = 0 TO h$ + 1
        FOR x$ = 0 TO w$ + 1
            world$(x$, y$, 0) = 0
            world$(x$, y$, 1) = 0
        NEXT x$
    NEXT y$
    FOR y$ = 1 TO h$
        FOR x$ = 1 TO w$
            IF MID(pattern$(y$ - 1), x$, 1) = "#" THEN world$(x$, y$, cur$) = 1
        NEXT x$
    NEXT y$
RETURN

' Print the current generation
[sub:show]
    FOR y$ = 1 TO h$
        row$ = ""
        FOR x$ = 1 TO w$
            IF world$(x$, y$, cur$) = 1 THEN
                row$ += "#"
            ELSE
                row$ += "."
            END IF
        NEXT x$
        PRINT row$
    NEXT y$
    PRINT ""
RETURN

' Compute the next generation into buf$, then swap buffers
[sub:step]
    FOR y$ = 1 TO h$
        FOR x$ = 1 TO w$
            sum$ = world$(x$ - 1, y$ - 1, cur$) + world$(x$, y$ - 1, cur$) + world$(x$ + 1, y$ - 1, cur$) +
                   world$(x$ - 1, y$,     cur$) +                           world$(x$ + 1, y$,     cur$) +
                   world$(x$ - 1, y$ + 1, cur$) + world$(x$, y$ + 1, cur$) + world$(x$ + 1, y$ + 1, cur$)
            IF sum$ = 3 THEN
                world$(x$, y$, buf$) = 1                       ' birth or survival
            ELSEIF sum$ = 2 THEN
                world$(x$, y$, buf$) = world$(x$, y$, cur$)    ' unchanged
            ELSE
                world$(x$, y$, buf$) = 0                       ' loneliness or overcrowding
            END IF
        NEXT x$
    NEXT y$
    cur$ = buf$
    buf$ = 1 - buf$
RETURN

' Output:
' Blinker
' Generation 0:
' .....
' .....
' .###.
' .....
' .....
'
' Generation 1:
' .....
' ..#..
' ..#..
' ..#..
' .....
'
' Generation 2:
' .....
' .....
' .###.
' .....
' .....
'
' Glider
' Generation 0:
' .#....
' ..#...
' ###...
' ......
' ......
' ......
'
' Generation 1:
' ......
' #.#...
' .##...
' .#....
' ......
' ......
'
' Generation 2:
' ......
' ..#...
' #.#...
' .##...
' ......
' ......
'
' Generation 3:
' ......
' .#....
' ..##..
' .##...
' ......
' ......
'
' Generation 4:
' ......
' ..#...
' ...#..
' .###..
' ......
' ......
