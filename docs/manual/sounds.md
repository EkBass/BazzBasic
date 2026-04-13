# Sound System

BazzBasic includes a comprehensive sound system built on SDL2_mixer, supporting audio playback with both background and blocking modes.

## Overview

The sound system allows you to:
- Load sound files in various formats (WAV, MP3, etc.)
- Play sounds once or in a continuous loop
- Control playback (stop individual sounds or all at once)
- Choose between background playback or wait-for-completion modes

## Supported Audio Formats

- **WAV** (recommended for best compatibility)
- **MP3**
- Other formats supported by SDL2_mixer.dll

## Sound Commands

### LOADSOUND(filepath$)

Loads a sound file from disk and returns a unique sound ID string.

**Returns:** String - Unique identifier for the loaded sound

**Syntax:**
```vb
LET SOUND_ID# = LOADSOUND("path/to/sound.wav")
' or
LET SOUND_ID# = LOADSOUND("path\\to\\sound.wav")
```

**Note:** If you use "\", you must use it as double "\\" since it is also a escape character

**Example:**
```vb
LET EXPLOSION#
EXPLOSION# = LOADSOUND("C:\\sounds\\explosion.wav")
PRINT "Sound loaded with ID: "; EXPLOSION#
```

**Notes:**
- The file must exist or an error will occur
- Each call to LOADSOUND creates a new independent sound instance
- The same file can be loaded multiple times for overlapping playback

---

### SOUNDONCE(SOUND_ID#)

Plays a loaded sound once in the background. Program execution continues immediately.

**Syntax:**
```vb
SOUNDONCE(SOUND_ID#)
```

**Example:**
```vb
LET BEEP#
BEEP# = LOADSOUND("beep.wav")
SOUNDONCE(BEEP#)
PRINT "Sound playing in background..."
SLEEP 1000
PRINT "Continuing while sound plays..."
```

**Use Cases:**
- Sound effects in games
- UI feedback sounds
- Background audio that shouldn't block program flow

---

### SOUNDONCEWAIT(SOUND_ID#)

Plays a sound once and waits for playback to complete before continuing program execution.

**Syntax:**
```vb
SOUNDONCEWAIT(SOUND_ID#)
```

**Example:**
```vb
LET INTRO#
INTRO# = LOADSOUND("intro_music.wav")
PRINT "Playing intro..."
SOUNDONCEWAIT(INTRO#)
PRINT "Intro finished, starting game!"
```

**Use Cases:**
- Intro music or narration
- Sequential audio playback
- When timing with program flow is critical

---

### SOUNDREPEAT(SOUND_ID#)

Plays a sound in a continuous loop in the background.

**Syntax:**
```vb
SOUNDREPEAT(SOUND_ID#)
```

**Example:**
```vb
LET BG_MUSIC#
BG_MUSIC# = LOADSOUND("background_music.wav")
SOUNDREPEAT(BG_MUSIC#)
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

### SOUNDSTOP(SOUND_ID#)

Stops playback of a specific sound.

**Syntax:**
```vb
SOUNDSTOP(SOUND_ID#)
```

**Example:**
```vb
LET ALARM#
ALARM# = LOADSOUND("alarm.wav")
SOUNDREPEAT(ALARM#)
PRINT "Alarm ringing..."
SLEEP 5000
SOUNDSTOP(ALARM#)
PRINT "Alarm stopped"
```

**Notes:**
- Safe to call even if sound is not currently playing
- Stops both looping and one-time playback

---

### SOUNDSTOPALL

Stops all currently playing sounds at once.

**Syntax:**
```vb
SOUNDSTOPALL
```

**Example:**
```vb
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

```vb
REM ============================================
REM Simple Game with Sound Effects
REM ============================================

CLS
PRINT "Loading sounds..."

REM Load all game sounds
LET JUMP#, COIN#, DEATH#, BG_MUSIC#
JUMP# = LOADSOUND("C:\\game_sounds\\jump.wav")
COIN# = LOADSOUND("C:\\game_sounds\\coin.wav")
DEATH# = LOADSOUND("C:\\game_sounds\\death.wav")
BG_MUSIC# = LOADSOUND("C:\\game_sounds\\music.wav")

REM Start background music
SOUNDREPEAT(BG_MUSIC#)

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
        SOUNDONCE(JUMP#)
        PRINT "Jump!"
    ENDIF
    
    REM Simulate collecting a coin
    IF RND(100) < 1 THEN
        coins_collected$ = coins_collected$ + 1
        score$ = score$ + 10
        SOUNDONCE(COIN#)
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
SOUNDONCEWAIT(DEATH#)
PRINT "Thanks for playing!"

END
```

## Example: Multiple Background Sounds

```vb
REM Layer multiple ambient sounds

LET RAIN#, WIND#, THUNDER#
RAIN# = LOADSOUND("rain.wav")
WIND# = LOADSOUND("wind.wav")  
THUNDER# = LOADSOUND("thunder.wav")

REM Start ambient background
SOUNDREPEAT(RAIN#)
SOUNDREPEAT(WIND#)

PRINT "Storm ambience playing..."
SLEEP 5000

REM Add thunder effect
SOUNDONCE(THUNDER#)
SLEEP 3000

REM Stop all ambience
SOUNDSTOPALL
PRINT "Storm ended"

END
```

## Example: Sequential Audio Narration

```vb
REM Play audio files in sequence

LET PART1#, PART2#, PART3#
PART1# = LOADSOUND("narration_part1.wav")
PART2# = LOADSOUND("narration_part2.wav")
PART3# = LOADSOUND("narration_part3.wav")

PRINT "Starting narration..."
SOUNDONCEWAIT(PART1#)
PRINT "Part 1 complete"

SOUNDONCEWAIT(PART2#)
PRINT "Part 2 complete"

SOUNDONCEWAIT(PART3#)
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
   ```vb
   REM Load all sounds at startup
   LET SFX_JUMP#, SFX_COIN#, MUSIC_BG#
   SFX_JUMP# = LOADSOUND("sfx\\jump.wav")
   SFX_COIN# = LOADSOUND("sfx\\coin.wav")
   MUSIC_BG# = LOADSOUND("music\\background.wav")
   ```

2. **Use Appropriate Playback Modes**
   - `SOUNDONCE` - Short sound effects
   - `SOUNDREPEAT` - Background music, ambient loops
   - `SOUNDONCEWAIT` - Sequential audio, narration

3. **Clean Up Audio**
   ```vb
   REM Before program exit
   SOUNDSTOPALL
   END
   ```

4. **Handle Game States**
   ```vb
   REM When pausing game
   SOUNDSTOPALL
   
   REM When resuming
   SOUNDREPEAT(BG_MUSIC#)
   ```
  
## Why Constants, Not Variables?

Sound IDs returned by `LOADSOUND` are handles assigned by SDL2. BazzBasic uses them only to point to the correct audio resource — they never change during program execution.

Storing them in constants (`#` suffix) communicates this intent clearly:

```basic
LET SHOOT_SND# = LOADSOUND("shoot.wav")
```

Using a mutable variable (`$` suffix) would work, but it implies the value *could* change — which is misleading and leaves the door open for accidental reassignment bugs.

**The rule of thumb:** if a value is set once and never modified, it belongs in a constant.

---

### When to Use an Array Instead

If your program loads many sounds at once, individual constants become verbose. In that case, a named array is cleaner and self-documenting:

```basic
DIM sounds$
	sounds$("shoot") 		= LOADSOUND("shoot.wav")
	sounds$("explosion") 	= LOADSOUND("explosion.wav")
	sounds$("pickup") 		= LOADSOUND("pickup.wav")

SOUNDOCE(sounds$("shoot"))
```

For larger projects with categorized sounds, multidimensional string keys scale even better:

```basic
DIM sounds$
	sounds$("shoot", "shotgun") 	= LOADSOUND("shoot_shotgun.wav")
	sounds$("shoot", "ak47")    	= LOADSOUND("shoot_ak47.wav")
	sounds$("explosion", "small") 	= LOADSOUND("explosion_small.wav")
	sounds$("explosion", "large") 	= LOADSOUND("explosion_large.wav")

SOUNDONCE(sounds$("shoot", "ak47"))
```

This keeps sound assets organized by category and type — easy to extend without renaming anything.