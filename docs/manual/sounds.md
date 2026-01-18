# Sound System

BazzBasic includes a comprehensive sound system built on NAudio, supporting audio playback with both background and blocking modes.

## Overview

The sound system allows you to:
- Load sound files in various formats (WAV, MP3, etc.)
- Play sounds once or in a continuous loop
- Control playback (stop individual sounds or all at once)
- Choose between background playback or wait-for-completion modes

## Supported Audio Formats

- **WAV** (recommended for best compatibility)
- **MP3**
- Other formats supported by NAudio

## Sound Commands

### LOADSOUND(filepath$)

Loads a sound file from disk and returns a unique sound ID string.

**Returns:** String - Unique identifier for the loaded sound

**Syntax:**
```basic
LET soundId$ = LOADSOUND("path/to/sound.wav")
' or
LET soundId$ = LOADSOUND("path\\to\\sound.wav")
```

**Note:** If you use "\", you must use it as double "\\" since it is also a escape character

**Example:**
```basic
LET explosion$
explosion$ = LOADSOUND("C:\\sounds\\explosion.wav")
PRINT "Sound loaded with ID: "; explosion$
```

**Notes:**
- The file must exist or an error will occur
- Each call to LOADSOUND creates a new independent sound instance
- The same file can be loaded multiple times for overlapping playback

---

### SOUNDONCE(soundId$)

Plays a loaded sound once in the background. Program execution continues immediately.

**Syntax:**
```basic
SOUNDONCE(soundId$)
```

**Example:**
```basic
LET beep$
beep$ = LOADSOUND("beep.wav")
SOUNDONCE(beep$)
PRINT "Sound playing in background..."
SLEEP 1000
PRINT "Continuing while sound plays..."
```

**Use Cases:**
- Sound effects in games
- UI feedback sounds
- Background audio that shouldn't block program flow

---

### SOUNDONCEWAIT(soundId$)

Plays a sound once and waits for playback to complete before continuing program execution.

**Syntax:**
```basic
SOUNDONCEWAIT(soundId$)
```

**Example:**
```basic
LET intro$
intro$ = LOADSOUND("intro_music.wav")
PRINT "Playing intro..."
SOUNDONCEWAIT(intro$)
PRINT "Intro finished, starting game!"
```

**Use Cases:**
- Intro music or narration
- Sequential audio playback
- When timing with program flow is critical

---

### SOUNDREPEAT(soundId$)

Plays a sound in a continuous loop in the background.

**Syntax:**
```basic
SOUNDREPEAT(soundId$)
```

**Example:**
```basic
LET bgmusic$
bgmusic$ = LOADSOUND("background_music.wav")
SOUNDREPEAT(bgmusic$)
PRINT "Music looping in background..."
REM Game loop runs here
```

**Notes:**
- Sound loops seamlessly when it reaches the end
- Use SOUNDSTOP to stop the loop
- Multiple sounds can be looping simultaneously

**Use Cases:**
- Background music
- Ambient sounds (rain, wind, etc.)
- Continuous sound effects

---

### SOUNDSTOP(soundId$)

Stops playback of a specific sound.

**Syntax:**
```basic
SOUNDSTOP(soundId$)
```

**Example:**
```basic
LET alarm$
alarm$ = LOADSOUND("alarm.wav")
SOUNDREPEAT(alarm$)
PRINT "Alarm ringing..."
SLEEP 5000
SOUNDSTOP(alarm$)
PRINT "Alarm stopped"
```

**Notes:**
- Safe to call even if sound is not currently playing
- Stops both looping and one-time playback

---

### SOUNDSTOPALL

Stops all currently playing sounds at once.

**Syntax:**
```basic
SOUNDSTOPALL
```

**Example:**
```basic
REM Emergency stop all audio
SOUNDSTOPALL
PRINT "All sounds stopped"
```

**Use Cases:**
- Game pause functionality
- Switching between game states
- Emergency audio cutoff
- Cleanup before program exit

---

## Complete Example: Game with Sound

```basic
REM ============================================
REM Simple Game with Sound Effects
REM ============================================

CLS
PRINT "Loading sounds..."

REM Load all game sounds
LET jump$, coin$, death$, bgmusic$
jump$ = LOADSOUND("C:\\game_sounds\\jump.wav")
coin$ = LOADSOUND("C:\\game_sounds\\coin.wav")
death$ = LOADSOUND("C:\\game_sounds\\death.wav")
bgmusic$ = LOADSOUND("C:\\game_sounds\\music.wav")

REM Start background music
SOUNDREPEAT(bgmusic$)

REM Game variables
LET score$ = 0
LET playing$ = 1
LET coins_collected$ = 0

PRINT "Game started! Press SPACE to jump, ESC to quit"

REM Main game loop
WHILE playing$
    LET key$ = INKEY
    
    IF key$ = KEY_ESC# THEN
        playing$ = 0
    ENDIF
    
    IF key$ = KEY_SPACE# THEN
        SOUNDONCE(jump$)
        PRINT "Jump!"
    ENDIF
    
    REM Simulate collecting a coin
    IF RND(100) < 1 THEN
        coins_collected$ = coins_collected$ + 1
        score$ = score$ + 10
        SOUNDONCE(coin$)
        PRINT "Coin collected! Score: "; score$
    ENDIF
    
    REM Simulate game over condition
    IF coins_collected$ >= 10 THEN
        playing$ = 0
    ENDIF
    
    SLEEP 50
WEND

REM Game over sequence
SOUNDSTOPALL
PRINT ""
PRINT "Game Over!"
PRINT "Final Score: "; score$
SOUNDONCEWAIT(death$)
PRINT "Thanks for playing!"

END
```

## Example: Multiple Background Sounds

```basic
REM Layer multiple ambient sounds

LET rain$, wind$, thunder$
rain$ = LOADSOUND("rain.wav")
wind$ = LOADSOUND("wind.wav")  
thunder$ = LOADSOUND("thunder.wav")

REM Start ambient background
SOUNDREPEAT(rain$)
SOUNDREPEAT(wind$)

PRINT "Storm ambience playing..."
SLEEP 5000

REM Add thunder effect
SOUNDONCE(thunder$)
SLEEP 3000

REM Stop all ambience
SOUNDSTOPALL
PRINT "Storm ended"

END
```

## Example: Sequential Audio Narration

```basic
REM Play audio files in sequence

LET part1$, part2$, part3$
part1$ = LOADSOUND("narration_part1.wav")
part2$ = LOADSOUND("narration_part2.wav")
part3$ = LOADSOUND("narration_part3.wav")

PRINT "Starting narration..."
SOUNDONCEWAIT(part1$)
PRINT "Part 1 complete"

SOUNDONCEWAIT(part2$)
PRINT "Part 2 complete"

SOUNDONCEWAIT(part3$)
PRINT "Narration finished!"

END
```

## Technical Details

### Thread Safety
- All sound operations are thread-safe
- Multiple sounds can play simultaneously
- Concurrent calls to SOUNDSTOP/SOUNDSTOPALL are handled safely

### Memory Management
- Sound files are loaded into memory when LOADSOUND is called
- Each sound instance maintains its own playback state
- Resources are automatically cleaned up when program ends
- Use SOUNDSTOPALL before exit for clean shutdown

### Performance Considerations
- Load sounds once at program start for best performance
- Avoid loading the same file repeatedly if possible
- Short sound effects are ideal for SOUNDONCE
- Longer audio files work well with SOUNDREPEAT

### Looping Behavior
- SOUNDREPEAT loops seamlessly without gaps
- Loop restarts automatically when sound completes
- IsRepeating flag can be interrupted by SOUNDSTOP

### Error Handling
- Invalid file paths throw exceptions with clear error messages
- Missing sound files are reported at load time
- Stopping non-existent sounds is a silent no-op

## Best Practices

1. **Organize Your Sounds**
   ```basic
   REM Load all sounds at startup
   LET sfx_jump$, sfx_coin$, music_bg$
   sfx_jump$ = LOADSOUND("sfx\\jump.wav")
   sfx_coin$ = LOADSOUND("sfx\\coin.wav")
   music_bg$ = LOADSOUND("music\\background.wav")
   ```

2. **Use Appropriate Playback Modes**
   - `SOUNDONCE` - Short sound effects
   - `SOUNDREPEAT` - Background music, ambient loops
   - `SOUNDONCEWAIT` - Sequential audio, narration

3. **Clean Up Audio**
   ```basic
   REM Before program exit
   SOUNDSTOPALL
   END
   ```

4. **Handle Game States**
   ```basic
   REM When pausing game
   SOUNDSTOPALL
   
   REM When resuming
   SOUNDREPEAT(bgmusic$)
   ```

## Troubleshooting

**Problem:** Sound doesn't play
- Verify file path is correct and absolute
- Check file format is supported (WAV recommended)
- Ensure file exists at specified location

**Problem:** Sound cuts off unexpectedly  
- Use SOUNDONCEWAIT if timing is critical
- Check that SOUNDSTOPALL isn't being called prematurely

**Problem:** Memory issues with many sounds
- Load sounds once, reuse sound IDs
- Consider limiting simultaneous playback
- Stop sounds when no longer needed

## Limitations

- Text/audio data only (no real-time generation)
- Sound IDs are GUID strings (not sequential numbers)
- No volume control (currently plays at system volume)
- No pitch/speed modification
- No audio mixing/effects

## Future Enhancements

Potential additions to the sound system:
- Volume control per sound
- Fade in/fade out effects
- Audio positioning (left/right balance)
- Real-time audio generation
- Audio recording capabilities
