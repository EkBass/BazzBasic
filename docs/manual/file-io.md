# File handling

BazzBasic includes a simple but powerful file system for reading and writing text files, enabling games to save scores, settings, and game state.

## Overview

The file system allows you to:
- Read text file contents as strings
- Write or overwrite files
- Append content to existing files
- Check if files exist
- Delete files
- Work with both relative and absolute paths
- Automatically create directories as needed

## Supported File Operations

- **Text file reading** - Load entire file as string
- **Text file writing** - Create or overwrite files
- **Text file appending** - Add content to end of files
- **File existence checking** - Verify files exist before operations
- **File deletion** - Remove files from disk
- **Automatic directory creation** - Parent directories created automatically

## File Functions

### FILEREAD(filepath$)

Reads the entire contents of a text file and returns it as a string or array.

**Returns:** String - Complete file contents, or empty string if file doesn't exist or error occurs

**Syntax:**
```vb
content$ = FILEREAD("path/to/file.txt")
```

**Example with variable:**
```vb
LET config$
config$ = FILEREAD("settings.txt")
IF LEN(config$) > 0 THEN
    PRINT "Config loaded: "; config$
ELSE
    PRINT "Config file not found"
ENDIF
```
**Example with array:**
```vb
LET FILENAME# = "array.txt"
DIM a$
a$("first") = 1
a$("second") = 2
a$("third") = 3
a$("fourth") = "Four"
a$("fourth", "temp") = "Temp"
FILEWRITE FILENAME#, a$
DIM b$ = FILEREAD(FILENAME#)
PRINT b$("fourth", "temp")
```

**Notes:**
- Returns empty string on error (no exception thrown)
- Handles various text encodings automatically
- Best for small to medium-sized text files
- Line breaks are preserved in the returned string

---

### FILEEXISTS(filepath$)

Checks whether a file exists at the specified path.

**Returns:** Number - 1 if file exists, 0 if not

**Syntax:**
```vb
LET exists# = FILEEXISTS("path/to/file.txt")
```

**Example:**
```vb
IF FILEEXISTS("highscore.txt") = 1 THEN
    PRINT "Loading existing scores..."
    LET scores$ = FILEREAD("highscore.txt")
ELSE
    PRINT "No saved scores found"
    LET scores$ = "0"
ENDIF
```

**Notes:**
- Safe to call on any path
- Returns 0 if path doesn't exist or access is denied
- Use before FILEREAD to avoid empty string results
- Useful for conditional file operations

---

## File Commands

### FILEWRITE filepath$, content$

Writes content to a file, creating it if it doesn't exist or overwriting it completely if it does.

**Syntax:**
```vb
FILEWRITE filepath$, content$
```

**Example with string:**
```vb
LET score$ = 12345
LET playerName$ = "Alice"
LET saveData$ = playerName$ + "\n" + STR(score$)
FILEWRITE "savegame.txt", saveData$
PRINT "Game saved!"
```

**Example with array:**
```vb
LET FILENAME# = "array.txt"
DIM a$
a$("first") = 1
a$("second") = 2
a$("third") = 3
a$("fourth") = "Four"
a$("fourth", "temp") = "Temp"
FILEWRITE FILENAME#, a$
DIM b$ = FILEREAD(FILENAME#)
PRINT b$("fourth", "temp") ' Outputs: Temp
```

**Notes:**
- Creates parent directories automatically if they don't exist
- Completely replaces existing file contents
- Silent operation - no return value
- Use `\n` for line breaks in content
- Escape backslashes in paths: `"data\\save.txt"` or use forward slash: `"data/save.txt"`

---

### FILEAPPEND filepath$, content$

Appends content to the end of an existing file, or creates the file if it doesn't exist.

**Syntax:**
```vb
FILEAPPEND filepath$, content$
```

**Example:**
```vb
LET timestamp$ = "2025-01-04 15:30:00"
LET logEntry$ = timestamp$ + " - Game started\n"
FILEAPPEND "gamelog.txt", logEntry$
```

**Notes:**
- Creates file if it doesn't exist
- Adds content to end without removing existing data
- Perfect for logging and incremental data
- Creates directories automatically if needed

---

### FILEDELETE filepath$

Deletes a file from the file system.

**Syntax:**
```vb
FILEDELETE filepath$
```

**Example:**
```vb
REM Clean up temporary files
IF FILEEXISTS("temp.dat") = 1 THEN
    FILEDELETE "temp.dat"
    PRINT "Temporary file removed"
ENDIF
```

**Notes:**
- Silent operation if file doesn't exist
- Irreversible operation - use with caution
- Useful for cleanup and reset operations

---

## Loading key=value Files into Arrays (.env support)

When `FILEREAD` assigns to a `DIM`'d array, BazzBasic automatically parses the file contents line by line into array elements — using the `key=value` format that `.env` files use.

```vb
DIM config$
LET config$ = FILEREAD("settings.txt")

PRINT config$("width")      ' Output: 800
PRINT config$("height")     ' Output: 600
PRINT config$("title")      ' Output: My Game
```

Where `settings.txt` contains:
```
width=800
height=600
title=My Game
```

Lines beginning with `#` are treated as comments and ignored:
```
# Game settings
width=800
height=600

# Display options
fullscreen=0
```

### Using .env files for API keys

This makes standard `.env` files work directly for storing sensitive values such as API keys outside of source code:

```vb
IF FILEEXISTS(".env") = 0 THEN
    PRINT "Error: .env file not found"
    END
END IF

DIM env$
LET env$ = FILEREAD(".env")

LET ApiKey# = env$("OPENAI_API_KEY")
LET OtherKey# = env$("OTHER_SERVICE_KEY")
```

Where `.env` contains:
```
OPENAI_API_KEY=sk-proj-...
OTHER_SERVICE_KEY=abc123...
```

**Important:** Add `.env` to your `.gitignore` to keep API keys out of version control:
```
.env
```

**Note:** This parsing only happens when assigning `FILEREAD` to a `DIM`'d array. Assigning to a regular variable (`LET data$`) always returns the raw file contents as a plain string.

---

## Path Handling

### Relative vs Absolute Paths

**Relative Paths** (recommended for game files):
```vb
FILEWRITE "highscore.txt", "1000"           REM Same directory as program
FILEWRITE "data/settings.txt", "sound=on"   REM Subdirectory
```

**Absolute Paths** (for system-wide access):
```vb
FILEWRITE "C:/Users/Player/Documents/save.txt", "data"
```

**Note:** Use forward slashes `/` or escaped backslashes `\\` to avoid escape sequence issues:
```vb
REM CORRECT:
FILEWRITE "data/file.txt", "content"
FILEWRITE "data\\file.txt", "content"

REM WRONG (escape sequences):
FILEWRITE "data\file.txt", "content"  REM \f becomes form feed!
```

### PRG_ROOT# Constant

BazzBasic provides a `PRG_ROOT#` constant containing the program's base directory path.

**Example:**
```vb
PRINT "Program root: "; PRG_ROOT#

REM Build absolute paths
LET savePath# = PRG_ROOT# + "/saves/game1.txt"
FILEWRITE savePath#, "Player data"
```

**Use Cases:**
- Ensuring consistent file locations
- Building absolute paths from relative ones
- Debugging path issues

---

## Complete Example: Highscore System

```vb
REM ============================================
REM Highscore Save/Load System
REM ============================================

CLS
PRINT "=== Highscore Demo ==="
PRINT ""

LET scoreFile$ = "highscore.txt"
LET currentScore$

REM Load existing highscore
IF FILEEXISTS(scoreFile$) = 1 THEN
    LET scoreData$ = FILEREAD(scoreFile$)
    LET highScore# = VAL(scoreData$)
    PRINT "Current highscore: "; highScore$
ELSE
    PRINT "No previous highscore found"
ENDIF

PRINT ""
PRINT "Play the game..."
REM Simulate gameplay
currentScore$ = RND(10000)

PRINT "Your score: "; currentScore$
PRINT ""

REM Check if new highscore
IF currentScore$ > highScore# THEN
    PRINT "NEW HIGHSCORE!"
    FILEWRITE scoreFile$, STR(currentScore$)
    PRINT "Highscore saved!"
ELSE
    PRINT "Better luck next time!"
ENDIF

END
```

---

## Complete Example: Game Settings

```vb
REM ============================================
REM Game Settings Manager
REM ============================================

LET settingsFile$ = "settings.txt"
LET soundEnabled$ = "1"
LET musicVolume$ = "80"
LET difficulty$ = "medium"

REM Load settings if they exist
IF FILEEXISTS(settingsFile$) = 1 THEN
    PRINT "Loading settings..."
    LET settings$ = FILEREAD(settingsFile$)
    
    REM Parse settings (simple format: one per line)
    REM In real game, you'd parse the string
    PRINT "Settings loaded"
ELSE
    PRINT "Creating default settings..."
    
    REM Build settings string
    LET settings$ = ""
    settings$ = settings$ + "sound=" + soundEnabled$ + "\n"
    settings$ = settings$ + "volume=" + musicVolume$ + "\n"
    settings$ = settings$ + "difficulty=" + difficulty$ + "\n"
    
    FILEWRITE settingsFile$, settings$
    PRINT "Default settings saved"
ENDIF

REM Display settings
PRINT ""
PRINT "Current Settings:"
PRINT settings$

END
```

---

## Complete Example: Game Event Log

```vb
REM ============================================
REM Event Logging System
REM ============================================

LET logFile$ = "gamelog.txt"

REM Initialize log file
IF FILEEXISTS(logFile$) = 0 THEN
    FILEWRITE logFile$, "=== Game Log ===\n"
ENDIF

REM Function to log an event
REM (In real code, use DEF FN)
LET event$ = "Game started"
FILEAPPEND logFile$, event$ + "\n"

REM Simulate game events
SLEEP 1000
event$ = "Player spawned at (100, 200)"
FILEAPPEND logFile$, event$ + "\n"

SLEEP 1000  
event$ = "Enemy encountered"
FILEAPPEND logFile$, event$ + "\n"

SLEEP 1000
event$ = "Player health: 75"
FILEAPPEND logFile$, event$ + "\n"

SLEEP 1000
event$ = "Game ended"
FILEAPPEND logFile$, event$ + "\n"

PRINT "Events logged!"
PRINT ""
PRINT "Log contents:"
PRINT FILEREAD(logFile$)

END
```

---

## Complete Example: Save Game System

```vb
REM ============================================
REM Simple Save Game System
REM ============================================

LET saveFile$ = "savegame.dat"

REM Game state variables
LET playerName$ = "Hero"
LET playerLevel$ = 5
LET playerHealth$ = 85
LET playerGold$ = 1250
LET currentMap$ = "dungeon_2"

REM === SAVE GAME ===
PRINT "Saving game..."

REM Build save data string (simple format)
LET saveData$ = ""
saveData$ = saveData$ + playerName$ + "\n"
saveData$ = saveData$ + STR(playerLevel$) + "\n"
saveData$ = saveData$ + STR(playerHealth$) + "\n"
saveData$ = saveData$ + STR(playerGold$) + "\n"
saveData$ = saveData$ + currentMap$ + "\n"

FILEWRITE saveFile$, saveData$
PRINT "Game saved!"
PRINT ""

REM === LOAD GAME ===
PRINT "Loading game..."

IF FILEEXISTS(saveFile$) = 1 THEN
    LET loadedData$ = FILEREAD(saveFile$)
    PRINT "Save file loaded:"
    PRINT loadedData$
    
    REM In real game, parse the string and restore variables
    PRINT "Game loaded successfully!"
ELSE
    PRINT "No save file found!"
ENDIF

END
```

---

## Technical Details

### Automatic Directory Creation
- Parent directories are created automatically when writing files
- Example: `FILEWRITE "saves/slot1/data.txt", "..."` creates `saves/slot1/` if needed
- No need to manually create directory structure

### Error Handling
- **FILEREAD**: Returns empty string on error (no exception)
- **FILEEXISTS**: Returns 0 on error or non-existent file
- **FILEWRITE/FILEAPPEND/FILEDELETE**: Silent failures (no exceptions)
- Check results with FILEEXISTS before/after operations if needed

### Character Encoding
- Handles UTF-8 and other common text encodings automatically
- String content preserves line breaks and special characters
- Use `\n` for newlines, `\t` for tabs in string literals

### Path Resolution
- **Relative paths**: Resolved from program's base directory (PRG_ROOT#)
- **Absolute paths**: Used as-is if rooted (e.g., `C:/...`)
- Forward slashes `/` work on all platforms
- Backslashes must be escaped: `\\`

### Thread Safety
- All file operations are synchronous
- Safe for sequential access
- Avoid concurrent writes to same file

---

## Best Practices

1. **Check File Existence Before Reading**
   ```vb
   IF FILEEXISTS("data.txt") = TRUE THEN
       LET data$ = FILEREAD("data.txt")
   ELSE
       LET data$ = ""  REM Default value
   ENDIF
   ```

2. **Use Relative Paths for Game Files**
   ```vb
   REM Keep game files organized
   FILEWRITE "saves/slot1.dat", saveData$
   FILEWRITE "config/settings.txt", config$
   ```

3. **Structure Your Save Data**
   ```vb
   REM Use clear format (one value per line)
   LET data$ = ""
   data$ = data$ + "PlayerName=" + name$ + "\n"
   data$ = data$ + "Score=" + STR(score#) + "\n"
   FILEWRITE "save.txt", data$
   ```

4. **Use FILEAPPEND for Logs**
   ```vb
   REM Accumulate log entries
   FILEAPPEND "debug.log", "Error occurred\n"
   ```

5. **Clean Up Temporary Files**
   ```vb
   REM At program exit
   IF FILEEXISTS("temp.dat") = 1 THEN
       FILEDELETE "temp.dat"
   ENDIF
   ```

6. **Escape Path Separators**
   ```vb
   REM CORRECT:
   FILEWRITE "data/save.txt", content$
   FILEWRITE "data\\save.txt", content$
   
   REM WRONG:
   FILEWRITE "data\save.txt", content$  REM \s might be escape!
   ```

---

## Common Patterns

### Save/Load Pattern
```vb
REM Save
FILEWRITE "game.sav", gameState$

REM Load
IF FILEEXISTS("game.sav") = 1 THEN
    gameState$ = FILEREAD("game.sav")
ENDIF
```

### Config File Pattern
```vb
REM Load or create default
IF FILEEXISTS("config.txt") = 0 THEN
    FILEWRITE "config.txt", defaultConfig$
ENDIF
config$ = FILEREAD("config.txt")
```

### Incremental Log Pattern
```vb
REM Add entries over time
FILEAPPEND "log.txt", timestamp$ + ": " + message$ + "\n"
```

### Multiple Save Slots
```vb
LET slot$ = 1
LET filename$ = "save" + STR(slot$) + ".dat"
FILEWRITE filename$, data$
```

---

## Troubleshooting

**Problem:** FILEREAD returns empty string
- Check file exists with FILEEXISTS first
- Verify file path is correct (use forward slashes)
- Check file isn't locked by another program
- Try absolute path to debug

**Problem:** FILEWRITE doesn't create file
- Check path doesn't contain invalid characters
- Verify disk isn't full or write-protected
- Check permissions on target directory

**Problem:** Escape sequence in path
- Use forward slashes: `"data/file.txt"`
- Or escape backslashes: `"data\\file.txt"`
- Avoid: `\n`, `\t`, `\r` in paths

**Problem:** Can't find files after writing
- Print PRG_ROOT# to see base directory
- Use absolute paths for debugging
- Check program's working directory

---

## Limitations

- Text files only (no binary data support)
- No file size limits enforced (use caution with large files)
- No file locking or concurrent access control
- No directory enumeration (can't list files in folder)
- No file metadata (size, dates, permissions)
- No copy or move operations

---

## Future Enhancements

Potential additions to the file system:
- Binary file support (read/write bytes)
- Directory listing and enumeration
- File copy and move operations
- File metadata queries (size, modified date)
- File locking for concurrent access
- Stream-based reading for large files
- CSV and JSON parsing helpers
- Compression support
