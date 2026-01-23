# Tutorial: Ball Animation

Create an animated bouncing ball using BazzBasic graphics!

## Prerequisites

Make sure you understand:
- [Variables & Constants](variables-and-constants.md)
- [Control Flow](control-flow.md)
- [Graphics Commands](graphics.md)

## The Goal

Create a ball that:
1. Moves across the screen
2. Bounces off the edges
3. Animates smoothly

## The Code

```basic
REM Bouncing Ball Animation

SCREEN 800, 600

LET x$ = 400
LET y$ = 300
LET dx$ = 5
LET dy$ = 3
LET radius$ = 20

WHILE INKEY = 0
    CLS
    
    ' Draw ball
    CIRCLE x$, y$, radius$, 14, 1
    
    ' Move ball
    x$ = x$ + dx$
    y$ = y$ + dy$
    
    ' Bounce off edges
    IF x$ < radius$ OR x$ > 800 - radius$ THEN
        dx$ = -dx$
    ENDIF
    
    IF y$ < radius$ OR y$ > 600 - radius$ THEN
        dy$ = -dy$
    ENDIF
    
    ' Control speed
    SLEEP 16
    
    FLIP
WEND
```

## How It Works

- `SCREEN` opens graphics window
- `dx$` and `dy$` control direction and speed
- Negating `dx$` or `dy$` reverses direction (bounce)
- `SLEEP 16` gives ~60 FPS
- `FLIP` updates the display (double buffering)

## Challenges

- Add multiple balls
- Change colors when bouncing
- Add gravity effect
- Make balls leave trails

## What You Learned

- Graphics mode with `SCREEN`
- Animation loop
- Collision detection with edges
- Double buffering with `FLIP`

## Next Steps

- [Simple Sound Effects Tutorial](tutorial-sounds.md)
- [Graphics Commands Reference](graphics.md)
