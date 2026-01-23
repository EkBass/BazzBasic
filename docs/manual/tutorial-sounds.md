# Tutorial: Simple Sound Effects

Add sounds to your BazzBasic programs!

## Prerequisites

- A `.wav` or `.mp3` sound file
- Understanding of [Variables](variables-and-constants.md)

## Loading and Playing Sounds

### Step 1: Load a Sound

```basic
LET sound$
sound$ = LOADSOUND("beep.wav")
```

### Step 2: Play Once

```basic
PLAYSOUND sound$
```

### Step 3: Complete Example

```basic
REM Sound Effects Demo

LET beep$
LET music$

' Load sounds
beep$ = LOADSOUND("beep.wav")
music$ = LOADSOUND("background.mp3")

' Play a beep
PRINT "Playing beep..."
PLAYSOUND beep$

SLEEP 1000

' Play background music (loop)
PRINT "Starting music..."
LOOPSOUND music$

PRINT "Press any key to stop..."
WHILE INKEY = 0
    SLEEP 100
WEND

STOPSOUND music$
PRINT "Done!"
```

## Sound Commands Summary

| Command | Description |
|---------|-------------|
| `LOADSOUND(file$)` | Load sound, returns ID |
| `PLAYSOUND(id$)` | Play sound once |
| `LOOPSOUND(id$)` | Play sound looping |
| `STOPSOUND(id$)` | Stop playing sound |

## Tips

- Load sounds at program start (not in loops)
- Use short `.wav` files for sound effects
- Use `.mp3` for longer music
- Always `STOPSOUND` before program ends

## Example: Game Sounds

```basic
REM Game with sound effects

LET jumpSound$
LET hitSound$
LET score$

jumpSound$ = LOADSOUND("jump.wav")
hitSound$ = LOADSOUND("hit.wav")
score$ = 0

PRINT "Press SPACE to jump, X to hit"

WHILE INKEY <> 27    ' ESC to exit
    LET key$ = INKEY
    
    IF key$ = 32 THEN    ' Space
        PLAYSOUND jumpSound$
        PRINT "Jump!"
    ELSEIF key$ = 120 THEN    ' x
        PLAYSOUND hitSound$
        score$ = score$ + 10
        PRINT "Hit! Score: "; score$
    ENDIF
    
    SLEEP 50
WEND
```

## What You Learned

- Loading sounds with `LOADSOUND`
- Playing sounds once or looped
- Stopping sounds
- Using sounds in a game loop

## Next Steps

- [Sound Commands Reference](sounds.md)
- [Ball Animation Tutorial](tutorial-ball-animation.md) - add sounds to animation!
